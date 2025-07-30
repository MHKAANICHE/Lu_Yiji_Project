// --- Helper: Check if now is within the replacement time window ---
bool IsInReplacementWindow() {
   int winStart = ParseTimeToSeconds(InpWindowStart);
   int winEnd = ParseTimeToSeconds(InpWindowEnd);
   if(winStart < 0 || winEnd < 0) return false; // window not enabled
   int nowSec = NowSeconds();
   if(winStart <= winEnd)
      return (nowSec >= winStart && nowSec <= winEnd);
   else // window spans midnight
      return (nowSec >= winStart || nowSec <= winEnd);
}
// --- Helper: Close all open trades for this EA and symbol ---
void CloseAllPositions() {
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() <= OP_SELL) {
            bool closed = OrderClose(OrderTicket(), OrderLots(), (OrderType()==OP_BUY ? Bid : Ask), Slippage, clrRed);
            if(!closed) Print("[OneTradeFlagEA] OrderClose failed: ", GetLastError());
         }
      }
   }
}

// --- Helper: Delete all pending orders for this EA and symbol ---
void DeleteAllPendingOrders() {
   for(int i=OrdersTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP)) {
            bool deleted = OrderDelete(OrderTicket());
            if(!deleted) Print("[OneTradeFlagEA] OrderDelete failed: ", GetLastError());
         }
      }
   }
}

// --- Helper: Parse time string (HH:MM:SS) to seconds since midnight ---
int ParseTimeToSeconds(string t) {
   if(StringLen(t) < 5) return -1;
   int h = StrToInteger(StringSubstr(t,0,2));
   int m = StrToInteger(StringSubstr(t,3,2));
   int s = 0;
   if(StringLen(t) >= 8) s = StrToInteger(StringSubstr(t,6,2));
   return h*3600 + m*60 + s;
}

// --- Trade and Order Helpers ---
int NowSeconds() {
   datetime now = Time[0];
   int h = TimeHour(now);
   int m = TimeMinute(now);
   int s = TimeSeconds(now);
   return h*3600 + m*60 + s;
}

// --- Helper: Get today's date at 00:00 ---
datetime DateOfDay(datetime t) {
   return t - (t % 86400);
}

// --- Daily trade tracking ---
datetime lastTradeDay = 0;
bool firstTradeOpenedToday = false;
// OneTradeFlagEA.mq4
// MQL4 Expert Advisor implementing the flag-driven order circulation logic with replacement score
// Logic based on OrderFlags_TechnicalDoc.md

#property copyright "GitHub Copilot"
#property version   "1.00"
#property strict


//--- Input parameters (copied from MT5 version)
extern int    InpTradeMode      = 0;           // 0=Buy, 1=Sell
extern double InpLotSize        = 0.10;        // Lot Size
extern double InpSLDistance     = 20.00;       // Stop Loss Distance (in price units)
extern double InpRewardValue    = 2.00;        // Risk:Reward Ratio (e.g., 2 for 1:2)
extern string InpOpenTime       = "09:00:00";  // Opening Time (HH:MM:SS)
extern string InpCloseTime      = "17:00:00";  // Closing Time (HH:MM:SS)
extern int    InpMaxReplacements= 2;           // Max Replacements
extern string InpWindowStart    = "";          // Time Window Start (HH:MM:SS, optional)
extern string InpWindowEnd      = "";          // Time Window End (HH:MM:SS, optional)

extern int    Slippage          = 5;
extern int    Magic             = 12345;

//--- ENUM_ORDER_TYPE for MQL4 (0=Buy, 1=Sell)
#define ORDER_TYPE_BUY  0
#define ORDER_TYPE_SELL 1

// --- Global variables for flag and state management ---
bool flagPlaceFirstEntry = true;
bool flagPlaceReplacement = false;
int replacementScore = 0;
int replacementScoreMax = 0;
double firstEntryPrice = 0;
double firstEntrySL = 0;
double firstEntryTP = 0;
double firstEntryLot = 0;
int openTicket = -1;

// --- Helper: Get pip size for symbol ---

// --- CSV Logging ---
// --- Helper: Get the starting month of the backtest (first trade day or current month) ---
string GetMonthString() {
   datetime now = Time[0];
   int year = TimeYear(now);
   int month = TimeMonth(now);
   string monthStr = IntegerToString(month);
   if(month < 10) monthStr = "0" + monthStr;
   return IntegerToString(year) + "-" + monthStr;
}

