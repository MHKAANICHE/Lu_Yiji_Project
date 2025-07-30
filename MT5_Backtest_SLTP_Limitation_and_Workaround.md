# Robust SL/TP Detection in MetaTrader 5 Backtesting: Limitations and Workarounds

## Problem Statement
In MetaTrader 5 (MT5) backtesting, detecting whether a position was closed by Stop Loss (SL) or Take Profit (TP) is essential for robust event-driven Expert Advisor (EA) logic. However, the standard event-driven approach using `OnTradeTransaction` does not work in the MT5 Strategy Tester, as trade events are not triggered in backtest mode.

## MT5 Limitation
- **OnTradeTransaction is NOT called in the Strategy Tester.**
- The trade/deal history (`HistoryDealsTotal()`, `HistoryDealGetTicket()`, etc.) is not updated until after the tick in which the position is closed.
- This means that, immediately after a position is closed, the EA cannot reliably detect the closure reason (SL/TP) by scanning the deal history in the same tick.

### Log Proof
```
2025.07.30 17:44:37.445	2025.07.01 00:01:00   [DEBUG] CheckForActivePosition called. PositionsTotal=0
2025.07.30 17:44:37.445	2025.07.01 00:01:00   [DEBUG] No active position for this EA and symbol.
2025.07.30 17:44:37.445	2025.07.01 00:01:00   [DEBUG] [Backtest] Entering SL/TP detection block
2025.07.30 17:44:37.445	2025.07.01 00:01:00   [DEBUG] [Backtest] HistoryDealsTotal=0, lastClosedTicket=0, openPositionTicket=0
2025.07.30 17:44:37.445	2025.07.01 00:01:00   [DEBUG] LogicLoop called. flagPlaceFirstEntry=1, flagPlaceReplacement=0
2025.07.30 17:44:37.445	2025.07.01 00:01:00   [DEBUG] Attempting PlaceFirstEntryOrder
2025.07.30 17:44:37.445	2025.07.01 00:01:00   failed market buy 0.01 EURUSD sl: 1.17789 tp: 1.18089 [Unsupported filling mode]
2025.07.30 17:44:37.445	2025.07.01 00:01:00   market buy 0.01 EURUSD sl: 1.17789 tp: 1.18089 (1.17801 / 1.17889 / 1.17801)
2025.07.30 17:44:37.445	2025.07.01 00:01:00   deal #2 buy 0.01 EURUSD at 1.17889 done (based on order #2)
2025.07.30 17:44:37.445	2025.07.01 00:01:00   deal performed [#2 buy 0.01 EURUSD at 1.17889]
2025.07.30 17:44:37.445	2025.07.01 00:01:00   order performed buy 0.01 at 1.17889 [#2 buy 0.01 EURUSD at 1.17889]
2025.07.30 17:44:37.635	2025.07.01 00:01:30   stop loss triggered #2 buy 0.01 EURUSD 1.17889 sl: 1.17789 tp: 1.18089 [#3 sell 0.01 EURUSD at 1.17789]
2025.07.30 17:44:37.635	2025.07.01 00:01:30   deal #3 sell 0.01 EURUSD at 1.17729 done (based on order #3)
2025.07.30 17:44:37.635	2025.07.01 00:01:30   deal performed [#3 sell 0.01 EURUSD at 1.17729]
2025.07.30 17:44:37.635	2025.07.01 00:01:30   order performed sell 0.01 at 1.17729 [#3 sell 0.01 EURUSD at 1.17789]
2025.07.30 17:44:37.636	2025.07.01 00:01:30   [DEBUG] CheckForActivePosition called. PositionsTotal=0
2025.07.30 17:44:37.636	2025.07.01 00:01:30   [DEBUG] No active position for this EA and symbol.
2025.07.30 17:44:37.636	2025.07.01 00:01:30   [DEBUG] [Backtest] Entering SL/TP detection block
2025.07.30 17:44:37.636	2025.07.01 00:01:30   [DEBUG] [Backtest] HistoryDealsTotal=0, lastClosedTicket=0, openPositionTicket=2

```
- The deal history is empty (`HistoryDealsTotal=0`) right after the position is closed, so no SL/TP detection is possible at this point.

## Workaround: Price-Based SL/TP Detection
Since event-driven and history-based detection are unreliable in backtesting, a practical workaround is to infer the closure reason by comparing the entry price, SL, TP, and the actual close price:

- **For BUY positions:**
  - If the close price is below the entry price, it is likely an SL.
  - If the close price is above the entry price, it is likely a TP.
- This method is not perfect (e.g., for manual closures or partial closes), but is robust for simple EAs with fixed SL/TP.

## Implementation Steps
1. When a position is closed, record the entry price, SL, TP, and the close price.
2. Compare the close price to the entry price:
   - If `close < entry` (for BUY), treat as SL and set the replacement flag.
   - If `close > entry` (for BUY), treat as TP and reset logic.
3. Log the decision for transparency and debugging.

## Conclusion
- **MT5 Strategy Tester does not support event-driven SL/TP detection.**
- **Deal history is not available immediately after closure.**
- **Price-based inference is a practical and robust workaround for simple EAs.**

This approach ensures that the EA logic remains robust and traceable, even in the face of MT5 backtesting limitations.
