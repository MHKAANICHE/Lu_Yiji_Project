


<p align="center">
  <img src="https://c.mql5.com/i/docs/background_docs.png" alt="MetaTrader Logo" width="120" />
</p>

# One Trade EA Project
**Professional Automated Trading Solution for MetaTrader (UpWork Contract)**



## Project Overview

This repository contains the development of the "One Trade EA" (Expert Advisor) for MetaTrader platforms, designed to automate a disciplined, time-based trading strategy. Originally contracted via UpWork, the EA is built for reliability, transparency, and ease of analysis, with all graphical/UI code removed for a purely technical solution. The project aims to solve the challenge of single-trade execution, risk management, and robust backtesting for professional and institutional users.



### Key Features

- **Trade Mode:** Select Buy or Sell for the day.
- **Lot Size:** Configurable per trade.
- **Stop Loss (SL):** Set maximum dollar risk per trade.
- **Take Profit (TP):** Risk:Reward ratio, optional.
- **Opening/Closing Time:** Precise control over trade entry and exit.
- **Max Replacements:** Retry logic after SL, with pending orders at the same entry.
- **Time Window:** Disable replacements during specified periods.
- **CSV Logging:** All trades and events are logged for analysis in the MetaTrader `Files` directory.




---

## Quick Start & Onboarding

1. Clone or download this repository.
2. Review the EA source files and documentation below.
3. For MetaTrader 4/5, copy the EA files to your `Experts` directory and compile.
4. Run backtests and review CSV logs for analysis.
5. See the [MT5_Backtest_SLTP_Article_for_MQL5.md](./MT5_Backtest_SLTP_Article_for_MQL5.md) for advanced SL/TP detection and community resources.

For a detailed technical flow, see the [OrderFlags_TechnicalDoc.md](./OrderFlags_TechnicalDoc.md).

For an in-depth discussion, technical solutions, and community resources on SL/TP detection in MT5 backtesting, please read our dedicated MQL5 article: [MT5_Backtest_SLTP_Article_for_MQL5.md](./MT5_Backtest_SLTP_Article_for_MQL5.md).

---

## MT5 Backtesting Challenge

During development, a critical limitation was discovered in MetaTrader 5 (MT5) backtesting: the platform does not reliably trigger trade events (`OnTradeTransaction`) in the Strategy Tester, making it impossible to detect whether a position was closed by SL or TP in real time. This led to an untrusted solution for professional backtest execution.

Despite providing technical proofs and a price-based workaround ([see details](./MT5_Backtest_SLTP_Limitation_and_Workaround.md)), the client was dissatisfied and closed the contract. As a result, the EA was redeveloped for MetaTrader 4 (MT4), where event-driven logic is reliable.

---

## Outcome & Future Work

While the contract was closed unsuccessfully, this repository stands as a technical reference and proof of the challenges faced. The project demonstrates advanced EA design, robust state management, and transparent documentation.

**We are open for new projects and collaborations.**  
If you are a future contractor or client, feel free to reach out for EA development, trading automation, or technical consulting.

---


## Files & Documentation

- `OneTradeFlagEA.mq4`: MQL4 EA implementing the full flag-driven logic and daily reset.
- `OrderFlags_TechnicalDoc.md`: Technical flow diagrams, state management, and flag logic documentation.
- `MT5_Backtest_SLTP_Limitation_and_Workaround.md`: Explains MT5 backtesting limitations and technical workarounds.
- `SimpleOneTradeEA_CodeFlow.md`: Code flow and architecture for the simplified EA.
- `MT5_Backtest_SLTP_Article_for_MQL5.md`: In-depth article on SL/TP detection, community solutions, and demo EA resources.
- `README.md`: Project summary, onboarding, and context.


---


---

## Contact & Collaboration

We are open for new contracts, technical partnerships, and community contributions. For questions, proposals, or feedback:

- Email: [Click Here](mhkaaniche@gmail.com)
- GitHub Issues: [Lu_Yiji_Project Issues](https://github.com/MHKAANICHE/Lu_Yiji_Project/issues)

**CSV file location:** By default, the CSV file is created in the MetaTrader 5 `Files` directory.




---

## UI & Feedback

All graphical and UI code has been removed. The EA is now technical-only, focusing on robust automated trading and transparent logging for professional analysis.


## Files

- `OneTradeEA.mq5`: Main EA logic (technical-only). Place this file in your MetaTrader 5 `Experts` folder.
- `OneTradeEA_Core.mqh`: Core trading logic and CSV logging. Place this file in your MetaTrader 5 `Include` folder.



## How to Use

1. Place all files in your MetaTrader 5 `Experts` and `Include` directories as described above.
2. Attach the EA to a chart.
3. Configure all input parameters as desired (see above for format).
4. Run the EA for automated trading and backtesting.
5. Review CSV logs for trade history and results.


## Main Files Breakdown

- `OneTradeEA.mq5`: Main EA script. Handles EA lifecycle (`OnInit`, `OnTick`, `OnDeinit`) and calls core logic methods.
- `OneTradeEA_Core.mqh`: Implements the core trading logic in the `COneTradeEA_Core` class. Manages trade parameters, time windows, CSV logging, trade execution, monitoring, replacements, and closing.


## Technical Workflow Diagram

```mermaid
flowchart TD
    Start((Start / OnInit))
    WaitTick(Wait for OnTick)
    AtOpenTime{Is Open Time?}
    OpenTrade(Open First Trade)
    MonitorTrades(Monitor Trades - SL/TP)
    SLHit{SL Hit?}
    TPHit{TP Hit?}
    ReplaceAllowed{Replacements Left?}
    ReplaceTrade(Open Replacement Trade)
    NoReplace(No More Replacements)
    AtCloseTime{Is Close Time?}
    CloseAll(Close All Positions & Orders)
    ResetDay(New Day: Reset State)
    End((End / OnDeinit))

    Start --> WaitTick
    WaitTick --> AtOpenTime
    AtOpenTime -- No --> AtCloseTime
    AtOpenTime -- Yes --> OpenTrade
    OpenTrade --> MonitorTrades
    MonitorTrades --> SLHit
    SLHit -- Yes --> ReplaceAllowed
    SLHit -- No --> TPHit
    TPHit -- Yes --> NoReplace
    TPHit -- No --> AtCloseTime
    ReplaceAllowed -- Yes --> ReplaceTrade
    ReplaceAllowed -- No --> NoReplace
    ReplaceTrade --> MonitorTrades
    NoReplace --> AtCloseTime
    AtCloseTime -- Yes --> CloseAll
    AtCloseTime -- No --> ResetDay
    CloseAll --> ResetDay
    ResetDay --> WaitTick
    WaitTick --> End
```


## Client Requirements Coverage


### Client Requirements Coverage

- Buy/Sell mode selection
- Lot size and stop loss (dollar risk)
- Take profit as risk:reward (optional)
- Strictly time-based entry (no indicators or price action)
- Replacements after stop loss, with max count
- Time window disables replacements
- Daily reset and new trade each day
- All trades and events logged to unique CSV file



## Contact

For further customization or support, contact the project maintainer.