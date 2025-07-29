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
   // Input validation
   if(InpLotSize <= 0)
     {
      logger.Log("ERROR: Lot size must be positive.");
      return(INIT_FAILED);
     }
   if(InpStopLoss < 0)
     {
      logger.Log("ERROR: Stop Loss must be non-negative.");
      return(INIT_FAILED);
     }
   if(InpRiskValue <= 0 || InpRewardValue <= 0)
     {
      logger.Log("ERROR: Risk and Reward values must be positive.");
      return(INIT_FAILED);
     }
   if(StringLen(InpOpenTime) != 5 || StringSubstr(InpOpenTime,2,1) != ":")
     {
      logger.Log("ERROR: Invalid Open Time format. Use HH:MM.");
      return(INIT_FAILED);
     }
   if(StringLen(InpCloseTime) != 5 || StringSubstr(InpCloseTime,2,1) != ":")
     {
      logger.Log("ERROR: Invalid Close Time format. Use HH:MM.");
      return(INIT_FAILED);
     }
   if(InpMaxReplacements < 0)
     {
      logger.Log("ERROR: Max Replacements must be non-negative.");
      return(INIT_FAILED);
     }
   // Optional window times
   if(InpWindowStart != "" && (StringLen(InpWindowStart) != 5 || StringSubstr(InpWindowStart,2,1) != ":"))
     {
      logger.Log("ERROR: Invalid Window Start format. Use HH:MM or leave empty.");
      return(INIT_FAILED);
     }
   if(InpWindowEnd != "" && (StringLen(InpWindowEnd) != 5 || StringSubstr(InpWindowEnd,2,1) != ":"))
     {
      logger.Log("ERROR: Invalid Window End format. Use HH:MM or leave empty.");
      return(INIT_FAILED);
     }
   // Initialize core EA logic
   coreEA.Init(
      InpTradeMode,
      InpLotSize,
      InpStopLoss,
      InpRiskValue,
      InpRewardValue,
      InpOpenTime,
      InpCloseTime,
      InpMaxReplacements,
      InpWindowStart,
      InpWindowEnd,
      Symbol()
   );
   // --- Create minimal UI elements on chart ---
   int x0 = 30, y0 = 30, w = 120, h = 20, pad = 5;
   // Mode input (Buy/Sell)
   ObjectCreate(0, "ModeInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "ModeInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "ModeInput", OBJPROP_YDISTANCE, y0);
   ObjectSetInteger(0, "ModeInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "ModeInput", OBJPROP_TEXT, (InpTradeMode==ORDER_TYPE_BUY?"Buy":"Sell"));

   // Lot size
   ObjectCreate(0, "LotInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "LotInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "LotInput", OBJPROP_YDISTANCE, y0+h+pad);
   ObjectSetInteger(0, "LotInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "LotInput", OBJPROP_TEXT, DoubleToString(InpLotSize,2));

   // Stop Loss
   ObjectCreate(0, "SLInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "SLInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "SLInput", OBJPROP_YDISTANCE, y0+2*(h+pad));
   ObjectSetInteger(0, "SLInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "SLInput", OBJPROP_TEXT, IntegerToString(InpStopLoss));

   // Risk
   ObjectCreate(0, "RRInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "RRInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "RRInput", OBJPROP_YDISTANCE, y0+3*(h+pad));
   ObjectSetInteger(0, "RRInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "RRInput", OBJPROP_TEXT, DoubleToString(InpRiskValue,2));

   // Reward
   ObjectCreate(0, "RewardInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "RewardInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "RewardInput", OBJPROP_YDISTANCE, y0+4*(h+pad));
   ObjectSetInteger(0, "RewardInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "RewardInput", OBJPROP_TEXT, DoubleToString(InpRewardValue,2));

   // Opening Time
   ObjectCreate(0, "OpenTimeInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "OpenTimeInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "OpenTimeInput", OBJPROP_YDISTANCE, y0+5*(h+pad));
   ObjectSetInteger(0, "OpenTimeInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "OpenTimeInput", OBJPROP_TEXT, InpOpenTime);

   // Closing Time
   ObjectCreate(0, "CloseTimeInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "CloseTimeInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "CloseTimeInput", OBJPROP_YDISTANCE, y0+6*(h+pad));
   ObjectSetInteger(0, "CloseTimeInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "CloseTimeInput", OBJPROP_TEXT, InpCloseTime);

   // Max Replacements
   ObjectCreate(0, "ReplaceInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "ReplaceInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "ReplaceInput", OBJPROP_YDISTANCE, y0+7*(h+pad));
   ObjectSetInteger(0, "ReplaceInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "ReplaceInput", OBJPROP_TEXT, IntegerToString(InpMaxReplacements));

   // Time Window
   ObjectCreate(0, "TimeWindowInput", OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, "TimeWindowInput", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "TimeWindowInput", OBJPROP_YDISTANCE, y0+8*(h+pad));
   ObjectSetInteger(0, "TimeWindowInput", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "TimeWindowInput", OBJPROP_TEXT, InpWindowStart);

   // Start EA Button
   ObjectCreate(0, "StartEAButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "StartEAButton", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "StartEAButton", OBJPROP_YDISTANCE, y0+9*(h+pad));
   ObjectSetInteger(0, "StartEAButton", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "StartEAButton", OBJPROP_TEXT, "Start EA");

   // Replace Order Button
   ObjectCreate(0, "ReplaceOrderButton", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "ReplaceOrderButton", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "ReplaceOrderButton", OBJPROP_YDISTANCE, y0+10*(h+pad));
   ObjectSetInteger(0, "ReplaceOrderButton", OBJPROP_WIDTH, (long)w);
   ObjectSetString(0, "ReplaceOrderButton", OBJPROP_TEXT, "Replace Order");

   // Status Label
   ObjectCreate(0, "StatusLabel", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "StatusLabel", OBJPROP_XDISTANCE, x0);
   ObjectSetInteger(0, "StatusLabel", OBJPROP_YDISTANCE, y0+11*(h+pad));
   ObjectSetInteger(0, "StatusLabel", OBJPROP_WIDTH, (long)(w*2));
   ObjectSetString(0, "StatusLabel", OBJPROP_TEXT, "Ready");

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

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Cleanup panel UI
   mainPanel.Delete();
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
