//+------------------------------------------------------------------+
//| One Trade EA for MetaTrader 5                                    |
//| Implements the strategy as described in the project README       |
//+------------------------------------------------------------------+

#property copyright "Lu_Yiji_Project"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <OneTradeEA_Core.mqh>

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
input double            InpRiskValue = 1.00;           // Risk Amount ($) - The maximum dollar amount you are willing to risk per trade
input double            InpRewardValue = 2.00;         // Risk:Reward Ratio (e.g., 2 for 1:2)
input string            InpOpenTime  = "09:00:00";     // Opening Time (HH:MM:SS)
input string            InpCloseTime = "17:00:00";     // Closing Time (HH:MM:SS)
input int               InpMaxReplacements = 2;        // Max Replacements
input string            InpWindowStart = "";           // Time Window Start (HH:MM:SS, empty=off)
input string            InpWindowEnd   = "";           // Time Window End (HH:MM:SS, empty=off)

// Define global object for coreEA
COneTradeEA_Core coreEA_instance;
#define coreEA coreEA_instance

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
   // Note: InpRiskValue is now the dollar risk, InpStopLoss removed
   coreEA.Init(InpTradeMode, InpLotSize, InpRiskValue, InpRewardValue, InpOpenTime, InpCloseTime, InpMaxReplacements, InpWindowStart, InpWindowEnd, Symbol());
   Print("Initialized. Magic: " + Symbol() + "_OneTradeEA");
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   // Call core EA trade monitoring
   coreEA.MonitorTrades();
   // --- Handle daily reset and open/close times ---
   static int lastDay = -1;
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   if(dt.day != lastDay) {
      lastDay = dt.day;
      coreEA.OnNewDay();
   }
   // Open first trade at opening time (use full HH:MM:SS comparison)
   string nowStr = TimeToStr(TimeCurrent(), 1); // HH:MM:SS
   // Only open a new market order if there is no active trade and no pending order
   if(nowStr == InpOpenTime && !coreEA.IsTradeActive() && !coreEA.HasPendingOrder())
   {
      coreEA.OpenFirstTrade();
   }
   // Close all at closing time
   if(TimeToStr(TimeCurrent(), 0) == InpCloseTime)
      coreEA.OnCloseTime();
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
   return today + h*3600 + m*60 + s;
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
