//+------------------------------------------------------------------+
//| SimpleOneTradeEA.mq5                                             |
//| A simple one-trade EA for backtesting, with replacement logic    |
//| Only BUY entries, fixed TP/SL, OOP, and clear state/logic loops  |
//+------------------------------------------------------------------+

#property copyright "GitHub Copilot"
#property version   "1.00"
#property strict

//--- Input parameters
input double Lots = 0.1;
input int    Slippage = 5;
input int    Magic = 12345;


//--- Fixed SL/TP in pips
#define FIXED_SL_PIPS 100
#define FIXED_TP_PIPS 200

//--- Helper to get pip size for the current symbol
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

//--- Helper struct to store first entry parameters
class FirstEntryParams {
public:
   double entryPrice;
   double sl;
   double tp;
   double lot;
   FirstEntryParams() { entryPrice=0; sl=0; tp=0; lot=0; }
   void Save(double price, double sl_, double tp_, double lot_) {
      entryPrice = price; sl = sl_; tp = tp_; lot = lot_;
   }
   void Reset() { entryPrice=0; sl=0; tp=0; lot=0; }
};

//--- Main EA class
class SimpleOneTradeEA {
   double lastEntryPrice;
   double lastSL;
   double lastTP;
   double lastClosePrice;
   bool pendingBacktestCloseCheck;
private:
   bool flagPlaceFirstEntry;
   bool flagPlaceReplacement;
   int replacementScore;
   int replacementScoreMax;
   FirstEntryParams firstEntry;
   ulong lastTicket;
   ulong openPositionTicket; // Track the ticket of the opened position
public:
   SimpleOneTradeEA() {
      flagPlaceFirstEntry = true;
      flagPlaceReplacement = false;
      replacementScoreMax = 5;
      replacementScore = replacementScoreMax;
      lastTicket = 0;
      openPositionTicket = 0;
      lastClosedTicket = 0;
   }
   ulong lastClosedTicket; // Track last closed position ticket for backtest SL/TP detection

   void OnInit() {
      flagPlaceFirstEntry = true;
      flagPlaceReplacement = false;
      replacementScore = replacementScoreMax;
      firstEntry.Reset();
      lastTicket = 0;
      openPositionTicket = 0;
      lastEntryPrice = 0;
      lastSL = 0;
      lastTP = 0;
      lastClosePrice = 0;
      pendingBacktestCloseCheck = false;
   }

   void OnTick() {
      bool hasPosition = CheckForActivePosition();
      #ifdef __MQL5__
      if(MQLInfoInteger(MQL_TESTER)) {
         // Always use price-based SL/TP detection in tester
         if(!hasPosition && !pendingBacktestCloseCheck && openPositionTicket != 0) {
            Print("[DEBUG] [Backtest] Position closed, will check SL/TP next tick (price-based technique)");
            pendingBacktestCloseCheck = true;
            lastEntryPrice = firstEntry.entryPrice;
            lastSL = firstEntry.sl;
            lastTP = firstEntry.tp;
            lastClosePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Approximate close price
            openPositionTicket = 0;
            return;
         }
         if(pendingBacktestCloseCheck && !hasPosition) {
            Print("[DEBUG] [Backtest] Using price-based SL/TP detection technique");
            string closeReason = "OTHER";
            PrintFormat("[DEBUG] [Backtest] Price-based SL/TP check: entry=%.5f, sl=%.5f, tp=%.5f, close=%.5f", lastEntryPrice, lastSL, lastTP, lastClosePrice);
            if(lastClosePrice <= lastEntryPrice) closeReason = "SL";
            else if(lastClosePrice > lastEntryPrice) closeReason = "TP";
            PrintFormat("[DEBUG] [Backtest] Inferred close reason: %s", closeReason);
            OnPositionClosed(closeReason);
            pendingBacktestCloseCheck = false;
         }
      }
      #endif
      if (hasPosition) {
         // State loop: if position is open, do nothing
         return;
      }
      // Only run logic loop if no position is open
      LogicLoop();
   }

