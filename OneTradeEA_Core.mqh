//+------------------------------------------------------------------+
//| OneTradeEA_Core.mqh                                              |
//| Implements the core logic for One Trade EA as per requirements   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OneTradeEA_Core.mqh                                              |
//| Implements the core logic for One Trade EA as per requirements   |
//+------------------------------------------------------------------+

#ifndef __ONETRADEEA_CORE_MQH__
#define __ONETRADEEA_CORE_MQH__

#include <Trade/Trade.mqh>
#include <Trade/OrderInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <StdLibErr.mqh>

// TradeInfo: Holds all data for a single trade or pending order
struct TradeInfo {
   double entryPrice;
   double sl;
   double tp;
   double lot;
   int score;
   string comment;
   ulong ticket;
   TradeInfo() : entryPrice(0), sl(0), tp(0), lot(0), score(0), comment(""), ticket(0) {}
};

class COneTradeEA_Core {
// --- State Variables ---
private:
   TradeInfo currentTrade; // Current trade or pending order info
   double originalEntryPrice;
   double originalSL;
   double originalTP;
   ENUM_ORDER_TYPE tradeMode;
   double lotSize;
   double riskValue; // Dollar risk per trade (client input)
   double rewardValue;
   string openTime;
   string closeTime;
   int maxReplacements;
   string windowStart;
   string windowEnd;
   int replacementsLeft;
   ulong lastOrderTicket;
   bool tradeActive;
   bool pendingOrderActive;
   string csvFileName;
   string m_symbol;
   string magicNumber;
   bool timeWindowEnabled;

public:
   // Generate a unique CSV file name for logging
   string GenerateCSVFileName()
   {
      string base = m_symbol + "_" + TimeToString(TimeCurrent(), TIME_DATE) + "_" + IntegerToString(MathRand());
      return base + ".csv";
   }

