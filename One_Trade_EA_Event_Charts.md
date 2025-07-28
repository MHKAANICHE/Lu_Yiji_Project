---

## 6. Graphical Features: State Management and Shadowing

This section details how graphical features (buttons, input fields, panels) are enabled, disabled, or shadowed based on the EA's state and trading situation, according to the strategy logic.

### State Variables
- `isTradeActive`: True if a trade is currently open.
- `isPendingOrderActive`: True if a pending order is active.
- `isInTimeWindow`: True if the current time is within the no-trade time window.
- `replacementsLeft`: Number of allowed pending order replacements remaining.
- `isEAEnabled`: True if the EA is running and monitoring the market.

### Graphical Features and Their States

| Feature                        | Enabled When                                      | Disabled/Shadowed When                                 |
|--------------------------------|---------------------------------------------------|--------------------------------------------------------|
| Start/Activate EA Button       | No trade is active, not in time window            | Trade active, in time window, or EA already running    |
| Buy/Sell Mode Toggle           | No trade or pending order active                  | Trade or pending order active                          |
| Lot Size/SL/TP Input Fields    | No trade or pending order active                  | Trade or pending order active                          |
| Opening/Closing Time Pickers   | No trade or pending order active                  | Trade or pending order active                          |
| Time Window Selector           | No trade or pending order active                  | Trade or pending order active                          |
| Replace Order Button           | Trade hit SL, replacementsLeft > 0, not in window | No replacements left, in time window                   |
| Status Panel                   | Always enabled                                   | Always enabled                                         |
| Visual Markers (Entry/SL/TP)   | Trade or pending order active                     | No trade or pending order active                       |
| Shadow Overlay/Message         | In time window, or during trade/pending order     | Not in time window, no trade/pending order             |

### Example State Transitions
- When a trade is opened, all input fields and mode toggles are disabled (shadowed) until the trade is closed or the daily cycle ends.
- If the EA enters the time window, all trading actions are disabled and a shadow overlay/message is shown.
- When a pending order is placed, input fields remain disabled until the order is triggered or removed.
- If the maximum number of replacements is reached, the Replace Order button is disabled.
- The status panel always displays the current state (active trade, pending order, replacements left, time window status, etc.).

---

### Graphical Features and Their State During a Trade

During an active trade (from entry until closure or stop loss):
- **All input fields (lot size, SL, TP, times, mode) are disabled** to prevent changes that could disrupt the strategy.
- **Buy/Sell mode toggle is disabled** to lock the chosen direction.
- **Replace Order button is enabled only if the trade hits SL and replacements are available.**
- **Visual markers (entry, SL, TP lines) are shown on the chart** to indicate the trade’s parameters.
- **Status panel is updated in real time** to show trade status, PnL, and remaining replacements.
- **If the time window is entered during a trade, a shadow overlay/message is displayed** and no new trades or replacements are allowed until the window ends.

This ensures the user interface always reflects the current strategy state, prevents invalid actions, and guides the user through the allowed workflow.
# One Trade EA - Comprehensive Event & UI Flow Charts

This document provides detailed charts covering all aspects of the client requirements, including live trading setup (with graphical/chart tools), backtest setup, and the full event logic for the One Trade EA.

---

## 1. Live Trading Setup (with Graphical Tools)

```mermaid
graph TD
    A["User Loads EA on Chart"] --> B["Input Menu/Panel Displayed"]
    B --> C["User Sets: Buy/Sell Mode, Lot Size, SL, TP as R:R, Opening Time, Closing Time, Max Replacements, Time Window"]
    C --> D["Graphical Tools on Chart"]
    D --> D1["Buy/Sell Mode Toggle Button"]
    D --> D2["Lot Size/SL/TP Input Fields"]
    D --> D3["Opening/Closing Time Pickers"]
    D --> D4["Time Window Range Selector"]
    D --> D5["Visual Markers for Entry, SL, TP"]
    D --> D6["Status Panel: Next Trade, Active Orders, Replacements Left"]
    D --> E["User Confirms Settings"]
    E --> F["EA Starts Monitoring Time & Market"]
```

---

## 2. Daily Trading & Order Management Logic

```mermaid
graph TD
    A["EA Monitoring"] --> B{"Opening Time Reached?"}
    B -- No --> A
    B -- Yes --> C["Place First Trade: Buy or Sell"]
    C --> D["Draw Entry, SL, TP Lines on Chart"]
    C --> E{"Trade Hits TP?"}
    E -- Yes --> F["Trade Closed, Mark on Chart"]
    E -- No --> G{"Trade Hits SL?"}
    G -- No --> H{"Closing Time Reached?"}
    H -- No --> G
    H -- Yes --> I["Close Trade, Mark on Chart"]
    G -- Yes --> J["Place Pending Order: Same Entry, SL, Lot"]
    J --> K["Draw Pending Order Marker"]
    K --> L{"Pending Order Triggered?"}
    L -- No --> M{"Closing Time Reached?"}
    M -- No --> L
    M -- Yes --> N["Remove Pending Order, Remove Marker"]
    L -- Yes --> O{"Pending Order Hits SL?"}
    O -- Yes --> P{"Replacements Left?"}
    P -- Yes --> J
    P -- No --> Q["No More Orders, Mark on Chart"]
    O -- No --> R{"Pending Order Hits TP?"}
    R -- Yes --> S["Trade Closed, Mark on Chart"]
    R -- No --> M
```

---

## 3. Time Window Logic

```mermaid
graph TD
    A[Current Time] --> B{Within Time Window?}
    B -- Yes --> C[Disable New/Replacement Orders]
    B -- No --> D[Allow Trading Logic]
```

---

## 4. Backtest Setup & Output

```mermaid
graph TD
    A["User Opens Backtest Panel"]
    A --> B["Set Parameters: Buy/Sell, Lot, SL, TP, Times, Opening/Closing Time, Time Window"]
    B --> C["Run Backtest"]
    C --> D["Simulate Daily Trading Logic"]
    D --> E["Record Each Trade: Open/Close in Memory"]
    E --> F["On Completion: Generate Unique CSV File"]
    F --> G["CSV Columns: Entry Time, Type, Lot, Entry, SL, TP, Exit Time, Exit, Result, etc."]
    F --> H["Show Backtest Results: Stats, Equity Curve, Trade List"]
```

---

## 5. Recap: Daily Reset

```mermaid
graph TD
    A[End of Day] --> B[Reset EA State]
    B --> C[Prepare for Next Day: Await Opening Time]
```

---

*These charts now cover all required aspects: live trading setup (with graphical/chart tools), full event logic, time window, backtest setup, and output details, as well as daily reset behavior.*
