# InterfaceGui for One Trade EA (MT5)

## Overview
This document describes the graphical interface (InterfaceGui) for the One Trade EA on MetaTrader 5, detailing what is feasible to implement in MQL5 and what is not, as well as the exact functionalities of all interface buttons.

---

## What is Realizable in MT5/MQL5
- **Panels, labels, and grouping:** Using `OBJ_RECTANGLE_LABEL`, `OBJ_LABEL`.
- **Text/numeric input fields:** Using `OBJ_EDIT` for user input (lot size, SL, times, etc.).
- **ComboBox/RadioButton:** Simulated using multiple `OBJ_BUTTON` or toggling states for Buy/Sell selection.
- **Buttons:** Using `OBJ_BUTTON` for actions (Start EA, Replace Order).
- **Status display:** Using `OBJ_LABEL` for showing EA status, trade info, and replacements left.
- **Basic chart drawing:** Entry, SL, TP lines and markers using `OBJ_TREND`, `OBJ_ARROW`, etc.
- **Event handling:** All user actions (button clicks, input changes) handled via `OnChartEvent()`.

## What is NOT Realizable in MT5/MQL5
- **Native sliders, dropdowns, or time pickers:** Must use text input and validate format.
- **HTML/CSS styling, advanced animations, overlays, popups.**
- **Drag-and-drop, resizing, or complex layouts.**
- **File dialogs, browser-like navigation, or web widgets.**
- **Direct import of HTML mockup—must be manually translated to chart objects.**

---

## Interface Elements and Their Mapping
| Requirement         | MT5 Control Type      | Notes/Best Practice                |
|---------------------|----------------------|------------------------------------|
| Mode                | ComboBox/RadioButton | Use two buttons or a dropdown      |
| Lot Size            | Edit/Text Input      | Numeric validation                 |
| Stop Loss           | Edit/Text Input      | Numeric validation                 |
| Risk/Reward         | Edit/Text Input      | Numeric validation                 |
| Opening/Closing Time| Edit/Text Input      | Validate format (HH:MM[:SS])       |
| Max Replacements    | Edit/Text Input      | Integer validation                 |
| Time Window         | Edit/Text Input      | Validate format (HH:MM)            |
| Status              | Label/Text           | Display current EA state           |
| Buttons             | Button               | See below for details              |

---

## Button Functionalities

### 1. Start EA Button
- **Purpose:** Initialize and start the EA with all user-configured parameters.
- **User Action:** Click to start trading after setting all inputs.
- **Implementation:**
  - Collect all input values from the interface (mode, lot, SL, risk, reward, times, replacements, time window).
  - Validate all inputs (numeric, time format, logical constraints).
  - Call `coreEA.Init(...)` with collected parameters.
  - Set EA state to running, lock inputs, and update status display.
  - Optionally call `OnInit()` if using standard EA lifecycle.
- **Event Handling:**
  - In `OnChartEvent()`, detect click on Start EA button.
  - Read values from `OBJ_EDIT` fields and ComboBox/RadioButton.
  - Pass values to core logic.

### 2. Replace Order Button
- **Purpose:** Manually trigger a replacement trade (pending order) after SL, if allowed.
- **User Action:** Click to force a replacement order (only enabled if replacements left > 0 and not in time window).
- **Implementation:**
  - On click, check if replacement is allowed (replacements left, time window).
  - Call `coreEA.OpenPendingOrder(entryPrice, sl)` with last trade’s entry and SL.
  - Update status display and replacements left.
- **Event Handling:**
  - In `OnChartEvent()`, detect click on Replace Order button.
  - Call core logic for pending order placement.

---

## Example Event Handling (MQL5)
```mql5
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
  if(id == CHARTEVENT_OBJECT_CLICK)
  {
    if(sparam == "StartEAButton")
    {
      // Read all input fields
      // Call coreEA.Init(...)
      // Set EA running state
    }
    else if(sparam == "ReplaceOrderButton")
    {
      // Call coreEA.OpenPendingOrder(...)
    }
  }
}
```

---

## Summary
---

## Final Implementation Checklist & Readiness Report

### 1. User Inputs
- [x] All required inputs (mode, lot size, SL, risk/reward, times, replacements, time window) are listed and mapped to MT5 chart objects.
- [x] Validation rules for each input (numeric, time format, logical constraints) are defined.

### 2. UI Controls
- [x] Feasible controls (edit fields, buttons, labels) are described and mapped.
- [x] Non-feasible controls (sliders, dropdowns, overlays) are clearly excluded.

### 3. Event Handling
- [x] Event handling logic for all controls (button clicks, input changes) is described.
- [x] Example MQL5 event handler provided for button actions.

### 4. Core EA Integration
- [x] Connection between UI controls and core EA methods (`Init`, `OpenPendingOrder`) is described.
- [x] Status updates and locking of inputs after EA start are covered.

### 5. Documentation
- [x] All mappings, limitations, and button functionalities are documented in this file.

### 6. Readiness
- [x] No missing requirements or unclear mappings remain.
- [x] Ready to proceed with implementation of the graphical interface in MT5.

---

**Conclusion:**
All requirements for the graphical interface are documented and mapped. The project is ready for implementation in MT5. No missing elements or blockers remain.
- All feasible controls are mapped to MT5 chart objects.
- Buttons are connected to core EA logic via event handling.
- Advanced HTML features are not supported; use only what is possible in MQL5.
