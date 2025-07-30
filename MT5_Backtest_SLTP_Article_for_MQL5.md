
# Robust SL/TP Detection in MetaTrader 5 Backtesting: Limitations and Professional Solutions


## Introduction
This article is intended for EA developers, quantitative researchers, and anyone working with MetaTrader 5 (MT5) backtesting. While MT5's Strategy Tester is a powerful tool for algorithmic trading, it presents unique challenges—especially in reliably detecting Stop Loss (SL) and Take Profit (TP) events during backtesting. Here, we provide technical insights, practical workarounds, and a community-driven solution for SL/TP detection in MT5.

For further reading, see:
- [MetaTrader 5 Documentation: OnTradeTransaction](https://www.metatrader5.com/en/terminal/help/algotrading/mql5standardlibrary#ontradetransaction)
- [MQL5 Forum: Strategy Tester Limitations](https://www.mql5.com/en/forum)


## The Challenge: Event-Driven Limitations in MT5 Backtesting
In live trading, MT5 offers event handlers such as `OnTradeTransaction` to respond to trade events, including SL and TP closures. However, in the Strategy Tester (backtest mode), these events are not triggered. Additionally, trade/deal history functions (`HistoryDealsTotal()`, `HistoryDealGetTicket()`, etc.) are not updated until after the tick in which the position is closed. As a result, an EA cannot reliably detect the closure reason (SL/TP) by scanning the deal history in the same tick. This behavior is different from MetaTrader 4 (MT4), where event-driven logic is more reliable in backtesting.

#### Example Log Output
```
[DEBUG] CheckForActivePosition called. PositionsTotal=0
[DEBUG] No active position for this EA and symbol.
[DEBUG] [Backtest] Entering SL/TP detection block
[DEBUG] [Backtest] HistoryDealsTotal=0, lastClosedTicket=0, openPositionTicket=0
... (position closed, but deal history not updated yet)
```


## Why This Matters for EA Developers
For professional EA development, especially for strategies that depend on precise SL/TP event handling, this limitation can lead to unreliable backtest results. Logic that works in live trading may fail in the Strategy Tester, undermining confidence in backtest outcomes and strategy validation. This is especially important for strategies involving partial closes, slippage, or complex order types, which may not be accurately reflected by simple price-based detection.


## Practical Workaround: Price-Based SL/TP Detection
Since event-driven and history-based detection are unreliable in backtesting, a practical workaround is to infer the closure reason by comparing the entry price, SL, TP, and the actual close price:

- **For BUY positions:**
  - If the close price is below the entry price, it is likely an SL.
  - If the close price is above the entry price, it is likely a TP.
- **For SELL positions:**
  - If the close price is above the entry price, it is likely an SL.
  - If the close price is below the entry price, it is likely a TP.

### Limitations of the Workaround
This method is not perfect and may misclassify trades in volatile markets, with partial closes, or when slippage occurs. It is not suitable for all strategies, especially those with complex exit logic. For mission-critical strategies, always validate backtest logic against live trading behavior and document any limitations for clients or users.

---

## Community Solution: Open-Source Library Proposal

To benefit the MT5 developer community, we propose an open-source MQL5 library dedicated to robust SL/TP detection in backtesting. This library would:

- Implement price-based SL/TP detection logic as described above
- Provide easy-to-use functions for integration into any EA
- Include documentation and example usage for quick adoption
- Be open for contributions and improvements from the community


### Library Concept & Example

The proposed library would be a single `.mqh` include file, offering a function such as:

```mql5
// Example: SLTP_Detector.mqh
enum SLTPResult { SL, TP, UNKNOWN };

SLTPResult DetectSLTP(double entryPrice, double closePrice, int direction)
{
    // direction: 0=Buy, 1=Sell
    if(direction==0) {
        if(closePrice < entryPrice) return SL;
        if(closePrice > entryPrice) return TP;
    } else {
        if(closePrice > entryPrice) return SL;
        if(closePrice < entryPrice) return TP;
    }
    return UNKNOWN;
}
```

**Usage Example:**

```mql5
#include <SLTP_Detector.mqh>

// ... in your EA code ...
SLTPResult result = DetectSLTP(entryPrice, closePrice, direction);
if(result == SL) Print("Closed by Stop Loss");
if(result == TP) Print("Closed by Take Profit");
```

Edge cases such as partial closes, slippage, and exotic order types should be handled with additional logic as needed.


This approach can be extended with additional parameters, logging, and documentation. Community feedback and contributions are welcome to make it robust and widely usable.


### Demo EA Available

A simple demo EA ([SimpleSLTPDemoEA.mq5](./SimpleSLTPDemoEA.mq5)) is available for download in this repository. It demonstrates how to use the SLTP_Detector function in practice: opening a trade at start and placing a pending order if the position is closed by SL. Feel free to download, test, and modify the EA to suit your needs.

**We encourage public interaction!**

- Share your feedback, improvements, and results in the comments or via [GitHub Issues](https://github.com/MHKAANICHE/Lu_Yiji_Project/issues).
- Suggest new features or report issues.
- Help us build a more reliable backtesting toolkit for the MT5 community.

If you are interested in collaborating or testing this solution, please comment below or reach out directly. Together, we can improve the reliability of MT5 backtesting for all developers.

---

## Conclusion
MT5's Strategy Tester has inherent limitations for event-driven SL/TP detection. By sharing knowledge and collaborating on open-source solutions, we can help the community achieve more reliable backtesting and EA development. If you have faced similar challenges or have ideas for improvement, please share your experience or solutions in the comments below!
