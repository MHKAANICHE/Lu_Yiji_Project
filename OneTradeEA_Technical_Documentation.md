## 15. Intellectual Property and Licensing (Optional)

- All intellectual property (IP) rights for the OneTradeEA project are rewarded to LU YIJI.
- The code is developed and authored by MH KAANICHE.
- (Optional) Add further licensing terms or copyright notices if required by the client or for distribution.
| Intellectual Property / Licensing | Optional    | See Section 15                              |
---

**Intellectual Property:**
- All IP rights for this EA are rewarded to LU YIJI.
- Code developed by MH KAANICHE.
## 0B. Final Optional/Advanced Considerations (Ultimate Review)

The following points are not explicitly required by the client but are recommended for a robust, professional EA. They are marked as **optional** unless found in the original requirements:

- **Test Cases/Acceptance Criteria:** Optional, not in client requirements.
- **Dependencies/Environment:** Optional, not in client requirements.
- **Rollback/Recovery:** Optional, not in client requirements.
- **Security/Trade Protection:** Optional, not in client requirements.
## 11. Test Cases and Acceptance Criteria (Optional)

Below is a recommended list of test cases to ensure all requirements and edge cases are validated:

- Open trade at correct time
- No trade outside allowed window
- Trade replaced after SL, up to max replacements
- No replacement after TP or max replacements
- Error on invalid input parameters
- Logging of all trade events
- Graphical/chart updates on trade events (planned)
- CSV log file created and updated (planned)
- Handles broker order rejection gracefully
- Handles network failure gracefully
- Only manages trades with EA’s magic number

Acceptance criteria: All above scenarios pass in both live and backtest modes.
## 12. Dependencies and Environment (Optional)

- Requires MetaTrader 5 (MT5), recommended build: latest stable
- Compatible with Windows (official), Linux/Wine (community, not guaranteed)
- Requires write permissions for CSV logging (planned)
- No external libraries required
## 13. Rollback and Recovery (Optional)

- (Optional) On MT5 or EA crash/restart, EA will re-scan open trades by magic number and restore state
- (Optional) Log files can be used to reconstruct trade history
## 14. Security and Trade Protection (Optional)

- EA only manages trades with its unique magic number
- (Optional) Add checks to prevent unauthorized trade manipulation
- (Optional) Add password or user confirmation for sensitive actions
## 10C. Ultimate Summary Table of Coverage

| Area                        | Status      | Recommendation/Notes                         |
|-----------------------------|-------------|----------------------------------------------|
| Class Diagrams/Data Flow    | Added       | See Section 2A                              |
| Parameter Validation        | Added       | See Section 2B                              |
| State Management            | Added       | See Section 2C                              |
| Localization                | Optional    | See Section 2F                              |
| Performance                 | Optional    | See Section 2E, 4E                          |
| Security/Risk Controls      | Added       | See Section 2D, 14                          |
| Deployment/Usage            | Optional    | See Section 2G                              |
| Versioning/Changelog        | Optional    | See Section 2H                              |
| Trade Logic Pseudocode      | Optional    | See Section 3A                              |
| Error Handling Scenarios    | Optional    | See Section 4A                              |
| User Interaction/Override   | Optional    | See Section 4B                              |
| Logging Granularity         | Optional    | See Section 4C                              |
| Integration/Compatibility   | Optional    | See Section 4D                              |
| Resource Usage              | Optional    | See Section 4E                              |
| Test Cases/Acceptance       | Optional    | See Section 11                              |
| Dependencies/Environment    | Optional    | See Section 12                              |
| Rollback/Recovery           | Optional    | See Section 13                              |
## 0A. Additional Optional/Advanced Considerations (Final Review)

The following points are not explicitly required by the client but are recommended for a robust, professional EA. They are marked as **optional** unless found in the original requirements:

- **Trade Logic Pseudocode/Flowchart:** Optional, but highly recommended for clarity.
- **Error Handling Scenarios:** Optional, unless specific error cases are in requirements.
- **User Interaction/Manual Override:** Optional, not in client requirements.
- **Logging Granularity/Management:** Optional, not in client requirements.
- **Integration/Compatibility:** Optional, not in client requirements.
- **Resource Usage:** Optional, not in client requirements.
## 3A. Trade Logic Pseudocode/Flowchart (Optional)

