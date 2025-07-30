# SimpleOneTradeEA Code Flow Technical Document

## Overview
This document describes the code flow for the `SimpleOneTradeEA.mq5` Expert Advisor, which implements both the state loop and the logic loop as described in the project requirements. The EA uses OOP principles and manages trade entries and replacements using a clear flag and state system.

## Code Flow (Mermaid Diagram)

```mermaid
flowchart TD
    OnInit["OnInit()\nInitialize flags, score, and state"]
    OnTick["OnTick()\nMain loop on every tick"]
    CheckActive["CheckForActivePosition()\nIs there an open position?"]
    YesActive["Yes: Loop (do nothing)"]
    NoActive["No: MonitorPositionClosure()"]
    MonitorClosure["Monitor if last position closed by TP/SL\nUpdate flags and score"]
    LogicLoop["LogicLoop()\nCheck flags and act"]
    PlaceFirst["flagPlaceFirstEntry = true:\nPlaceFirstEntryOrder()\nSave params, reset flags"]
    PlaceRepl["flagPlaceReplacement = true:\nPlaceReplacementOrder()\nUse saved params, decrement score, reset flags"]
    ResetLogic["Reset condition:\nResetLogic()\nReset flags, score, clear params"]

    OnInit --> OnTick
    OnTick --> CheckActive
    CheckActive -- "Yes" --> YesActive --> OnTick
    CheckActive -- "No" --> NoActive --> MonitorClosure --> LogicLoop
    LogicLoop --> PlaceFirst
    LogicLoop --> PlaceRepl
    LogicLoop --> ResetLogic
    PlaceFirst --> OnTick
    PlaceRepl --> OnTick
    ResetLogic --> OnTick
```

## Notes
- The EA only places BUY orders for both first entry and replacements.
- All replacement orders use the exact parameters of the first entry until a reset occurs.
- The state loop ensures only one position is managed at a time.
- The logic loop manages the trading logic and flag transitions.
