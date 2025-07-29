//+------------------------------------------------------------------+
//| One Trade EA for MetaTrader 5                                    |
//| Implements the strategy as described in the project README       |
//+------------------------------------------------------------------+

#property copyright "Lu_Yiji_Project"
#property version   "1.00"
#property strict



#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

// Remove EasyAndFastGUI includes and use SimpleWindow
#include <InterfaceGui.mqh>
#include <OneTradeEA_Core.mqh>
#include <EventHandler.mqh>

#ifndef OBJPROP_HEIGHT
#define OBJPROP_HEIGHT 133
#endif

#ifndef FILE_APPEND
#define FILE_APPEND 8
#endif

// Helper for closing positions
bool PositionClose(ulong ticket) {
   CTrade trade;
   return trade.PositionClose(ticket);
}

// Helper for getting today's date at 00:00
datetime DateOfDay(datetime t) {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   return StructToTime(dt);
}

// Helper for formatting time as HH:MM
string TimeToStr(datetime t, int mode=0) {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   if(mode==0) return StringFormat("%02d:%02d", dt.hour, dt.min);
   else return StringFormat("%02d:%02d:%02d", dt.hour, dt.min, dt.sec);
}

//--- Input parameters
input ENUM_ORDER_TYPE   InpTradeMode = ORDER_TYPE_BUY; // Trade Mode (Buy/Sell)
input double            InpLotSize   = 0.10;           // Lot Size
input int               InpStopLoss  = 20;             // Stop Loss (pips)
input double            InpRiskValue = 1.00;           // Risk [1] (value)
input double            InpRewardValue = 2.00;         // Reward [2] (value)
input string            InpOpenTime  = "09:00";        // Opening Time (HH:MM)
input string            InpCloseTime = "17:00";        // Closing Time (HH:MM)
input int               InpMaxReplacements = 2;        // Max Replacements
input string            InpWindowStart = "";           // Time Window Start (HH:MM, empty=off)
input string            InpWindowEnd   = "";           // Time Window End (HH:MM, empty=off)

//--- OOP Managers
class TimeManager
  {
   public:
      datetime openTime, closeTime, windowStart, windowEnd;
      TimeManager() {}
      void ParseTimes(string open, string close, string winStart, string winEnd)
        {
         openTime = ParseTime(open);
         closeTime = ParseTime(close);
         windowStart = ParseTime(winStart);
         windowEnd = ParseTime(winEnd);
        }
      bool IsInTimeWindow(datetime now)
        {
         if(windowStart==0 || windowEnd==0) return false;
         return (now >= windowStart && now <= windowEnd);
        }
      bool IsNewDay(datetime now)
        {
         static int lastDay = -1;
         MqlDateTime dt; TimeToStruct(now, dt); int today = dt.day;
         if(today != lastDay)
           {
            lastDay = today;
            return true;
           }
         return false;
        }
  };

//--- UI Object Name Constants
#define OT_PANEL      "OneTradeEA_Panel"
#define OT_LABEL      "OneTradeEA_Label"



