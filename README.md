# One Trade EA Project

## Overview

The One Trade EA is a MetaTrader 5 (MT5) Expert Advisor that automates a single trade per day, with advanced risk management, time-based logic, and a modern, user-friendly graphical interface. It is designed for both live trading and backtesting, with all parameters configurable via an intuitive control panel.

## Features & Logic

- **Buy/Sell Mode:** Choose the direction for the daily trade.
- **Lot Size:** Set the trade volume.
- **Stop Loss:** Define your risk in pips.
- **Risk:Reward (R:R):** Set your risk and reward in value, using a clear [1]:[2] format (e.g., 1.00:2.00).
- **Opening/Closing Time:** Control when the trade is opened and closed each day. Opening Time must be before Closing Time.
- **Max Replacements:** If a trade hits Stop Loss, the EA will automatically place a new pending order at the same entry, SL, and lot size. This repeats up to the Max Replacements value (e.g., if set to 2, the EA will try up to 2 additional times after the first loss).
- **Time Window:** Prevent new trades or replacements during a specified period. Time Window Start must be before Time Window End. Leave both empty to disable.
- **Magic Number:** Each EA instance is uniquely identified by a magic number based on the instrument and a random sequence, ensuring no interference between charts or instruments.
- **Instrument Digits & Pips Explanation:** The UI explains pip values and provides a pedagogic example for the current instrument, helping users avoid misconfiguration.
- **Status Panel:** Real-time feedback on trade status, pending orders, and replacements left.
- **Replace Order Button:** After the EA is started, if a trade hits Stop Loss and replacements are available, this button becomes active to manually trigger a new pending order as per the strategy.
- **Backtesting Support:** All logic is fully automated for backtesting, with CSV output for trade history. No interactive features are available in backtest mode; all parameters must be set as inputs.


## Visual Features & User Guidance

The EA's control panel is designed for clarity, error prevention, and ease of use. Key visual features include:

- **Instrument Info:** Shows the instrument, digits, current price, and a pedagogic example of what 100 pips means for that instrument.
- **Input Sections:** Each input (mode, lot size, stop loss, risk/reward, times, max replacements) is visually grouped, color-coded, and includes helper text.
- **Error Handling:** JavaScript-based validation provides instant feedback and error messages below each input if the user enters invalid values (e.g., negative lot size, opening time after closing time, etc.).
- **Shadowing/Locking:** Once the user clicks "Start EA" and inputs are valid, all input fields are disabled and a visual overlay appears, indicating the EA is running and settings are locked.
- **Replace Order Button:** Only enabled after the EA is started and a trade has hit Stop Loss, if replacements are still available.
- **Status Panel:** Always visible, showing the current state of the EA, including active trade, pending order, replacements left, and time window status.
- **Chart Area (for illustration):** Placeholder for where entry, SL, TP lines, and trade markers would be drawn on the MT5 chart.

### Responsive UI Mockups

Two HTML mockups are provided:

- **Full UI:** `One_Trade_EA_UI_Mockup.html` — for full-screen or large MT5 panels, with detailed layout and helper text.
- **Compact UI:** `One_Trade_EA_UI_Compact.html` — for retracted or small MT5 panels, fully responsive and optimized for limited space.

Both mockups use consistent color-coding, helper text, and error handling, and are ready to be adapted for MT5 graphical panel implementation.

## UI Mockup (HTML)

Below is a code block of the HTML mockup representing the desired graphical features for the EA's control panel (see the above files for the full code):

```html
<!-- One Trade EA - UI Mockup (see One_Trade_EA_UI_Mockup.html and One_Trade_EA_UI_Compact.html for full code) -->
<div class="container">
  ...existing code for all UI sections, as described above...
</div>
```

## How to Use

1. **Configure your trade:** Set the mode, lot size, stop loss, risk/reward, times, and max replacements using the control panel.
2. **Review the instrument info:** Check the digits and pip example to avoid misconfiguration.
3. **Monitor status:** The status panel provides real-time feedback on trade and EA state.
4. **Start the EA:** Click "Start EA" to lock in your settings and begin automated trading for the day.
5. **Replace Order:** If a trade hits Stop Loss and replacements are available, use the "Replace Order" button to manually trigger a new pending order as per the strategy.
6. **Backtesting:** All parameters can be set as inputs for automated backtesting. The EA will generate a CSV file for each run. No interactive features are available in backtest mode.

---

For more details, see the event flow charts and requirements documentation in `One_Trade_EA_Event_Charts.md`.