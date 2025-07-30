//+------------------------------------------------------------------+
//| OneTradeEA_Core.mqh                                              |
//| Implements the core logic for One Trade EA as per requirements   |
//| SL is a price distance (e.g. $20 for BTCUSD, 20 points for XAUUSD),
//| not a dollar risk. Lot size is independent of SL calculation.    |
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
   double originalEntryPrice;
   double originalSL;
   double originalTP;
   ENUM_ORDER_TYPE tradeMode;
   double lotSize;
   double slDistance; // Stop loss distance in price units (e.g. $20 for BTCUSD, 20 points for XAUUSD)
   double rewardValue;
   string openTime;
   string closeTime;
   int maxReplacements;
   string windowStart;
   string windowEnd;
   int replacementsLeft;
   ulong lastOrderTicket;
   bool tradeActive;
   string csvFileName;
   string m_symbol;
   string magicNumber;
   bool timeWindowEnabled;

public:
   TradeInfo currentTrade; // Exposed for event-driven access
   bool pendingOrderActive; // Exposed for event-driven access

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
      double sl_dist, // Stop loss distance in price units
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
      slDistance = sl_dist;
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

   // Return the user-defined SL distance (in price units, e.g. $20 for BTCUSD, 20 points for XAUUSD)
   // Also provide conversion to pips for robust calculation
   double GetSLDistancePrice() { return slDistance; }
   double GetSLDistancePips() {
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point <= 0) return 0;
      return slDistance / point;
   }

   // Open the first trade of the day. SL/TP are set robustly using broker pip/digit info.
   // For BUY: SL = entry - slDistance; TP = entry + (slDistance * rewardValue)
   // For SELL: SL = entry + slDistance; TP = entry - (slDistance * rewardValue)
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
      double sl_distance = GetSLDistancePrice();
      if(sl_distance <= 0) {
         Print("[OneTradeEA][ERROR] SL distance must be positive");
         return;
      }
      // Convert to pips for info/debug
      double sl_pips = sl_distance / point;
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
      // Normalize all price levels
      sl = NormalizeDouble(sl, digits);
      tp = NormalizeDouble(tp, digits);
      price = NormalizeDouble(price, digits);
      // Initialize currentTrade for the original position
      currentTrade.entryPrice = price;
      currentTrade.sl = sl;
      currentTrade.tp = tp;
      currentTrade.lot = lotSize;
      currentTrade.score = maxReplacements;
      currentTrade.comment = "ORIGINAL_" + IntegerToString(maxReplacements);
      // ...existing code for pip values, request, and order send logic...
      double pipSize = (digits == 3 || digits == 5) ? point * 10 : point;
      double sl_pips2 = MathAbs(price - sl) / pipSize;
      double tp_pips = MathAbs(tp - price) / pipSize;
      Print("[OneTradeEA][DEBUG] SL distance input=", sl_distance, " (", sl_pips, " pips), normalized SL=", sl, " TP=", tp, " entry=", price);
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      request.action = TRADE_ACTION_DEAL;
      request.symbol = m_symbol;
      request.volume = lotSize;
      request.type = tradeMode;
      request.price = price;
      request.sl = sl;
      request.tp = tp;
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
      // Passive/event-driven: Only update currentTrade for tracking, do not act on trades.
      bool found = false;
      for(int i=0; i<PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         string comment = PositionGetString(POSITION_COMMENT);
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && (StringFind(comment, "ORIGINAL_") == 0 || StringFind(comment, "REPLACEMENT_") == 0))
         {
            found = true;
            // Update currentTrade from position info for tracking only
            int score = 0;
            if(StringFind(comment, "ORIGINAL_") == 0)
               score = StringToInteger(StringSubstr(comment, 9));
            else if(StringFind(comment, "REPLACEMENT_") == 0)
               score = StringToInteger(StringSubstr(comment, 12));
            currentTrade.entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            currentTrade.sl = PositionGetDouble(POSITION_SL);
            currentTrade.tp = PositionGetDouble(POSITION_TP);
            currentTrade.lot = PositionGetDouble(POSITION_VOLUME);
            currentTrade.score = score;
            currentTrade.comment = comment;
            currentTrade.ticket = ticket;
            // If a pending order was active and now a position is open, update state for tracking
            if(pendingOrderActive && !tradeActive)
            {
               Print("[OneTradeEA][DEBUG] Position opened from pending order. Core logic: tradeActive set to true, pendingOrderActive set to false. Replacement score now: ", currentTrade.score);
               tradeActive = true;
               pendingOrderActive = false;
            }
            // Removed debug print for timeWindow
            // No trade actions here. All SL/TP/replacement logic is handled in OnTradeTransaction.
            return; // Only handle one position per tick
         }
      }
      // If no position found, set tradeActive to false (for tracking only)
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
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point <= 0) {
         Print("[OneTradeEA][ERROR] Failed to get point for symbol ", m_symbol);
         return;
      }
      double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
      double stops_level = SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double min_distance = stops_level * point;
      // Use currentTrade info for the replacement pending order
      double entry = currentTrade.entryPrice;
      double sl_distance = GetSLDistancePrice();
      double rr = rewardValue;
      double sl = 0, tp = 0;
      if(tradeMode == ORDER_TYPE_BUY)
      {
         // For BUY_STOP, ensure price is above Ask + stops_level
         Print("[OneTradeEA][DEBUG] BUY_STOP: entry=", entry, " Ask=", ask, " stops_level=", stops_level, " min_distance=", min_distance);
         double min_valid_price = ask + min_distance;
         if(entry <= min_valid_price) {
            Print("[OneTradeEA][WARNING] BUY_STOP price invalid (<= Ask+stops_level). Adjusting from ", entry, " to ", min_valid_price);
            entry = min_valid_price;
         }
         sl = entry - sl_distance;
         tp = entry + (sl_distance * rr);
      }
      else // SELL_STOP
      {
         sl = entry + sl_distance;
         tp = entry - (sl_distance * rr);
      }
      // Normalize all price levels
      entry = NormalizeDouble(entry, digits);
      sl = NormalizeDouble(sl, digits);
      tp = NormalizeDouble(tp, digits);
      // Debug output
      double sl_pips = sl_distance / point;
      Print("[OneTradeEA][DEBUG] Pending SL distance input=", sl_distance, " (", sl_pips, " pips), normalized SL=", sl, " TP=", tp, " entry=", entry);
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
      request.price = entry;
      request.sl = sl;
      request.tp = tp;
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
         bool sendResult = OrderSend(request, result);
         Print("[OneTradeEA][DEBUG] OrderSend (try mode ", mode, ") result=", sendResult, " retcode=", result.retcode);
         if(sendResult && result.retcode == TRADE_RETCODE_DONE) {
            orderSent = true;
         }
      }
      // As last resort, try the default mode
      if(!orderSent) {
         request.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
         bool sendResult = OrderSend(request, result);
         Print("[OneTradeEA][DEBUG] OrderSend (default mode) result=", sendResult, " retcode=", result.retcode);
         if(sendResult && result.retcode == TRADE_RETCODE_DONE) {
            orderSent = true;
         }
      }
      if(!orderSent) {
         Print("[OneTradeEA][ERROR] Pending order send failed. retcode=", result.retcode);
         LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl, tp, "PendingOrderFail", currentTrade.score, IntegerToString((int)result.retcode), 0);
         pendingOrderActive = false;
         return;
      }
      Print("[OneTradeEA][DEBUG] Pending order placed successfully. Ticket=", result.order);
      pendingOrderActive = true;
      currentTrade.ticket = result.order;
      LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), currentTrade.lot, sl, tp, "PENDING", currentTrade.score, "", result.order);
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