class TradeManager
  {
   public:
      int replacementsLeft;
      bool tradeActive;
      bool pendingOrderActive;
      string magicNumber;
      string symbol;
      TradeManager() { tradeActive=false; pendingOrderActive=false; replacementsLeft=0; magicNumber=""; symbol=""; }
      void Init(int maxRepl, string sym)
        {
         replacementsLeft = maxRepl;
         tradeActive = false;
         pendingOrderActive = false;
         symbol = sym;
         magicNumber = symbol+"_OneTradeEA";
        }
      void Reset(int maxRepl)
        {
         replacementsLeft = maxRepl;
         tradeActive = false;
         pendingOrderActive = false;
        }
      void OpenFirstTrade()
        {
         MqlTradeRequest request;
         MqlTradeResult result;
         double price = 0, sl = 0, tp = 0;
         int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
         double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
         double stopLossPips = InpStopLoss * point * 10;
         double rr = InpRewardValue / InpRiskValue;
         double lot = InpLotSize;
         ENUM_ORDER_TYPE orderType = InpTradeMode;
         string tradeType = (orderType == ORDER_TYPE_BUY) ? "BUY" : "SELL";
         if(orderType == ORDER_TYPE_BUY)
           {
            price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
            sl = price - stopLossPips;
            tp = price + stopLossPips * rr;
           }
         else if(orderType == ORDER_TYPE_SELL)
           {
            price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
            sl = price + stopLossPips;
            tp = price - stopLossPips * rr;
           }
         else
           {
            logger.Log("ERROR: Invalid trade mode.");
            logger.LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), Symbol(), "ERROR", lot, sl, tp, "OrderSendFail", replacementsLeft, "MODE", 0);
            return;
           }
         ZeroMemory(request);
         request.action = TRADE_ACTION_DEAL;
         request.symbol = Symbol();
         request.volume = lot;
         request.type = orderType;
         request.price = price;
         request.sl = NormalizeDouble(sl, digits);
         request.tp = NormalizeDouble(tp, digits);
         request.deviation = 10;
         request.magic = 0; // Use 0 for simplicity, or set a unique int if needed
         request.comment = magicNumber;
         if(!OrderSend(request, result) || result.retcode != TRADE_RETCODE_DONE)
           {
            logger.Log("ERROR: OrderSend failed. Retcode: " + IntegerToString(result.retcode));
            logger.LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), Symbol(), tradeType, lot, sl, tp, "OrderSendFail", replacementsLeft, IntegerToString(result.retcode), 0);
            tradeActive = false;
            return;
           }
         tradeActive = true;
         replacementsLeft = InpMaxReplacements;
         logger.Log("First trade opened at " + TimeToString(TimeCurrent(), TIME_SECONDS) + ", Ticket: " + IntegerToString(result.order));
         logger.LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), Symbol(), tradeType, lot, sl, tp, "OPEN", replacementsLeft, "", result.order);
        }
      void MonitorTrades()
        {
         for(int i=0; i<PositionsTotal(); i++)
           {
            ulong ticket = PositionGetTicket(i);
            if(PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetString(POSITION_COMMENT) == magicNumber)
              {
               double sl = PositionGetDouble(POSITION_SL);
               double tp = PositionGetDouble(POSITION_TP);
               double priceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
               double priceCurrent = (mainPanel.GetMode()==0) ? SymbolInfoDouble(Symbol(), SYMBOL_BID) : SymbolInfoDouble(Symbol(), SYMBOL_ASK);
               bool closed = false;
               // Check for SL hit
               if(sl > 0 && ((mainPanel.GetMode() == 0 && priceCurrent <= sl) || (mainPanel.GetMode() == 1 && priceCurrent >= sl)))
                 {
                  logger.Log("SL hit. Closing position.");
                  string date = TimeToString(TimeCurrent(), TIME_DATE);
                  string time = TimeToString(TimeCurrent(), TIME_SECONDS);
                  if(PositionClose(ticket))
                    {
                     logger.Log("Position closed (SL). Ticket: " + IntegerToString(ticket));
                     logger.LogCSV(date, time, Symbol(), (mainPanel.GetMode()==0?"BUY":"SELL"), mainPanel.GetLot(), sl, tp, "SL", replacementsLeft, "", ticket);
                    }
                  else
                    {
                     logger.Log("ERROR: Failed to close position (SL). Ticket: " + IntegerToString(ticket));
                     logger.LogCSV(date, time, Symbol(), (mainPanel.GetMode()==0?"BUY":"SELL"), mainPanel.GetLot(), sl, tp, "SL_FAIL", replacementsLeft, "CLOSE", ticket);
                    }
                  tradeActive = false;
                  closed = true;
                  if(replacementsLeft > 0)
                    {
                     replacementsLeft--;
                     logger.Log("Opening replacement trade. Replacements left: " + IntegerToString(replacementsLeft));
                     OpenFirstTrade();
                    }
                  else
                    {
                     logger.Log("No replacements left. Trading done for today.");
                    }
                 }
               // Check for TP hit
               if(!closed && tp > 0 && ((mainPanel.GetMode() == 0 && priceCurrent >= tp) || (mainPanel.GetMode() == 1 && priceCurrent <= tp)))
                 {
                  logger.Log("TP hit. Closing position. Trading done for today.");
                  string date = TimeToString(TimeCurrent(), TIME_DATE);
                  string time = TimeToString(TimeCurrent(), TIME_SECONDS);
                  if(PositionClose(ticket))
                    {
                     logger.Log("Position closed (TP). Ticket: " + IntegerToString(ticket));
                     logger.LogCSV(date, time, Symbol(), (mainPanel.GetMode()==0?"BUY":"SELL"), mainPanel.GetLot(), sl, tp, "TP", replacementsLeft, "", ticket);
                    }
                  else
                    {
                     logger.Log("ERROR: Failed to close position (TP). Ticket: " + IntegerToString(ticket));
                     logger.LogCSV(date, time, Symbol(), (mainPanel.GetMode()==0?"BUY":"SELL"), mainPanel.GetLot(), sl, tp, "TP_FAIL", replacementsLeft, "CLOSE", ticket);
                    }
                  tradeActive = false;
                  replacementsLeft = 0;
                 }
              }
           }
        }
  };