**Pseudocode for Main Trade Loop:**

```
OnTick:
  if not in trading window:
    return
  if new day:
    reset trade state
  if no trade active and open time reached:
    open first trade
  if trade active:
    monitor for SL/TP
    if SL hit and replacements left:
      open replacement trade
    if TP hit or replacements exhausted:
      end trading for day
  log all events
  update UI (planned)
```

**Flowchart:** See mermaid diagrams in `One_Trade_EA_Event_Charts.md` for detailed event flows.
## 4A. Error Handling Scenarios (Optional)

- **Order Rejection:** Log error, skip trading for the day or retry if safe.
- **Network Failure:** Log error, attempt recovery if possible.
- **Partial Fills:** Log warning, monitor remaining volume.
- **Parameter Error:** Log and halt or skip trading.
- **Margin/Account Error:** Log and halt trading.
- **Unknown Error:** Log and alert user (planned via UIManager).
## 4B. User Interaction/Manual Override (Optional)

- The EA is designed for automated operation.
- (Optional) Manual override features (pause, close trade, adjust parameters at runtime) can be added if required.
## 4C. Logging Granularity and Management (Optional)

- Logging will include info, warning, and error levels (planned).
- (Optional) Log rotation or size management can be implemented for long-term operation.
## 4D. Integration and Compatibility (Optional)

- The EA is designed for MT5 and should work with most brokers and symbols.
- (Optional) Test with different account types (hedging/netting) and brokers for full compatibility.
## 4E. Resource Usage (Optional)

- The EA is lightweight, but graphical/chart features may increase resource usage.
- (Optional) Monitor memory and CPU usage if running on low-spec VPS or with many chart objects.
## 10B. Final Summary Table of Coverage

| Area                        | Status      | Recommendation/Notes                         |
|-----------------------------|-------------|----------------------------------------------|
| Class Diagrams/Data Flow    | Added       | See Section 2A                              |
| Parameter Validation        | Added       | See Section 2B                              |
| State Management            | Added       | See Section 2C                              |
| Localization                | Optional    | See Section 2F                              |
| Performance                 | Optional    | See Section 2E, 4E                          |
| Security/Risk Controls      | Added       | See Section 2D                              |
| Deployment/Usage            | Optional    | See Section 2G                              |
| Versioning/Changelog        | Optional    | See Section 2H                              |
| Trade Logic Pseudocode      | Optional    | See Section 3A                              |
| Error Handling Scenarios    | Optional    | See Section 4A                              |
| User Interaction/Override   | Optional    | See Section 4B                              |
| Logging Granularity         | Optional    | See Section 4C                              |
| Integration/Compatibility   | Optional    | See Section 4D                              |
| Resource Usage              | Optional    | See Section 4E                              |

# OneTradeEA Technical Documentation
## 0. Optional/Advanced Considerations

The following points are not explicitly required by the client but are recommended for professional, robust EA development. They are marked as **optional** unless found in the original requirements:

- **Localization/Internationalization:** Optional. Not in client requirements.
- **Performance Optimization:** Optional. Not in client requirements.
- **Deployment/Usage Instructions:** Optional. Not in client requirements, but referenced in README.
- **Versioning/Changelog:** Optional. Not in client requirements.
## 2A. Class Diagrams and Data Flow (Recommended)

**UML-style Class Diagram (Textual):**

```
OnInit/OnTick/OnDeinit
   |
   +-- TimeManager
   |
   +-- TradeManager
   |
   +-- Logger
   |
   +-- (Planned) UIManager
```

**Data Flow:**
- `OnTick` calls `TimeManager` for time checks, then delegates to `TradeManager` for trade logic.
- `TradeManager` logs events via `Logger` and (planned) updates UI via `UIManager`.
- All managers are independent, but may notify each other via method calls or observer pattern (planned).
## 2B. Parameter Validation and User Feedback

- All input parameters are validated at initialization.
- If invalid, the EA will log an error and (planned) display a message via `UIManager`.
- **Behavior:**
  - On critical error, EA may halt or skip trading for the day.
  - On non-critical error, EA will log and continue if safe.
## 2C. State Management and Concurrency

