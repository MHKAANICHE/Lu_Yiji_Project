//+------------------------------------------------------------------+
//| Trade transaction event handler for SL detection                |
//+------------------------------------------------------------------+
#ifndef DEAL_TYPE_SL
#define DEAL_TYPE_SL 2
#endif
#ifndef DEAL_TYPE_TP
#define DEAL_TYPE_TP 3
#endif

void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
   Print("[OneTradeEA][DEBUG] OnTradeTransaction called: trans.type=", trans.type, " deal_type=", trans.deal_type, " symbol=", trans.symbol, " price=", trans.price, " volume=", trans.volume);
   ulong deal_ticket_dbg = trans.deal;
   string deal_comment_dbg = "";
   if(deal_ticket_dbg > 0) deal_comment_dbg = HistoryDealGetString(deal_ticket_dbg, DEAL_COMMENT);
   Print("[OneTradeEA][DEBUG] Deal ticket=", deal_ticket_dbg, " comment=", deal_comment_dbg);
{
   // Only interested in deals (not orders, not position changes)
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      ulong deal_ticket = trans.deal;
      long deal_type = trans.deal_type;
      string deal_symbol = trans.symbol;
      double deal_price = trans.price;
      datetime deal_time = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
      double deal_volume = trans.volume;
      // Only process for our symbol
      if(deal_symbol == Symbol())
      {
         // Get comment from history (to match EA trades)
         string deal_comment = HistoryDealGetString(deal_ticket, DEAL_COMMENT);
         // Only process if comment matches our EA's format
         bool isOurTrade = (StringFind(deal_comment, "ORIGINAL_") == 0 || StringFind(deal_comment, "REPLACEMENT_") == 0);
         if(!isOurTrade) return;
         // SL hit
         if(deal_type == DEAL_TYPE_SL)
         {
            string vline_name = "SL_HIT_" + IntegerToString(deal_ticket) + "_" + TimeToString(deal_time, TIME_SECONDS);
            ObjectCreate(0, vline_name, OBJ_VLINE, 0, deal_time, 0);
            ObjectSetInteger(0, vline_name, OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0, vline_name, OBJPROP_WIDTH, 2);
            Print("[OneTradeEA][DEBUG] SL detected by OnTradeTransaction. Vertical line drawn at ", TimeToString(deal_time, TIME_SECONDS), " for ticket ", deal_ticket);
            // Log SL event
            coreEA.LogCSV(TimeToString(deal_time, TIME_DATE), TimeToString(deal_time, TIME_SECONDS), deal_symbol, (InpTradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), deal_volume, 0, 0, "SL", 0, "", deal_ticket);
            // Replacement logic: only if allowed and no pending order exists
            if(coreEA.HasPendingOrder()) return;
            // Decrement score if possible (parse from comment)
            int score = 0;
            if(StringFind(deal_comment, "ORIGINAL_") == 0)
               score = StringToInteger(StringSubstr(deal_comment, 9));
            else if(StringFind(deal_comment, "REPLACEMENT_") == 0)
               score = StringToInteger(StringSubstr(deal_comment, 12));
            if(score > 0)
            {
               Print("[OneTradeEA][DEBUG] Placing replacement pending order after SL. score=", score-1);
               // Set up currentTrade for replacement
               coreEA.currentTrade.score = score-1;
               coreEA.currentTrade.comment = "REPLACEMENT_" + IntegerToString(score-1);
               // Place the replacement pending order at the SL price of the closed position
               coreEA.currentTrade.entryPrice = deal_price; // SL price where position was closed
               coreEA.currentTrade.sl = deal_price;         // Set SL for the new pending order to the same SL price
               coreEA.pendingOrderActive = true;
               Print("[OneTradeEA][DEBUG] Calling OpenPendingOrder with entry=", coreEA.currentTrade.entryPrice, " sl=", coreEA.currentTrade.sl);
               coreEA.OpenPendingOrder(coreEA.currentTrade.entryPrice, coreEA.currentTrade.sl);
               Print("[OneTradeEA][DEBUG] OpenPendingOrder call finished");
            }
         }
         // TP hit
         else if(deal_type == DEAL_TYPE_TP)
         {
            string vline_name = "TP_HIT_" + IntegerToString(deal_ticket) + "_" + TimeToString(deal_time, TIME_SECONDS);
            ObjectCreate(0, vline_name, OBJ_VLINE, 0, deal_time, 0);
            ObjectSetInteger(0, vline_name, OBJPROP_COLOR, clrGreen);
            ObjectSetInteger(0, vline_name, OBJPROP_WIDTH, 2);
            Print("[OneTradeEA][DEBUG] TP detected by OnTradeTransaction. Vertical line drawn at ", TimeToString(deal_time, TIME_SECONDS), " for ticket ", deal_ticket);
            // Log TP event
            coreEA.LogCSV(TimeToString(deal_time, TIME_DATE), TimeToString(deal_time, TIME_SECONDS), deal_symbol, (InpTradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), deal_volume, 0, 0, "TP", 0, "", deal_ticket);
         }
      }
   }
}
//| One Trade EA for MetaTrader 5                                    |
//| Implements the strategy as described in the project README       |
//+------------------------------------------------------------------+