   bool CheckForActivePosition() {
      Print("[DEBUG] CheckForActivePosition called. PositionsTotal=", PositionsTotal());
      for(int i=0; i<PositionsTotal(); i++) {
         ulong ticket = PositionGetTicket(i);
         long magic = PositionGetInteger(POSITION_MAGIC);
         string symbol = PositionGetString(POSITION_SYMBOL);
         PrintFormat("[DEBUG] Position %d: ticket=%d, magic=%d, symbol=%s", i, ticket, magic, symbol);
         if(magic == Magic && symbol == _Symbol) {
            Print("[DEBUG] Active position found for this EA and symbol.");
            return true;
         }
      }
      Print("[DEBUG] No active position for this EA and symbol.");
      return false;
   }


//--- Called on every trade transaction (robust for SL/TP detection)
// This must be a global function for MetaTrader to call it
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result) {
    Print("[DEBUG] OnTradeTransaction called");
    PrintFormat("[DEBUG] Transaction type: %d", trans.type);
    PrintFormat("[DEBUG] Transaction fields: deal=%d, order=%d, symbol=%s, magic=%d, price=%f, volume=%f, entryType=%d, positionId=%d", 
        trans.deal, trans.order, HistoryDealGetString(trans.deal, DEAL_SYMBOL), HistoryDealGetInteger(trans.deal, DEAL_MAGIC),
        HistoryDealGetDouble(trans.deal, DEAL_PRICE), HistoryDealGetDouble(trans.deal, DEAL_VOLUME),
        HistoryDealGetInteger(trans.deal, DEAL_ENTRY), HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID));
    // Only process closed positions for this EA and symbol and ticket
    if(trans.type == TRADE_TRANSACTION_DEAL_ADD) {
        ulong deal = trans.deal;
        string dealSymbol = HistoryDealGetString(deal, DEAL_SYMBOL);
        long dealMagic = HistoryDealGetInteger(deal, DEAL_MAGIC);
        long entryType = HistoryDealGetInteger(deal, DEAL_ENTRY);
        ulong positionId = HistoryDealGetInteger(deal, DEAL_POSITION_ID);
        long reason = HistoryDealGetInteger(deal, DEAL_REASON);
        string reasonStr = "OTHER";
        if(reason == DEAL_REASON_SL) reasonStr = "SL";
        else if(reason == DEAL_REASON_TP) reasonStr = "TP";
        PrintFormat("[DEBUG] DEAL_ADD: deal=%d, symbol=%s, magic=%d, entryType=%d, positionId=%d, openPositionTicket=%d, reason=%d (%s)", deal, dealSymbol, dealMagic, entryType, positionId, ea.openPositionTicket, reason, reasonStr);
        if(dealSymbol == _Symbol && dealMagic == Magic) {
            if(entryType == DEAL_ENTRY_OUT && positionId == ea.openPositionTicket && ea.openPositionTicket != 0) { // Only closing deals for our ticket
                PrintFormat("[DEBUG] Position closed detected. Reason: %s (code=%d)", reasonStr, reason);
                ea.OnPositionClosed(reasonStr);
                PrintFormat("[DEBUG] After OnPositionClosed: flagPlaceFirstEntry=%d, flagPlaceReplacement=%d", ea.flagPlaceFirstEntry, ea.flagPlaceReplacement);
                ea.openPositionTicket = 0; // Reset ticket after closure
            } else {
                PrintFormat("[DEBUG] Not our closing deal or not matching ticket. entryType=%d, positionId=%d, openPositionTicket=%d", entryType, positionId, ea.openPositionTicket);
            }
        } else {
            Print("[DEBUG] Deal not for this EA or symbol.");
        }
    }
    Print("[DEBUG] OnTradeTransaction END");
}

   // Called by OnTradeTransaction when a position is closed
   void OnPositionClosed(string reasonStr) {
      PrintFormat("[DEBUG] OnPositionClosed called. reasonStr=%s, replacementScore=%d, flagPlaceFirstEntry=%d, flagPlaceReplacement=%d", reasonStr, replacementScore, flagPlaceFirstEntry, flagPlaceReplacement);
      if(reasonStr == "TP" || replacementScore == 0) {
         Print("[DEBUG] Position closed for TP or max replacements. Resetting logic.");
         flagPlaceFirstEntry = true;
         flagPlaceReplacement = false;
         replacementScore = replacementScoreMax;
         firstEntry.Reset();
         PrintFormat("[DEBUG] After TP/max reset: flagPlaceFirstEntry=%d, flagPlaceReplacement=%d", flagPlaceFirstEntry, flagPlaceReplacement);
      } else if(reasonStr == "SL") {
         Print("[DEBUG] Position closed for SL.");
         if(replacementScore > 0) {
            Print("[DEBUG] SL detected, placing replacement order.");
            flagPlaceFirstEntry = false;
            flagPlaceReplacement = true;
            // Do NOT reset firstEntry here, so replacement uses original entry params
            replacementScore--;
            PrintFormat("[DEBUG] After SL replacement: flagPlaceFirstEntry=%d, flagPlaceReplacement=%d, replacementScore=%d", flagPlaceFirstEntry, flagPlaceReplacement, replacementScore);
         } else {
            Print("[DEBUG] SL detected, but no more replacements allowed. Resetting logic.");
            flagPlaceFirstEntry = true;
            flagPlaceReplacement = false;
            replacementScore = replacementScoreMax;
            firstEntry.Reset();
            PrintFormat("[DEBUG] After SL/max reset: flagPlaceFirstEntry=%d, flagPlaceReplacement=%d", flagPlaceFirstEntry, flagPlaceReplacement);
         }
      }
   }

   void LogicLoop() {
      PrintFormat("[DEBUG] LogicLoop called. flagPlaceFirstEntry=%d, flagPlaceReplacement=%d", flagPlaceFirstEntry, flagPlaceReplacement);
      if(flagPlaceFirstEntry) {
         Print("[DEBUG] Attempting PlaceFirstEntryOrder");
         if(PlaceFirstEntryOrder()) {
            flagPlaceFirstEntry = false;
            flagPlaceReplacement = false;
         }
      } else if(flagPlaceReplacement) {
         Print("[DEBUG] Attempting PlaceReplacementOrder");
         if(PlaceReplacementOrder()) {
            flagPlaceFirstEntry = false;
            flagPlaceReplacement = false;
         }
      }
   }

   bool PlaceFirstEntryOrder() {
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
         firstEntry.Save(price, sl, tp, lot);
         openPositionTicket = res.order; // Save the ticket of the opened position
         lastEntryPrice = price;
         lastSL = sl;
         lastTP = tp;
         return true;
      } else {
         Print("[SimpleOneTradeEA] OrderSend failed for all filling modes. Retcode:", res.retcode);
         return false;
      }
   }

   bool PlaceReplacementOrder() {
      // Use saved first entry params
      double price = firstEntry.entryPrice;
      double sl = firstEntry.sl;
      double tp = firstEntry.tp;
      double lot = firstEntry.lot;
      MqlTradeRequest req;
      ZeroMemory(req);
      MqlTradeResult res;
      ZeroMemory(res);
      req.action = TRADE_ACTION_PENDING;
      req.symbol = _Symbol;
      req.volume = lot;
      req.type = ORDER_TYPE_BUY_STOP;
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
         return true;
      } else {
         Print("[SimpleOneTradeEA] Replacement order send failed for all filling modes. Retcode:", res.retcode);
         return false;
      }
   }
};

//--- Global EA instance
SimpleOneTradeEA ea;

int OnInit() {
   ea.OnInit();
   return(INIT_SUCCEEDED);
}

void OnTick() {
   ea.OnTick();
}