// --- Helper: Generate a random number for the filename ---
int GetRandomNumber() {
   // Use seconds as a simple random seed (not cryptographically secure)
   return (int)TimeSeconds(Time[0]) + (int)MathRand();
}

string GetLogFileName() {
   string sym = Symbol();
   string month = GetMonthString();
   int randNum = GetRandomNumber();
   return sym + "_" + month + "_random" + IntegerToString(randNum) + ".csv";
}

void LogTradeEvent(string eventType, int ticket, double price, double lots, double sl, double tp, double profit, string reason) {
   string file = GetLogFileName();
   int handle = FileOpen(file, FILE_CSV|FILE_READ|FILE_WRITE, ";");
   if(handle < 0) {
      Print("[OneTradeFlagEA] Log file open failed: ", GetLastError());
      return;
   }
   if(FileSize(handle) == 0) {
      FileWrite(handle, "Event", "Ticket", "Time", "Price", "Lots", "SL", "TP", "Profit", "Reason");
   }
   string tstr = TimeToStr(Time[0], TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   FileWrite(handle, eventType, ticket, tstr, DoubleToStr(price, Digits), DoubleToStr(lots, 2), DoubleToStr(sl, Digits), DoubleToStr(tp, Digits), DoubleToStr(profit, 2), reason);
   FileClose(handle);
}

// --- Helper: Get pip size for symbol ---
double GetPipSize() {
   int digits = MarketInfo(Symbol(), MODE_DIGITS);
   if(digits == 3 || digits == 5) return 0.00010;
   if(digits == 2 || digits == 4) return 0.01;
   return MarketInfo(Symbol(), MODE_POINT);
}

// --- Helper: Get stop loss distance in price units (InpSLDistance logic) ---
double GetSLDistancePrice() {
   return InpSLDistance;
}

// --- Reset all state to initial ---
void ResetEA() {
   flagPlaceFirstEntry = true;
   flagPlaceReplacement = false;
   replacementScoreMax = InpMaxReplacements;
   replacementScore = replacementScoreMax;
   firstEntryPrice = 0;
   firstEntrySL = 0;
   firstEntryTP = 0;
   firstEntryLot = 0;
   openTicket = -1;
}

// --- Check for active position for this EA and symbol ---
bool HasActivePosition() {
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() <= OP_SELL) {
            openTicket = OrderTicket();
            return true;
         }
      }
   }
   openTicket = -1;
   return false;
}

// --- Place the first entry order ---
bool PlaceFirstEntryOrder() {
   double price = (InpTradeMode == ORDER_TYPE_BUY) ? Ask : Bid;
   double sl_distance = GetSLDistancePrice();
   int digits = MarketInfo(Symbol(), MODE_DIGITS);
   double sl = 0, tp = 0, tp_distance = 0;
   if (InpTradeMode == ORDER_TYPE_BUY) {
      sl = price - sl_distance;
      if (InpRewardValue > 0.0) {
         tp_distance = MathAbs(price - sl) * InpRewardValue;
         tp = price + tp_distance;
      } else {
         tp = 0;
      }
   } else {
      sl = price + sl_distance;
      if (InpRewardValue > 0.0) {
         tp_distance = MathAbs(price - sl) * InpRewardValue;
         tp = price - tp_distance;
      } else {
         tp = 0;
      }
   }
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * MarketInfo(Symbol(), MODE_POINT);
   sl = NormalizeDouble(sl, digits);
   if(tp != 0) tp = NormalizeDouble(tp, digits);
   price = NormalizeDouble(price, digits);
   // Check SL/TP distance for broker requirements
   if(InpTradeMode == ORDER_TYPE_BUY) {
      if(sl > 0 && (price - sl) < stopLevel) sl = 0;
      if(tp > 0 && (tp - price) < stopLevel) tp = 0;
   } else {
      if(sl > 0 && (sl - price) < stopLevel) sl = 0;
      if(tp > 0 && (price - tp) < stopLevel) tp = 0;
   }
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double lot = MathMax(NormalizeDouble(InpLotSize, 2), minLot);
   lot = MathFloor(lot / lotStep) * lotStep;
   lot = NormalizeDouble(lot, 2);
   int orderType = (InpTradeMode == ORDER_TYPE_BUY) ? OP_BUY : OP_SELL;
   int ticket = OrderSend(Symbol(), orderType, lot, price, Slippage, sl, tp, "FirstEntry", Magic, 0, clrBlue);
if(ticket > 0) {
   firstEntryPrice = price;
   firstEntrySL = sl;
   firstEntryTP = tp;
   firstEntryLot = lot;
   openTicket = ticket;
   LogTradeEvent("OPEN", ticket, price, lot, sl, tp, 0, "FirstEntry");
   return true;
} else {
   Print("[OneTradeFlagEA] OrderSend failed: ", GetLastError());
   LogTradeEvent("OPEN_FAIL", -1, price, lot, sl, tp, 0, "FirstEntry");
   return false;
}
}