- MT5 EAs can be affected by asynchronous events (e.g., order fills, partial closes).
- The EA will use internal state variables (e.g., `tradeActive`, `pendingOrderActive`) to track status.
- (Planned) All state changes will be atomic and protected against race conditions.
- (Optional) Consider using event queues or observer pattern for complex state transitions.
## 2D. Security, Risk Controls, and Safety

- The EA will enforce max trades per day and max replacements as per requirements.
- (Optional) Add max daily loss, max risk per account, and other safety checks for professional robustness.
- All order placement will check for sufficient margin and account status.
## 2E. Performance Considerations (Optional)

- For most use cases, performance is not a bottleneck, but graphical/chart updates and logging will be optimized to avoid excessive resource use.
- (Optional) Throttle graphical updates and log writes if running in high-frequency environments.
## 2F. Localization and Internationalization (Optional)

- All messages and UI elements are in English by default.
- (Optional) Add support for multiple languages if required by future users.
## 2G. Deployment and Usage (Optional)

- See `README.md` for installation and usage instructions.
- (Optional) Add a dedicated deployment section if distributing to end users.
## 2H. Versioning and Change Management (Optional)

- (Optional) Use semantic versioning and maintain a changelog for all releases.
## 10A. Summary Table of Coverage

| Area                        | Status      | Recommendation/Notes                         |
|-----------------------------|-------------|----------------------------------------------|
| Class Diagrams/Data Flow    | Added       | See Section 2A                              |
| Parameter Validation        | Added       | See Section 2B                              |
| State Management            | Added       | See Section 2C                              |
| Localization                | Optional    | See Section 2F                              |
| Performance                 | Optional    | See Section 2E                              |
| Security/Risk Controls      | Added       | See Section 2D                              |
| Deployment/Usage            | Optional    | See Section 2G                              |
| Versioning/Changelog        | Optional    | See Section 2H                              |

## 1. Overview

OneTradeEA is a modular, object-oriented Expert Advisor (EA) for MetaTrader 5 (MT5) designed to implement a time-based, single-trade-per-day strategy with optional trade replacement, robust time window logic, and extensible logging and graphical/chart features. The EA is structured for maintainability, clarity, and future extensibility.

## 2. Requirements Traceability

### 2.1. Event Flow (Mermaid Diagrams)
- The event flows and edge cases are fully documented in `One_Trade_EA_Event_Charts.md` using mermaid diagrams. These diagrams define:
  - Daily initialization and reset
  - Time window checks
  - Trade opening, monitoring, and replacement logic
  - Error and edge case handling
  - Logging and graphical/chart update events
- **Mapping:** Each event in the diagrams is mapped to a method or class in the code (see Section 3).

### 2.2. UI Mockups (HTML)
- The HTML mockups (`One_Trade_EA_UI_Mockup.html`, `One_Trade_EA_UI_Compact.html`) serve as blueprints for the planned graphical/chart features in MT5.
- **Planned Implementation:**
  - Info panels, trade status, and controls will be implemented as chart objects in MT5.
  - The OOP structure will be extended with a `UIManager` or similar class to encapsulate all graphical/chart logic.
  - User feedback and error messages will be surfaced visually, following the pedagogic and visually appealing style of the HTML mockups.

## 3. Code Structure and OOP Design

### 3.1. Main Components

- **Input Parameters:** All configurable options (trade mode, lot size, stop loss, risk/reward, time windows, max replacements) are exposed as EA inputs.
- **OOP Managers:**
  - **TimeManager:** Handles all time parsing, time window checks, and daily reset logic.
  - **TradeManager:** Manages trade state, opening logic, replacement tracking, and will encapsulate all trade monitoring and management.
  - **Logger:** Handles logging to the MT5 terminal (and will be extended for CSV/backtest logging).
  - **(Planned) UIManager:** Will manage all graphical/chart features, mapping HTML UI elements to MT5 chart objects.
- **Event Functions:**
  - `OnInit()`: Initializes all managers and parses input parameters.
  - `OnTick()`: Delegates all per-tick logic to the managers, keeping the main loop clean.
  - `OnDeinit()`: Reserved for cleanup (currently minimal).

### 3.2. Class Responsibilities and Interfaces

#### TimeManager
- Parses and stores open/close and window times.
- Checks if the current time is within the allowed trading window.
- Detects new trading days for daily reset logic.
- **Interface:**
  - `void ParseTimes(string open, string close, string winStart, string winEnd)`
  - `bool IsInTimeWindow(datetime now)`
  - `bool IsNewDay(datetime now)`

