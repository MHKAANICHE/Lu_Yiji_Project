//+------------------------------------------------------------------+
//| StupidBuyEA_FillingModes.mq5                                     |
//| Opens a BUY position with 100 pips TP/SL using robust filling   |
//| Prints history trades for this symbol and magic                 |
//+------------------------------------------------------------------+

#property copyright "GitHub Copilot"
#property version   "1.01"
#property strict

input double Lots = 0.1;
input int    Slippage = 5;
input int    Magic = 54321;

#define FIXED_SL_PIPS 100
#define FIXED_TP_PIPS 100

// Helper to get pip size for the current symbol
double GetPipSize() {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pip = 0.0;
   if(digits == 3 || digits == 5)
      pip = 0.00010;
   else if(digits == 2 || digits == 4)
      pip = 0.01;
   else
      pip = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // fallback
   return pip;
}

// Print all closed trades for this symbol and magic
void PrintHistoryTrades() {
   int total = HistoryDealsTotal();
   //Print("[StupidBuyEA] History deals: ", total);
   for(int i=0; i<total; i++) {
      ulong deal = HistoryDealGetTicket(i);
      if(HistoryDealGetString(deal, DEAL_SYMBOL) == _Symbol && HistoryDealGetInteger(deal, DEAL_MAGIC) == Magic) {
         double price = HistoryDealGetDouble(deal, DEAL_PRICE);
         double profit = HistoryDealGetDouble(deal, DEAL_PROFIT);
         long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
         string entryType = (entry == DEAL_ENTRY_IN) ? "IN" : (entry == DEAL_ENTRY_OUT ? "OUT" : "OTHER");
         PrintFormat("[StupidBuyEA] Deal #%d: %s, Price: %.5f, Profit: %.2f, Entry: %s", deal, _Symbol, price, profit, entryType);
      }
   }
}

// Check if there is an open position for this symbol and magic
bool HasOpenPosition() {
   for(int i=0; i<PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
         return true;
   }
   return false;
}

// Place a BUY order using robust filling mode technique
bool PlaceBuyOrder() {
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double pip = GetPipSize();
   double sl = price - FIXED_SL_PIPS * pip;
   double tp = price + FIXED_TP_PIPS * pip;
   double lot = Lots;
   MqlTradeRequest req;
   ZeroMemory(req);
   MqlTradeResult res;
   ZeroMemory(res);
   req.action = TRADE_ACTION_DEAL;
   req.symbol = _Symbol;
   req.volume = lot;
   req.type = ORDER_TYPE_BUY;
   req.price = price;
   req.sl = sl;
   req.tp = tp;
   req.deviation = Slippage;
   req.magic = Magic;

   // Try multiple filling modes for broker compatibility
   long filling_mode_long = 0;
   if(!SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE, filling_mode_long))
      filling_mode_long = ORDER_FILLING_IOC;
   int filling_mode = (int)filling_mode_long;
   int try_modes[3] = {ORDER_FILLING_FOK, ORDER_FILLING_IOC, ORDER_FILLING_RETURN};
   bool orderSent = false;
   for(int i=0; i<3 && !orderSent; i++) {
      int mode = try_modes[i];
      req.type_filling = (ENUM_ORDER_TYPE_FILLING)mode;
      if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE) {
         orderSent = true;
      }
   }
   // As last resort, try the default mode
   if(!orderSent) {
      req.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
      if(OrderSend(req, res) && res.retcode == TRADE_RETCODE_DONE) {
         orderSent = true;
      }
   }
   if(orderSent) {
      Print("[StupidBuyEA] BUY order placed. Ticket:", res.order);
      return true;
   } else {
      Print("[StupidBuyEA] OrderSend failed for all filling modes. Retcode:", res.retcode);
      return false;
   }
}

int OnInit() {
   Print("[StupidBuyEA] Initialized");
   return(INIT_SUCCEEDED);
}

void OnTick() {
   PrintHistoryTrades(); // Print history every tick
   if(HasOpenPosition())
      return;
   PlaceBuyOrder();
}

// Robust: Print closed deals in real time using OnTradeTransaction
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result) {
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD) {
      ulong deal = trans.deal;
      if(HistoryDealGetString(deal, DEAL_SYMBOL) == _Symbol && HistoryDealGetInteger(deal, DEAL_MAGIC) == Magic) {
         long entryType = HistoryDealGetInteger(deal, DEAL_ENTRY);
         if(entryType == DEAL_ENTRY_OUT) { // Only print closing deals
            double price = HistoryDealGetDouble(deal, DEAL_PRICE);
            double profit = HistoryDealGetDouble(deal, DEAL_PROFIT);
            string reasonStr = "OTHER";
            long reason = HistoryDealGetInteger(deal, DEAL_REASON);
            if(reason == DEAL_REASON_SL) reasonStr = "SL";
            else if(reason == DEAL_REASON_TP) reasonStr = "TP";
            PrintFormat("[StupidBuyEA][OnTradeTransaction] Closed deal #%d: %s, Price: %.5f, Profit: %.2f, Reason: %s", deal, _Symbol, price, profit, reasonStr);
         }
      }
   }
}