   // Initialize the CSV file with header if it does not exist
   void InitCSV(string filename)
   {
      int handle = FileOpen(filename, FILE_READ|FILE_TXT);
      if(handle < 0)
      {
         handle = FileOpen(filename, FILE_WRITE|FILE_TXT);
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

   // Log a trade event to the CSV file
   void LogCSV(string date, string time, string symbol, string tradeType, double lot, double sl, double tp, string result, int replacement, string errorCode, ulong ticket)
   {
      int handle = FileOpen(csvFileName, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_READ|FILE_SHARE_WRITE|FILE_SHARE_READ|8); // 8 = FILE_APPEND
      if(handle >= 0)
      {
         FileWrite(handle, date + "," + time + "," + symbol + "," + tradeType + "," + DoubleToString(lot,2) + "," + DoubleToString(sl,2) + "," + DoubleToString(tp,2) + "," + result + "," + IntegerToString((int)replacement) + "," + errorCode + "," + IntegerToString((int)ticket));
         FileClose(handle);
      }
   }
   // Returns true if a pending order for this symbol/magic is present
   bool HasPendingOrder()
   {
      // Detect pending orders by symbol and comment prefix (ORIGINAL_ or REPLACEMENT_)
      for(int i=0; i<OrdersTotal(); i++)
      {
         ulong ticket = OrderGetTicket(i);
         string symbol = OrderGetString(ORDER_SYMBOL);
         string comment = OrderGetString(ORDER_COMMENT);
         int type = (int)OrderGetInteger(ORDER_TYPE);
         bool isOurOrder = (symbol == m_symbol) &&
            ((StringFind(comment, "ORIGINAL_") == 0) || (StringFind(comment, "REPLACEMENT_") == 0)) &&
            (type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP);
         if(isOurOrder)
         {
            Print("[OneTradeEA][DEBUG] Found existing pending order: ticket=", ticket, " type=", (type==ORDER_TYPE_BUY_STOP?"BUY_STOP":"SELL_STOP"), " price=", OrderGetDouble(ORDER_PRICE_OPEN), " SL=", OrderGetDouble(ORDER_SL), " TP=", OrderGetDouble(ORDER_TP), " comment=", comment);
            return true;
         }
      }
      return false;
   }
// ...existing code...

public:
   COneTradeEA_Core() {}
   bool IsTradeActive() const { return tradeActive; }

   void Init(
      ENUM_ORDER_TYPE mode,
      double lot,
      double risk, // Dollar risk per trade
      double reward,
      string open,
      string close,
      int maxRepl,
      string winStart,
      string winEnd,
      string sym
   )
   {
      tradeMode = mode;
      lotSize = lot;
      riskValue = risk;
      rewardValue = reward;
      openTime = open;
      closeTime = close;
      // Always allow at least one replacement
      maxReplacements = (maxRepl > 0) ? maxRepl : 1;
      // Disable time window restrictions by default
      windowStart = "";
      windowEnd = "";
      m_symbol = sym;
      magicNumber = m_symbol + "_OneTradeEA";
      replacementsLeft = maxReplacements;
      tradeActive = false;
      pendingOrderActive = false;
      timeWindowEnabled = false;
      csvFileName = GenerateCSVFileName();
      InitCSV(csvFileName);
   }

   datetime ParseTime(string t)
   {
      if(t=="") return 0;
      int h = StringToInteger(StringSubstr(t,0,2));
      int m = StringToInteger(StringSubstr(t,3,2));
      int s = 0;
      if(StringLen(t) >= 8) s = StringToInteger(StringSubstr(t,6,2));
      datetime today = DateOfDay(TimeCurrent());
      return today + h*3600 + m*60 + s;
   }

   bool IsInTimeWindow(datetime now)
   {
      if(!timeWindowEnabled) return false;
      datetime winStart = ParseTime(windowStart);
      datetime winEnd = ParseTime(windowEnd);
      return (now >= winStart && now <= winEnd);
   }

   void OnNewDay()
   {
      replacementsLeft = maxReplacements;
      tradeActive = false;
      pendingOrderActive = false;
   }

   // Calculate price distance for SL/TP based on dollar risk
   double CalculateSLDistance()
   {
      double tickValue = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(tickValue <= 0 || tickSize <= 0 || point <= 0) {
         Print("[OneTradeEA][ERROR] Invalid tickValue/tickSize/point for symbol ", m_symbol);
         return 0;
      }
      // How many price units (in points) for the given dollar risk
      double sl_distance = (riskValue / (tickValue * lotSize)) * tickSize / point;
      return sl_distance * point;
   }

   void OpenFirstTrade()
   {
      double price = (tradeMode == ORDER_TYPE_BUY) ? SymbolInfoDouble(m_symbol, SYMBOL_ASK) : SymbolInfoDouble(m_symbol, SYMBOL_BID);
      if(price == 0.0) {
         Print("[OneTradeEA][ERROR] Failed to get price for symbol ", m_symbol);
         return;
      }
      long digits_long = SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      int digits = (int)digits_long;
      if(digits_long <= 0) {
         Print("[OneTradeEA][ERROR] Failed to get digits for symbol ", m_symbol);
         return;
      }
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point <= 0) {
         Print("[OneTradeEA][ERROR] Failed to get point for symbol ", m_symbol);
         return;
      }
      double rr = rewardValue; // R:R ratio (e.g., 2 for 1:2)
      double sl_distance = CalculateSLDistance();
      if(sl_distance <= 0) {
         Print("[OneTradeEA][ERROR] SL distance calculation failed");
         return;
      }
      double sl = 0, tp = 0;
      if(tradeMode == ORDER_TYPE_BUY)
      {
         sl = price - sl_distance;
         tp = price + (sl_distance * rr);
      }
      else // SELL
      {
         sl = price + sl_distance;
         tp = price - (sl_distance * rr);
      }
      // Initialize currentTrade for the original position
      currentTrade.entryPrice = price;
      currentTrade.sl = sl;
      currentTrade.tp = tp;
      currentTrade.lot = lotSize;
      currentTrade.score = maxReplacements;
      currentTrade.comment = "ORIGINAL_" + IntegerToString(maxReplacements);
      // ...existing code for pip values, request, and order send logic...
      double pipSize = (digits == 3 || digits == 5) ? point * 10 : point;
      double sl_pips = MathAbs(price - sl) / pipSize;
      double tp_pips = MathAbs(tp - price) / pipSize;
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      request.action = TRADE_ACTION_DEAL;
      request.symbol = m_symbol;
      request.volume = lotSize;
      request.type = tradeMode;
      request.price = price;
      request.sl = NormalizeDouble(sl, digits);
      request.tp = NormalizeDouble(tp, digits);
      request.deviation = 10;
      request.magic = 0;
      request.comment = currentTrade.comment;
      // Use only supported filling modes for the symbol
      long filling_mode_long = 0;
      if(!SymbolInfoInteger(m_symbol, SYMBOL_FILLING_MODE, filling_mode_long)) {
         Print("[OneTradeEA][ERROR] Failed to get SYMBOL_FILLING_MODE for symbol ", m_symbol);
         return;
      }
      int filling_mode = (int)filling_mode_long;
      int try_modes[3] = {ORDER_FILLING_FOK, ORDER_FILLING_IOC, ORDER_FILLING_RETURN};
      bool orderSent = false;
      for(int i=0; i<3 && !orderSent; i++) {
         int mode = try_modes[i];
         request.type_filling = (ENUM_ORDER_TYPE_FILLING)mode;
         if(OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE) {
            orderSent = true;
         }
      }
      // As last resort, try the default mode
      if(!orderSent) {
         request.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
         if(OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE) {
            orderSent = true;
         }
      }
      if(!orderSent) {
         // Log order send failure with calculated SL/TP in price
         LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "OrderSendFail", currentTrade.score, IntegerToString((int)result.retcode), 0);
         tradeActive = false;
         return;
      }
      tradeActive = true;
      lastOrderTicket = result.order;
      currentTrade.ticket = result.order;
      // Log successful order open with calculated SL/TP in price
      LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "OPEN", currentTrade.score, "", result.order);

   }

   void MonitorTrades()
   {
      // Check if any position is open for this EA
      bool found = false;
      for(int i=0; i<PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         string comment = PositionGetString(POSITION_COMMENT);
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && (StringFind(comment, "ORIGINAL_") == 0 || StringFind(comment, "REPLACEMENT_") == 0))
         {
            found = true;
            double sl = PositionGetDouble(POSITION_SL);
            double tp = PositionGetDouble(POSITION_TP);
            double priceCurrent = (tradeMode==ORDER_TYPE_BUY) ? SymbolInfoDouble(m_symbol, SYMBOL_BID) : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
            // Parse score from comment
            int score = 0;
            if(StringFind(comment, "ORIGINAL_") == 0)
               score = StringToInteger(StringSubstr(comment, 9));
            else if(StringFind(comment, "REPLACEMENT_") == 0)
               score = StringToInteger(StringSubstr(comment, 12));
            // Update currentTrade from position info
            currentTrade.entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            currentTrade.sl = sl;
            currentTrade.tp = tp;
            currentTrade.lot = PositionGetDouble(POSITION_VOLUME);
            currentTrade.score = score;
            currentTrade.comment = comment;
            currentTrade.ticket = ticket;
            // Only print when SL is hit (see below)
            // If a pending order was active and now a position is open, reset state and print clear debug message
            if(pendingOrderActive && !tradeActive)
            {
               Print("[OneTradeEA][DEBUG] Position opened from pending order. Core logic: tradeActive set to true, pendingOrderActive set to false. Replacement score now: ", currentTrade.score);
               tradeActive = true;
               pendingOrderActive = false;
            }
            Print("    timeWindow=", IsInTimeWindow(TimeCurrent()));

            // Draw vertical line at SL hit
            string vline_name = "SL_HIT_" + IntegerToString(ticket) + "_" + TimeToString(TimeCurrent(), TIME_SECONDS);
            datetime vline_time = TimeCurrent();
            ObjectCreate(0, vline_name, OBJ_VLINE, 0, vline_time, 0);
            ObjectSetInteger(0, vline_name, OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0, vline_name, OBJPROP_WIDTH, 2);

            if(PositionCloseHelper(ticket))
            {
               LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl, tp, "SL", currentTrade.score, "", ticket);
            }
            else
            {
               LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl, tp, "SL_FAIL", currentTrade.score, "CLOSE", ticket);
            }
            // Only place replacement if not in time window, score > 0, and no pending order exists
            tradeActive = false;
            bool hasPending = HasPendingOrder();
            Print("[OneTradeEA][DEBUG] HasPendingOrder() result: ", hasPending);
            if(currentTrade.score > 0 && !IsInTimeWindow(TimeCurrent()) && !hasPending)
            {
               Print("[OneTradeEA][DEBUG] Condition met for pending order: score > 0, not in time window, no pending order exists.");
               Print("[OneTradeEA][DEBUG] Attempting to place pending order after SL. score=", currentTrade.score-1);
               currentTrade.score--;
               currentTrade.comment = "REPLACEMENT_" + IntegerToString(currentTrade.score);
               pendingOrderActive = true;
               // Use original entry/SL for pending order
               OpenPendingOrder(currentTrade.entryPrice, currentTrade.sl);
               Print("[OneTradeEA][DEBUG] State AFTER pending order logic:");
               Print("    tradeActive=", tradeActive);
               Print("    pendingOrderActive=", pendingOrderActive);
               Print("    score=", currentTrade.score);
            }
            else
            {
               Print("[OneTradeEA][DEBUG] Condition NOT met for pending order. State:");
               Print("    score=", currentTrade.score);
               Print("    pendingOrderActive=", pendingOrderActive);
               Print("    timeWindow=", IsInTimeWindow(TimeCurrent()));
               Print("[OneTradeEA][DEBUG] Pending order NOT placed after SL.");
               if(hasPending)
                  Print("[OneTradeEA][DEBUG] Pending order block is activated: HasPendingOrder()=true");
            }
            return; // Only handle one position per tick
         }
         // TP hit
         double tp = PositionGetDouble(POSITION_TP);
         double sl = PositionGetDouble(POSITION_SL);
         double priceCurrent = (tradeMode==ORDER_TYPE_BUY) ? SymbolInfoDouble(m_symbol, SYMBOL_BID) : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
         if(tp > 0 && ((tradeMode == ORDER_TYPE_BUY && priceCurrent >= tp) || (tradeMode == ORDER_TYPE_SELL && priceCurrent <= tp)))
         {
            Print("[OneTradeEA][DEBUG] Position closed at TP. tradeActive=", tradeActive, " pendingOrderActive=", pendingOrderActive, " score=", currentTrade.score);
            if(PositionCloseHelper(ticket))
            {
               LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl, tp, "TP", currentTrade.score, "", ticket);
            }
            else
            {
               LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl, tp, "TP_FAIL", currentTrade.score, "CLOSE", ticket);
            }
            tradeActive = false;
            currentTrade.score = 0;
            pendingOrderActive = false;
            return;
         }
      }
      // If no position found, set tradeActive to false
      tradeActive = found;
   }

   void OpenPendingOrder(double entryPrice, double sl)
   {
      long digits_long = SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      int digits = (int)digits_long;
      if(digits_long <= 0) {
         Print("[OneTradeEA][ERROR] Failed to get digits for symbol ", m_symbol);
         return;
      }
      // Use currentTrade info for the replacement pending order
      double entry = currentTrade.entryPrice;
      double sl_val = currentTrade.sl;
      double tp_val = currentTrade.tp;
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      request.action = TRADE_ACTION_PENDING;
      request.symbol = m_symbol;
      request.volume = currentTrade.lot;
      // Set correct pending order type
      if(tradeMode == ORDER_TYPE_BUY)
         request.type = ORDER_TYPE_BUY_STOP;
      else
         request.type = ORDER_TYPE_SELL_STOP;
      request.price = NormalizeDouble(entry, digits);
      request.sl = NormalizeDouble(sl_val, digits);
      request.tp = NormalizeDouble(tp_val, digits);
      request.deviation = 10;
      request.magic = 0;
      // Always use comment format "REPLACEMENT_N" for replacements
      request.comment = currentTrade.comment;
      Print("[OneTradeEA][DEBUG] Placing pending order:");
      Print("    Symbol: ", m_symbol);
      Print("    Type: ", (request.type == ORDER_TYPE_BUY_STOP ? "BUY_STOP" : "SELL_STOP"));
      Print("    Price: ", request.price);
      Print("    SL: ", request.sl);
      Print("    TP: ", request.tp);
      Print("    Lot: ", request.volume);
      Print("    Magic: ", request.magic);
      Print("    Comment: ", request.comment);
      Print("    Score after this: ", currentTrade.score);
      // Use only supported filling modes for the symbol
      long filling_mode_long = 0;
      if(!SymbolInfoInteger(m_symbol, SYMBOL_FILLING_MODE, filling_mode_long)) {
         Print("[OneTradeEA][ERROR] Failed to get SYMBOL_FILLING_MODE for symbol ", m_symbol);
         return;
      }
      int filling_mode = (int)filling_mode_long;
      int try_modes[3] = {ORDER_FILLING_FOK, ORDER_FILLING_IOC, ORDER_FILLING_RETURN};
      bool orderSent = false;
      for(int i=0; i<3 && !orderSent; i++) {
         int mode = try_modes[i];
         request.type_filling = (ENUM_ORDER_TYPE_FILLING)mode;
         if(OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE) {
            orderSent = true;
         }
      }
      // As last resort, try the default mode
      if(!orderSent) {
         request.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
         if(OrderSend(request, result) && result.retcode == TRADE_RETCODE_DONE) {
            orderSent = true;
         }
      }
      if(!orderSent) {
         LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl_val, tp_val, "PendingOrderFail", currentTrade.score, IntegerToString((int)result.retcode), 0);
         pendingOrderActive = false;
         return;
      }
      pendingOrderActive = true;
      currentTrade.ticket = result.order;
      LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl_val, tp_val, "PENDING", currentTrade.score, "", result.order);
   }

   void RemovePendingOrders()
   {
      for(int i=0; i<OrdersTotal(); i++)
      {
         ulong ticket = OrderGetTicket(i);
         string symbol = OrderGetString(ORDER_SYMBOL);
         string comment = OrderGetString(ORDER_COMMENT);
         int type = (int)OrderGetInteger(ORDER_TYPE);
         bool isOurOrder = (symbol == m_symbol) &&
            ((StringFind(comment, "ORIGINAL_") == 0) || (StringFind(comment, "REPLACEMENT_") == 0)) &&
            (type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP);
         if(isOurOrder)
         {
            OrderDeleteHelper(ticket);
         }
      }
   }

   void OnCloseTime()
   {
      // Close all positions and remove pending orders
      for(int i=0; i<PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetString(POSITION_COMMENT) == magicNumber)
            // If a new position is opened (pending order triggered), reset pendingOrderActive
            if(!tradeActive && PositionGetDouble(POSITION_PRICE_OPEN) != 0)
            {
               tradeActive = true;
               pendingOrderActive = false;
            }
         {
            PositionCloseHelper(ticket);
         }
      }
      RemovePendingOrders();
   }

   // Utility
   datetime DateOfDay(datetime t)
   {
      MqlDateTime dt;
      TimeToStruct(t, dt);
      dt.hour = 0; dt.min = 0; dt.sec = 0;
      return StructToTime(dt);
   }
   // Helper for closing positions
   bool PositionCloseHelper(ulong ticket)
   {
      CTrade trade;
      return trade.PositionClose(ticket);
   }
   // Helper for deleting orders
   bool OrderDeleteHelper(ulong ticket)
   {
      CTrade trade;
      return trade.OrderDelete(ticket);
   }
};

#endif // __ONETRADEEA_CORE_MQH__