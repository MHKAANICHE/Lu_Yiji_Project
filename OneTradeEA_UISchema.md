# One Trade EA UI Technical Schema

This document defines the pixel-perfect layout for all UI elements in the MetaTrader 5 EA panel, including positions, sizes, padding, and spacing. All values are in pixels and should be strictly applied in the MQL5 code using OBJPROP_XDISTANCE, OBJPROP_YDISTANCE, OBJPROP_XSIZE, OBJPROP_YSIZE, and related properties.

## Panel Background
- X: 10
- Y: 10
- Width: 400
- Height: 340
- Corner radius: 14
- Color: #F5F5F5 (C'245,245,245')
- Border: 1px, #C5C5C5 (C'197,197,197')

## Grid System
- Grid X: 28 (panel_x + 18)
- Grid Y: 28 (panel_y + 18)
- Grid Width: 364 (panel_w - 36)
- Row Height: 48
- Column Gap: 16
- Row Gap: 10
- Column Width: 174 ((grid_w - col_gap) / 2)

## Title/Status Block
- X: 28
- Y: 28
- Width: 364
- Height: 48
- Padding Left: 16
- Title Font Size: 15
- Status Font Size: 11
- Title Y: 40
- Status Y: 56

## Input Blocks (Two Columns)
- Each block:
  - X: 28 (left column), 218 (right column)
  - Y: Calculated per row (see below)
  - Width: 174
  - Height: 48
  - Padding Left: 10
  - Label Font Size: 12
  - Value Font Size: 12
  - Tip Font Size: 9
  - Label Y: block_y + 12
  - Value Y: block_y + 28
  - Tip Y: block_y + 40

### Row Y Positions
- Row 1: 76
- Row 2: 134
- Row 3: 192
- Row 4: 250

## Time Window Block (Full Width)
- X: 28
- Y: 308
- Width: 364
- Height: 48
- Padding Left: 10

## Button Row (Full Width)
- X: 28
- Y: 366
- Width: 364
- Height: 40
- Button Width: 100
- Button Height: 28
- Button Gap: 18
- First Button X: 44
- Button Y: 372

## Colors
- Panel: #F5F5F5
- Title Block: #E3F2FD
- Mode Block: #E8F5E9
- Lot Block: #E8F5E9
- SL Block: #FFFDE7
- Repl Block: #FFFDE7
- Risk Block: #E3F2FD
- Reward Block: #E3F2FD
- Open Block: #FFF3E0
- Close Block: #FFF3E0
- Time Window Block: #F3E5F5
- Button: #1976D2 (Start), #808080 (Others)

## Example Block Position Table
| Block         | X   | Y   | Width | Height |
|---------------|-----|-----|-------|--------|
| ModeBlock     | 28  | 76  | 174   | 48     |
| LotBlock      | 218 | 76  | 174   | 48     |
| SLBlock       | 28  | 134 | 174   | 48     |
| ReplBlock     | 218 | 134 | 174   | 48     |
| RiskBlock     | 28  | 192 | 174   | 48     |
| RewardBlock   | 218 | 192 | 174   | 48     |
| OpenBlock     | 28  | 250 | 174   | 48     |
| CloseBlock    | 218 | 250 | 174   | 48     |
| TWBlock       | 28  | 308 | 364   | 48     |
| ButtonRow     | 28  | 366 | 364   | 40     |

## Notes
- All padding, font sizes, and colors should be strictly applied for pixel-perfect fidelity.
- If the EA window size changes, update all positions and sizes proportionally.
- This schema should be referenced for all future UI changes.