// --- Place a replacement order using saved first entry params ---
bool PlaceReplacementOrder() {
   double price = firstEntryPrice;
   double sl_distance = GetSLDistancePrice();
   int digits = MarketInfo(Symbol(), MODE_DIGITS);
   double sl = 0, tp = 0, tp_distance = 0;
   if (InpTradeMode == ORDER_TYPE_BUY) {
      sl = price - sl_distance;
      if (InpRewardValue > 0.0) {
         tp_distance = MathAbs(price - sl) * InpRewardValue;
         tp = price + tp_distance;
      } else {
         tp = 0;
      }
   } else {
      sl = price + sl_distance;
      if (InpRewardValue > 0.0) {
         tp_distance = MathAbs(price - sl) * InpRewardValue;
         tp = price - tp_distance;
      } else {
         tp = 0;
      }
   }
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * MarketInfo(Symbol(), MODE_POINT);
   price = NormalizeDouble(price, digits);
   sl = NormalizeDouble(sl, digits);
   if(tp != 0) tp = NormalizeDouble(tp, digits);
   // Check SL/TP distance for broker requirements
   if(InpTradeMode == ORDER_TYPE_BUY) {
      if(sl > 0 && (price - sl) < stopLevel) sl = 0;
      if(tp > 0 && (tp - price) < stopLevel) tp = 0;
   } else {
      if(sl > 0 && (sl - price) < stopLevel) sl = 0;
      if(tp > 0 && (price - tp) < stopLevel) tp = 0;
   }
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double lot = MathMax(NormalizeDouble(firstEntryLot, 2), minLot);
   lot = MathFloor(lot / lotStep) * lotStep;
   lot = NormalizeDouble(lot, 2);
   int orderType = (InpTradeMode == ORDER_TYPE_BUY) ? OP_BUYSTOP : OP_SELLSTOP;
   int ticket = OrderSend(Symbol(), orderType, lot, price, Slippage, sl, tp, "Replacement", Magic, 0, clrRed);
if(ticket > 0) {
   openTicket = ticket;
   LogTradeEvent("REPLACEMENT", ticket, price, lot, sl, tp, 0, "Replacement");
   return true;
} else {
   Print("[OneTradeFlagEA] Replacement Pending OrderSend failed: ", GetLastError());
   LogTradeEvent("REPLACEMENT_FAIL", -1, price, lot, sl, tp, 0, "Replacement");
   return false;
}
}

// --- Detect if position closed by TP or SL ---
string DetectCloseReason(int closedTicket) {
   if(OrderSelect(closedTicket, SELECT_BY_TICKET, MODE_HISTORY)) {
      double closePrice = OrderClosePrice();
      double entry = OrderOpenPrice();
      double sl = OrderStopLoss();
      double tp = OrderTakeProfit();
      if(MathAbs(closePrice - tp) < GetPipSize()*2) return "TP";
      if(MathAbs(closePrice - sl) < GetPipSize()*2) return "SL";
   }
   return "OTHER";
}

// --- Main logic loop ---
void LogicLoop() {
   // Only one of the flags should ever be true at a time
   if(flagPlaceFirstEntry && !HasActivePosition()) {
      if(PlaceFirstEntryOrder()) {
         flagPlaceFirstEntry = false;
         flagPlaceReplacement = false;
      }
   } else if(flagPlaceReplacement && !HasActivePosition()) {
      // Only place replacement if not in the replacement window
      if(!IsInReplacementWindow()) {
         if(PlaceReplacementOrder()) {
            flagPlaceFirstEntry = false;
            flagPlaceReplacement = false;
         }
      } else {
         // Skip replacement during window
         Print("[OneTradeFlagEA] Replacement skipped due to time window.");
      }
   }
}