class Logger
  {
   public:
      Logger() {}
      void Log(string msg)
        {
         Print("[OneTradeEA] ", msg);
        }
      // CSV logging
      string csvFile;
      void InitCSV(string filename)
        {
         csvFile = filename;
         // Write header if file does not exist
         int handle = FileOpen(csvFile, FILE_READ|FILE_TXT);
         if(handle < 0)
           {
            handle = FileOpen(csvFile, FILE_WRITE|FILE_TXT);
            if(handle >= 0)
              {
               FileWrite(handle, "Date,Time,Symbol,TradeType,Lot,SL,TP,Result,Replacement,ErrorCode,Ticket");
               FileClose(handle);
              }
           }
         else
           {
            FileClose(handle);
           }
        }
      void LogCSV(string date, string time, string symbol, string tradeType, double lot, double sl, double tp, string result, int replacement, string errorCode, ulong ticket)
        {
         int handle = FileOpen(csvFile, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_READ|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_APPEND);
         if(handle >= 0)
           {
            FileWrite(handle, date + "," + time + "," + symbol + "," + tradeType + "," + DoubleToString(lot,2) + "," + DoubleToString(sl,2) + "," + DoubleToString(tp,2) + "," + result + "," + IntegerToString((int)replacement) + "," + errorCode + "," + IntegerToString((int)ticket));
            FileClose(handle);
           }
        }
  };

//--- Manager instances
TimeManager timeManager;
TradeManager tradeManager;
Logger logger;

// Main panel UI
CInterfaceGui mainPanel;


