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
   ENUM_ORDER_TYPE tradeMode;
   double lotSize;
   int stopLoss;
   double riskValue;
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

   void Init(
      ENUM_ORDER_TYPE mode,
      double lot,
      int sl,
      double risk,
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
      stopLoss = sl;
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
      datetime today = DateOfDay(TimeCurrent());
      return today + h*3600 + m*60;
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

   void OpenFirstTrade()
   {
      double price = (tradeMode == ORDER_TYPE_BUY) ? SymbolInfoDouble(m_symbol, SYMBOL_ASK) : SymbolInfoDouble(m_symbol, SYMBOL_BID);
      double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      double stopLossPips = stopLoss * point * 10;
      double rr = (rewardValue > 0 && riskValue > 0) ? rewardValue / riskValue : 0;
      double sl = (tradeMode == ORDER_TYPE_BUY) ? price - stopLossPips : price + stopLossPips;
      double tp = (rewardValue > 0 && riskValue > 0) ? ((tradeMode == ORDER_TYPE_BUY) ? price + stopLossPips * rr : price - stopLossPips * rr) : 0;
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      request.action = TRADE_ACTION_DEAL;
      request.symbol = m_symbol;
      request.volume = lotSize;
      request.type = tradeMode;
      request.price = price;
      request.sl = NormalizeDouble(sl, digits);
      request.tp = (tp > 0) ? NormalizeDouble(tp, digits) : 0;
      request.deviation = 10;
      request.magic = 0;
      request.comment = magicNumber;
      if(!OrderSend(request, result) || result.retcode != TRADE_RETCODE_DONE)
      {
         LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "OrderSendFail", replacementsLeft, IntegerToString((int)result.retcode), 0);
         tradeActive = false;
         return;
      }
      tradeActive = true;
      lastOrderTicket = result.order;
      LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, tp, "OPEN", replacementsLeft, "", result.order);
   }

   void MonitorTrades()
   {
      for(int i=0; i<PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionGetString(POSITION_SYMBOL) == m_symbol && PositionGetString(POSITION_COMMENT) == magicNumber)
         {
            double sl = PositionGetDouble(POSITION_SL);
            double tp = PositionGetDouble(POSITION_TP);
            double priceCurrent = (tradeMode==ORDER_TYPE_BUY) ? SymbolInfoDouble(m_symbol, SYMBOL_BID) : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
            bool closed = false;
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
               tradeActive = false;
               closed = true;
               if(replacementsLeft > 0 && !IsInTimeWindow(TimeCurrent()))
               {
                  replacementsLeft--;
                  OpenPendingOrder(priceCurrent, sl);
               }
            }
            // TP hit
            if(!closed && tp > 0 && ((tradeMode == ORDER_TYPE_BUY && priceCurrent >= tp) || (tradeMode == ORDER_TYPE_SELL && priceCurrent <= tp)))
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
            }
         }
      }
   }

   void OpenPendingOrder(double entryPrice, double sl)
   {
      MqlTradeRequest request;
      MqlTradeResult result;
      ZeroMemory(request);
      request.action = TRADE_ACTION_PENDING;
      request.symbol = m_symbol;
      request.volume = lotSize;
      request.type = tradeMode;
      request.price = entryPrice;
      request.sl = sl;
      request.tp = 0;
      request.deviation = 10;
      request.magic = 0;
      request.comment = magicNumber;
      if(!OrderSend(request, result) || result.retcode != TRADE_RETCODE_DONE)
      {
         LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, 0, "PendingOrderFail", replacementsLeft, IntegerToString((int)result.retcode), 0);
         pendingOrderActive = false;
         return;
      }
      pendingOrderActive = true;
      LogCSV(TimeToString(TimeCurrent(), TIME_DATE), TimeToString(TimeCurrent(), TIME_SECONDS), m_symbol, (tradeMode==ORDER_TYPE_BUY?"BUY":"SELL"), lotSize, sl, 0, "PENDING", replacementsLeft, "", result.order);
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