// --- Check for closed position and handle logic ---
void CheckClosedPosition() {
   static int lastClosedTicket = -1;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() <= OP_SELL) {
            int closedTicket = OrderTicket();
            if(closedTicket != lastClosedTicket) {
               string reason = DetectCloseReason(closedTicket);
               double profit = OrderProfit() + OrderSwap() + OrderCommission();
               LogTradeEvent("CLOSE", closedTicket, OrderClosePrice(), OrderLots(), OrderStopLoss(), OrderTakeProfit(), profit, reason);
               if(reason == "TP" || replacementScore == 0) {
                  ResetEA();
               } else if(reason == "SL") {
                  if(replacementScore > 0) {
                     flagPlaceFirstEntry = false;
                     flagPlaceReplacement = true;
                     replacementScore--;
                  } else {
                     ResetEA();
                  }
               }
               lastClosedTicket = closedTicket;
            }
            break;
         }
      }
   }
}

// --- EA entry points ---
int init() {
   replacementScoreMax = InpMaxReplacements;
   replacementScore = replacementScoreMax;
   // Only allow first entry if within allowed open window
   int nowSec = NowSeconds();
   int openSec = ParseTimeToSeconds(InpOpenTime);
   int closeSec = ParseTimeToSeconds(InpCloseTime);
   if(openSec < 0 || closeSec < 0) {
      Print("[OneTradeFlagEA] Invalid InpOpenTime or InpCloseTime in init: ", InpOpenTime, " / ", InpCloseTime);
      flagPlaceFirstEntry = false;
      flagPlaceReplacement = false;
   } else if(nowSec >= openSec && nowSec < closeSec) {
      ResetEA();
   } else {
      // Not in allowed window, do not allow first entry
      flagPlaceFirstEntry = false;
      flagPlaceReplacement = false;
      replacementScoreMax = InpMaxReplacements;
      replacementScore = replacementScoreMax;
      firstEntryPrice = 0;
      firstEntrySL = 0;
      firstEntryTP = 0;
      firstEntryLot = 0;
      openTicket = -1;
   }
   return(0);
}

int start() {
   int nowSec = NowSeconds();
   int closeSec = ParseTimeToSeconds(InpCloseTime);

   // At closing time, close all positions and delete pending orders (always enforced)
   if(closeSec >= 0 && nowSec >= closeSec) {
      CloseAllPositions();
      DeleteAllPendingOrders();
      // Reset daily state for next day
      flagPlaceFirstEntry = false;
      flagPlaceReplacement = false;
      firstTradeOpenedToday = false;
      openTicket = -1;
      firstEntryPrice = 0;
      firstEntrySL = 0;
      firstEntryTP = 0;
      firstEntryLot = 0;
      return(0);
   }
   datetime today = DateOfDay(Time[0]);
   int openSec = ParseTimeToSeconds(InpOpenTime);

   // Check for invalid open time
   if(openSec < 0) {
      Print("[OneTradeFlagEA] Invalid InpOpenTime: ", InpOpenTime);
      return(0); // Do nothing if open time is invalid
   }

   // Reset daily state if new day
   if(today != lastTradeDay) {
      firstTradeOpenedToday = false;
      lastTradeDay = today;
      // Reset all EA state for new run, but only allow first entry if nowSec >= openSec
      firstEntryPrice = 0;
      firstEntrySL = 0;
      firstEntryTP = 0;
      firstEntryLot = 0;
      openTicket = -1;
      flagPlaceReplacement = false;
      if(nowSec >= openSec && nowSec < closeSec) {
         flagPlaceFirstEntry = true;
      } else {
         flagPlaceFirstEntry = false;
      }
      replacementScoreMax = InpMaxReplacements;
      replacementScore = replacementScoreMax;
   }

   if(!firstTradeOpenedToday && nowSec >= openSec && nowSec < closeSec && !HasActivePosition()) {
      // Only open first trade at or after opening time, once per day
      // Reset entry state to ensure a fresh first entry
      firstEntryPrice = 0;
      firstEntrySL = 0;
      firstEntryTP = 0;
      firstEntryLot = 0;
      openTicket = -1;
      flagPlaceFirstEntry = true;
      flagPlaceReplacement = false;
      // Only place first entry if no active position and not in replacement mode
      if(flagPlaceFirstEntry && !flagPlaceReplacement && !HasActivePosition()) {
         if(PlaceFirstEntryOrder()) {
            flagPlaceFirstEntry = false;
            flagPlaceReplacement = false;
            firstTradeOpenedToday = true;
         }
      }
      return(0);
   }

   if(HasActivePosition()) {
      // Wait for position to close
      return(0);
   } else {
      CheckClosedPosition();
      LogicLoop();
   }
   return(0);
}

int deinit() {
   return(0);
}

