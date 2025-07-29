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

class COneTradeEA_Core
  {
private:
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
      maxReplacements = maxRepl;
      windowStart = winStart;
      windowEnd = winEnd;
      m_symbol = sym;
      magicNumber = m_symbol + "_OneTradeEA";
      replacementsLeft = maxReplacements;
      tradeActive = false;
      pendingOrderActive = false;
      timeWindowEnabled = (windowStart != "" && windowEnd != "");
      csvFileName = GenerateCSVFileName();
      InitCSV(csvFileName);
   }

   string GenerateCSVFileName()
   {
      string base = m_symbol + "_" + TimeToString(TimeCurrent(), TIME_DATE) + "_" + IntegerToString(MathRand());
      return base + ".csv";
   }

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

   void LogCSV(string date, string time, string symbol, string tradeType, double lot, double sl, double tp, string result, int replacement, string errorCode, ulong ticket)
   {
      int handle = FileOpen(csvFileName, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_READ|FILE_SHARE_WRITE|FILE_SHARE_READ|8); // 8 = FILE_APPEND
      if(handle >= 0)
      {
         FileWrite(handle, date + "," + time + "," + symbol + "," + tradeType + "," + DoubleToString(lot,2) + "," + DoubleToString(sl,2) + "," + DoubleToString(tp,2) + "," + result + "," + IntegerToString((int)replacement) + "," + errorCode + "," + IntegerToString((int)ticket));
         FileClose(handle);
      }
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
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      if(digits <= 0) {
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
      // Store original entry/SL/TP for replacement logic
      originalEntryPrice = price;
      originalSL = sl;
      originalTP = tp;
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
      request.comment = magicNumber;
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
         LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "OrderSendFail", replacementsLeft, IntegerToString((int)result.retcode), 0);
         tradeActive = false;
         return;
      }
      tradeActive = true;
      lastOrderTicket = result.order;
      // Log successful order open with calculated SL/TP in price
      LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "OPEN", replacementsLeft, "", result.order);
   }

   void MonitorTrades()
   {
      // Check if any position is open for this EA
      bool found = false;
      for(int i=0; i<PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetString(POSITION_COMMENT) == magicNumber)
         {
            found = true;
            double sl = PositionGetDouble(POSITION_SL);
            double tp = PositionGetDouble(POSITION_TP);
            double priceCurrent = (tradeMode==ORDER_TYPE_BUY) ? SymbolInfoDouble(m_symbol, SYMBOL_BID) : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
            // If a pending order was active and now a position is open, reset state
            if(pendingOrderActive && !tradeActive)
            {
               tradeActive = true;
               pendingOrderActive = false;
            }
            // SL hit
            if(sl > 0 && ((tradeMode == ORDER_TYPE_BUY && priceCurrent <= sl) || (tradeMode == ORDER_TYPE_SELL && priceCurrent >= sl)))
            {
               if(PositionCloseHelper(ticket))
               {
                  LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "SL", replacementsLeft, "", ticket);
               }
               else
               {
                  LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "SL_FAIL", replacementsLeft, "CLOSE", ticket);
               }
               // Only place replacement if not in time window, replacementsLeft > 0, and no pending order is active
               tradeActive = false;
               if(replacementsLeft > 0 && !IsInTimeWindow(TimeCurrent()) && !pendingOrderActive)
               {
                  replacementsLeft--;
                  pendingOrderActive = true;
                  // Use original entry/SL for pending order
                  OpenPendingOrder(originalEntryPrice, originalSL);
               }
               return; // Only handle one position per tick
            }
            // TP hit
            if(tp > 0 && ((tradeMode == ORDER_TYPE_BUY && priceCurrent >= tp) || (tradeMode == ORDER_TYPE_SELL && priceCurrent <= tp)))
            {
               if(PositionCloseHelper(ticket))
               {
                  LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "TP", replacementsLeft, "", ticket);
               }
               else
               {
                  LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "TP_FAIL", replacementsLeft, "CLOSE", ticket);
               }
               tradeActive = false;
               replacementsLeft = 0;
               pendingOrderActive = false;
               return;
            }
         }
      }
      // If no position found, set tradeActive to false
      tradeActive = found;
   }

   void OpenPendingOrder(double entryPrice, double sl)
   {
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      if(digits <= 0) {
         Print("[OneTradeEA][ERROR] Failed to get digits for symbol ", m_symbol);
         return;
      }
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point <= 0) {
         Print("[OneTradeEA][ERROR] Failed to get point for symbol ", m_symbol);
         return;
      }
      double rr = rewardValue;
      // Calculate SL distance for pending order (use same as market order)
      double sl_distance = CalculateSLDistance();
      if(sl_distance <= 0) {
         Print("[OneTradeEA][ERROR] SL distance calculation failed (pending order)");
         return;
      }
      // Use original TP for replacement logic
      double tp = originalTP;
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      request.action = TRADE_ACTION_PENDING;
      request.symbol = m_symbol;
      request.volume = lotSize;
      request.type = tradeMode;
      request.price = NormalizeDouble(entryPrice, digits);
      request.sl = NormalizeDouble(sl, digits);
      request.tp = NormalizeDouble(tp, digits);
      request.deviation = 10;
      request.magic = 0;
      request.comment = magicNumber;
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
         LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "PendingOrderFail", replacementsLeft, IntegerToString((int)result.retcode), 0);
         pendingOrderActive = false;
         return;
      }
      pendingOrderActive = true;
      LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "PENDING", replacementsLeft, "", result.order);
   }

   void RemovePendingOrders()
   {
      for(int i=0; i<OrdersTotal(); i++)
      {
         ulong ticket = OrderGetTicket(i);
         if(OrderGetString(ORDER_SYMBOL) == m_symbol && OrderGetString(ORDER_COMMENT) == magicNumber)
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