// Define global pointer for coreEA to resolve extern in EventHandler.mqh
COneTradeEA_Core coreEA_instance;
COneTradeEA_Core *coreEA = &coreEA_instance;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Instantiate and initialize logical UI
   mainPanel.Create("Gui", 30, 30, 540);
   mainPanel.SetMode(InpTradeMode == ORDER_TYPE_BUY ? 0 : 1);
   mainPanel.SetLot(InpLotSize);
   mainPanel.SetSL(InpStopLoss);
   mainPanel.SetRepl(InpMaxReplacements);
   mainPanel.SetRisk(InpRiskValue);
   mainPanel.SetReward(InpRewardValue);
   mainPanel.SetOpenTime(InpOpenTime);
   mainPanel.SetCloseTime(InpCloseTime);
   mainPanel.SetTWStart(InpWindowStart);
   mainPanel.SetTWEnd(InpWindowEnd);
   mainPanel.ValidateInputs();

   // Create chart objects for all UI elements
   // Mode input (Buy/Sell)
   ObjectCreate(0, "ModeInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "ModeInput", OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0, "ModeInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "ModeInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "ModeInput", OBJPROP_TEXT, (InpTradeMode == ORDER_TYPE_BUY ? "Buy" : "Sell"));

   // Lot input
   ObjectCreate(0, "LotInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "LotInput", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, "LotInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "LotInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "LotInput", OBJPROP_TEXT, DoubleToString(InpLotSize,2));

   // SL input
   ObjectCreate(0, "SLInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "SLInput", OBJPROP_XDISTANCE, 210);
   ObjectSetInteger(0, "SLInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "SLInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "SLInput", OBJPROP_TEXT, IntegerToString(InpStopLoss));

   // RR input
   ObjectCreate(0, "RRInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "RRInput", OBJPROP_XDISTANCE, 300);
   ObjectSetInteger(0, "RRInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "RRInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "RRInput", OBJPROP_TEXT, DoubleToString(InpRiskValue,2));

   // Open time input
   ObjectCreate(0, "OpenTimeInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "OpenTimeInput", OBJPROP_XDISTANCE, 390);
   ObjectSetInteger(0, "OpenTimeInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "OpenTimeInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "OpenTimeInput", OBJPROP_TEXT, InpOpenTime);

   // Close time input
   ObjectCreate(0, "CloseTimeInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "CloseTimeInput", OBJPROP_XDISTANCE, 480);
   ObjectSetInteger(0, "CloseTimeInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "CloseTimeInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "CloseTimeInput", OBJPROP_TEXT, InpCloseTime);

   // Replace input
   ObjectCreate(0, "ReplaceInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "ReplaceInput", OBJPROP_XDISTANCE, 570);
   ObjectSetInteger(0, "ReplaceInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "ReplaceInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "ReplaceInput", OBJPROP_TEXT, IntegerToString(InpMaxReplacements));

   // Time window input
   ObjectCreate(0, "TimeWindowInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "TimeWindowInput", OBJPROP_XDISTANCE, 660);
   ObjectSetInteger(0, "TimeWindowInput", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "TimeWindowInput", OBJPROP_WIDTH, 80);
   ObjectSetString(0, "TimeWindowInput", OBJPROP_TEXT, InpWindowStart);

   // Start EA button
   ObjectCreate(0, "StartEAButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "StartEAButton", OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0, "StartEAButton", OBJPROP_YDISTANCE, 70);
   ObjectSetInteger(0, "StartEAButton", OBJPROP_WIDTH, 120);
   ObjectSetString(0, "StartEAButton", OBJPROP_TEXT, "Start EA");

   // Replace order button
   ObjectCreate(0, "ReplaceOrderButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "ReplaceOrderButton", OBJPROP_XDISTANCE, 160);
   ObjectSetInteger(0, "ReplaceOrderButton", OBJPROP_YDISTANCE, 70);
   ObjectSetInteger(0, "ReplaceOrderButton", OBJPROP_WIDTH, 120);
   ObjectSetString(0, "ReplaceOrderButton", OBJPROP_TEXT, "Replace Order");

   // Status label
   ObjectCreate(0, "StatusLabel", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "StatusLabel", OBJPROP_XDISTANCE, 300);
   ObjectSetInteger(0, "StatusLabel", OBJPROP_YDISTANCE, 70);
   ObjectSetInteger(0, "StatusLabel", OBJPROP_WIDTH, 440);
   ObjectSetString(0, "StatusLabel", OBJPROP_TEXT, mainPanel.GetStatus());

   // Reset button
   ObjectCreate(0, "ResetButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "ResetButton", OBJPROP_XDISTANCE, 180);
   ObjectSetInteger(0, "ResetButton", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "ResetButton", OBJPROP_WIDTH, 120);
   ObjectSetString(0, "ResetButton", OBJPROP_TEXT, "Reset");

   ChartRedraw(0);
   logger.Log("Initialized. Magic: " + Symbol() + "_OneTradeEA");
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   string status = "OneTradeEA Running\n";
   status += "Mode: " + (mainPanel.GetMode()==0?"BUY":"SELL") + "\n";
   status += "Lot: " + DoubleToString(mainPanel.GetLot(),2) + "\n";
   status += "SL: " + IntegerToString(mainPanel.GetSL()) + "\n";
   status += "Risk: " + DoubleToString(mainPanel.GetRisk(),2) + "\n";
   status += "Reward: " + DoubleToString(mainPanel.GetReward(),2) + "\n";
   status += "Open: " + mainPanel.GetOpenTime() + "\n";
   status += "Close: " + mainPanel.GetCloseTime() + "\n";
   status += "Repl left: " + IntegerToString(mainPanel.GetRepl());
   Comment(status);
   // Call core EA trade monitoring
   coreEA.MonitorTrades();
   // --- Handle daily reset and open/close times ---
   static int lastDay = -1;
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   if(dt.day != lastDay) {
      lastDay = dt.day;
      coreEA.OnNewDay();
   }
   // Open first trade at opening time
   if(TimeToStr(TimeCurrent(), 0) == InpOpenTime)
      coreEA.OpenFirstTrade();
   // Close all at closing time
   if(TimeToStr(TimeCurrent(), 0) == InpCloseTime)
      coreEA.OnCloseTime();
  }
// Unlock input fields on EA deinitialization (call from OnDeinit in main EA)
void UnlockInputFields()
{
   ObjectSetInteger(0, OBJ_MODE_INPUT, OBJPROP_READONLY, false);
   ObjectSetInteger(0, OBJ_LOT_INPUT, OBJPROP_READONLY, false);
   ObjectSetInteger(0, OBJ_SL_INPUT, OBJPROP_READONLY, false);
   ObjectSetInteger(0, OBJ_RR_INPUT, OBJPROP_READONLY, false);
   ObjectSetInteger(0, OBJ_OPEN_TIME_INPUT, OBJPROP_READONLY, false);
   ObjectSetInteger(0, OBJ_CLOSE_TIME_INPUT, OBJPROP_READONLY, false);
   ObjectSetInteger(0, OBJ_REPLACE_INPUT, OBJPROP_READONLY, false);
   ObjectSetInteger(0, OBJ_TIME_WINDOW_INPUT, OBJPROP_READONLY, false);
   mainPanel.Create("Gui", 30, 30, 540);
   mainPanel.ValidateInputs();
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Cleanup panel UI
   mainPanel.Delete();
   // Unlock input fields for next use
   UnlockInputFields();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Chart event handler: wire up UI events to EventHandler.mqh      |
//+------------------------------------------------------------------+
// OnChartEvent is handled via EventHandler.mqh
//+------------------------------------------------------------------+
//| Helper: Parse time string (HH:MM) to datetime (today)           |
//+------------------------------------------------------------------+
datetime ParseTime(string t)
  {
   if(t=="") return 0;
   int h = StringToInteger(StringSubstr(t,0,2));
   int m = StringToInteger(StringSubstr(t,3,2));
   datetime today = DateOfDay(TimeCurrent());
   return today + h*3600 + m*60;
  }

//+------------------------------------------------------------------+
//| Helper: Check if now is within the time window                   |
//+------------------------------------------------------------------+
// ...existing code...

//+------------------------------------------------------------------+
//| (Placeholder) Handle trade monitoring, SL/TP, replacements       |
//+------------------------------------------------------------------+
// Implement trade monitoring, SL/TP hit detection, replacement logic, CSV logging, and graphical/chart features as needed.
// See README and One_Trade_EA_Event_Charts.md for full requirements.
//+------------------------------------------------------------------+