#property copyright "Lu_Yiji_Project"
#property version   "1.00"
#property strict


#include <Trade/Trade.mqh>
#include <Trade/OrderInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/DealInfo.mqh>
#include <Trade/HistoryOrderInfo.mqh>
#include <OneTradeEA_Core.mqh>

#include <stdlib.mqh>

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
// Global instance of core EA logic
COneTradeEA_Core coreEA;

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
input double            InpSLDistance = 20.00;         // Stop Loss Distance (in price units, e.g. $20 for BTCUSD, 20 points for XAUUSD)
input double            InpRewardValue = 2.00;         // Risk:Reward Ratio (e.g., 2 for 1:2)
input string            InpOpenTime  = "09:00:00";     // Opening Time (HH:MM:SS)
input string            InpCloseTime = "17:00:00";     // Closing Time (HH:MM:SS)
input int               InpMaxReplacements = 2;        // Max Replacements
input string            InpWindowStart = "";           // Time Window Start (HH:MM:SS, empty=off)
input string            InpWindowEnd   = "";           // Time Window End (HH:MM:SS, empty=off)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Validate lot size
   double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   if(InpLotSize < minLot || InpLotSize > maxLot || fmod(InpLotSize - minLot, lotStep) > 1e-8)
   {
      Print("ERROR: Lot size ", InpLotSize, " is invalid. Allowed: [", minLot, " - ", maxLot, "] step ", lotStep);
      return(INIT_FAILED);
   }
   // Initialize core EA logic
   // InpSLDistance is now the stop loss distance in price units (not dollar risk)
   coreEA.Init(InpTradeMode, InpLotSize, InpSLDistance, InpRewardValue, InpOpenTime, InpCloseTime, InpMaxReplacements, InpWindowStart, InpWindowEnd, Symbol());
   Print("Initialized. Magic: " + Symbol() + "_OneTradeEA");
   extern bool firstTradeOpened = false; // Ensure flag is reset on EA start
   firstTradeOpened = false;
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   // Call core EA trade monitoring
   coreEA.MonitorTrades();
   // --- Handle daily reset and open/close times ---
   // Removed daily restriction: allow new trade at opening time whenever there is no active or pending trade
   // Only open the first trade automatically if there has never been a trade (e.g. at EA start)
   extern bool firstTradeOpened;
   if(!firstTradeOpened && !coreEA.IsTradeActive() && !coreEA.HasPendingOrder())
   {
      coreEA.OpenFirstTrade();
      firstTradeOpened = true;
   }
   // Close all at closing time
   if(TimeToStr(TimeCurrent(), 0) == InpCloseTime)
   {
      coreEA.OnCloseTime();
      firstTradeOpened = false; // Allow new first trade after daily close
   }
  }

void OnDeinit(const int reason)
  {
   // No graphical cleanup needed
  }

//+------------------------------------------------------------------+
//| Helper: Parse time string (HH:MM) to datetime (today)           |
//+------------------------------------------------------------------+
datetime ParseTime(string t)
  {
   if(t=="") return 0;
   if(StringLen(t) != 8 || StringSubstr(t,2,1) != ":" || StringSubstr(t,5,1) != ":") {
      Print("ERROR: Time string '", t, "' is not in HH:MM:SS format.");
      return 0;
   }
   long h = StringToInteger(StringSubstr(t,0,2));
   long m = StringToInteger(StringSubstr(t,3,2));
   long s = StringToInteger(StringSubstr(t,6,2));
   if(h < 0 || h > 23 || m < 0 || m > 59 || s < 0 || s > 59) {
      Print("ERROR: Time string '", t, "' has invalid values.");
      return 0;
   }
   datetime today = DateOfDay(TimeCurrent());
   return today + (datetime)(h*3600 + m*60 + s);
  }

//+------------------------------------------------------------------+
//| Helper: Check if now is within the time window                   |
//+------------------------------------------------------------------+
// Implement IsInTimeWindow logic in TimeManager or COneTradeEA_Core if needed
//+------------------------------------------------------------------+
//| (Placeholder) Handle trade monitoring, SL/TP, replacements       |
//+------------------------------------------------------------------+
// Implement trade monitoring, SL/TP hit detection, replacement logic, CSV logging, as needed
//+------------------------------------------------------------------+
