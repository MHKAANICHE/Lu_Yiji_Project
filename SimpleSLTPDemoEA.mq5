//+------------------------------------------------------------------+
//| SimpleSLTPDemoEA.mq5                                             |
//| Demo EA: Opens a trade at start and uses SLTP_Detector to place  |
//| a pending order when the position hits SL                        |
//+------------------------------------------------------------------+
#property copyright "GitHub Copilot"
#property version   "1.00"
#property strict

#include <SLTP_Detector.mqh>

input double LotSize = 0.10;
input int    TradeDirection = 0; // 0=Buy, 1=Sell
input double SL_Points = 200;
input double TP_Points = 400;
input int    Magic = 123456;

bool tradeOpened = false;
int mainTicket = -1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    tradeOpened = false;
    mainTicket = -1;
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(!tradeOpened)
    {
        double price = (TradeDirection == 0) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double sl = (TradeDirection == 0) ? price - SL_Points * _Point : price + SL_Points * _Point;
        double tp = (TradeDirection == 0) ? price + TP_Points * _Point : price - TP_Points * _Point;
        int ticket = OrderSend(_Symbol, (TradeDirection == 0) ? OP_BUY : OP_SELL, LotSize, price, 10, sl, tp, "FirstEntry", Magic, 0, clrBlue);
        if(ticket > 0)
        {
            tradeOpened = true;
            mainTicket = ticket;
        }
    }
    else
    {
        // Check if main position is closed
        ulong positionTicket = PositionGetTicket(0);
        if(mainTicket > 0 && PositionSelectByTicket(mainTicket) == false)
        {
            // Get last closed position info
            double entryPrice = 0, closePrice = 0;
            int direction = TradeDirection;
            for(int i=HistoryDealsTotal()-1; i>=0; i--)
            {
                ulong dealTicket = HistoryDealGetTicket(i);
                if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) == Magic)
                {
                    entryPrice = HistoryDealGetDouble(dealTicket, DEAL_ENTRY_PRICE);
                    closePrice = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
                    break;
                }
            }
            SLTPResult result = DetectSLTP(entryPrice, closePrice, direction);
            if(result == SL)
            {
                // Place pending order at same entry price
                double lot = LotSize;
                int orderType = (TradeDirection == 0) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
                double price = entryPrice;
                double sl = (TradeDirection == 0) ? price - SL_Points * _Point : price + SL_Points * _Point;
                double tp = (TradeDirection == 0) ? price + TP_Points * _Point : price - TP_Points * _Point;
                OrderSend(_Symbol, orderType, lot, price, 10, sl, tp, "Replacement", Magic, 0, clrRed);
            }
            // Reset EA state for demo (only one replacement)
            tradeOpened = false;
            mainTicket = -1;
        }
    }
}