#### TradeManager
- Tracks trade state (active, pending, replacements left).
- Generates a unique magic number per chart.
- Handles opening the first trade of the day.
- (Planned) Will manage trade monitoring, SL/TP detection, and replacement logic.
- **Interface:**
  - `void Init(int maxRepl, string symbol)`
  - `void Reset(int maxRepl)`
  - `void OpenFirstTrade()`
  - (Planned) `void MonitorTrades()`, `void HandleSLTP()`, `void ReplaceTrade()`

#### Logger
- Logs key events to the MT5 terminal.
- (Planned) Will support CSV logging for backtesting and analytics.
- **Interface:**
  - `void Log(string msg)`
  - (Planned) `void LogCSV(string[] fields)`

#### (Planned) UIManager
- Will manage all graphical/chart features, mapping HTML UI elements to MT5 chart objects.
- **Interface:**
  - `void DrawPanel()`
  - `void UpdatePanel()`
  - `void ShowError(string msg)`

### 3.3. Class Interactions
- `OnTick()` will call `TimeManager` for time checks, then delegate trade logic to `TradeManager`, and log events via `Logger`.
- (Planned) `TradeManager` will notify `UIManager` and `Logger` on trade events.

## 4. Error Handling and Robustness

- All input parameters will be validated at initialization.
- Order placement, time parsing, and trade monitoring will include error checks.
- Errors will be logged via `Logger` and surfaced to the user via `UIManager` (planned).
- (Planned) Consider a dedicated `ErrorManager` or error codes for robust error propagation.

## 5. Backtest and Live Mode Support

- The EA will detect the environment (live vs. backtest) and adapt logging and graphical/chart features accordingly.
- CSV logging will be enabled in backtest mode for analytics.
- Graphical/chart features will be active only in live trading.

## 6. Extensibility and Design Patterns

- The OOP structure allows for easy addition of new features:
  - New managers (e.g., `UIManager`, analytics modules).
  - Additional trade strategies via the Strategy pattern.
  - Observer pattern for event-driven updates (e.g., trade events triggering UI/log updates).
- Interfaces and abstract base classes will be used to ensure future growth does not break existing code.

## 7. Trade Logic and Event Mapping

- **Trade Opening:**
  - At the specified open time, if no trade is active, `TradeManager.OpenFirstTrade()` is called.
  - Order parameters (type, lot, SL, TP) are calculated based on input and risk/reward.
- **Trade Monitoring:**
  - (Planned) `TradeManager.MonitorTrades()` will check for SL/TP hits and manage replacements.
  - Replacement logic will follow the event flows in the mermaid diagrams.
- **Edge Cases:**
  - All edge cases (e.g., missed open time, order rejection, time window violations) are documented in the mermaid diagrams and will be handled in code.

## 8. CSV Logging

- (Planned) Logger will support CSV output for all trade events.
- **Schema:**
  - Fields: Date, Time, Symbol, TradeType, Lot, SL, TP, Result, Replacement#, ErrorCode, etc.
- **Triggers:**
  - On trade open, close, SL/TP hit, error.

## 9. Graphical/Chart Features

- (Planned) UIManager will map HTML UI elements to MT5 chart objects:
  - Info panels for trade status, replacement count, and error messages.
  - Entry/exit markers on the chart.
  - Visual feedback for user actions and errors.
- **Update Logic:**
  - Panels and markers will update on trade events and time window changes.

## 10. Testing and Validation

- **Unit Testing:**
  - Each class will be tested in isolation (where possible in MQL5).
- **Backtesting:**
  - The EA will be validated in MT5 Strategy Tester with various scenarios (normal, edge cases, error conditions).
- **Scenario Validation:**
  - Test cases will be derived from the mermaid event flows to ensure all logic is covered.

## 11. References
- See `README.md` for user-facing documentation and usage.
- See `One_Trade_EA_Event_Charts.md` for detailed event flow diagrams.
- See HTML mockups for UI/UX blueprint.
- See code comments for further technical details.

---

**Status:**
- The foundation is in place for a robust, maintainable EA.
- Core trade management, monitoring, CSV logging, and graphical/chart features are the next priorities for implementation.
- All advanced/professional features are planned as optional unless required by the client.
