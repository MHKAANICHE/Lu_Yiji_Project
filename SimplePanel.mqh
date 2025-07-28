//+------------------------------------------------------------------+
//|                 SimplePanel.mqh                                  |
//|   Inspired by HTML mockup and EasyAndFastGUI, for MQL5           |
//+------------------------------------------------------------------+
#ifndef __SIMPLE_PANEL_MQH__
#define __SIMPLE_PANEL_MQH__

#include <ChartObjects/ChartObjectsTxtControls.mqh>

class CSimplePanel
  {
private:
   string m_prefix;
   int m_x, m_y, m_w;
public:
   CSimplePanel() : m_prefix("Panel"), m_x(30), m_y(30), m_w(540) {}
   void Create(const string prefix, int x, int y, int w=540)
     {
      m_prefix = prefix; m_x = x; m_y = y; m_w = w;
      // Grid and padding setup
      int grid_x = m_x + 24; // left margin
      int grid_w = m_w - 48; // usable width
      int block_h = 40;      // block height
      int block_gap = 10;    // vertical gap between blocks
      int label_w = 110;     // label width
      int value_w = 90;      // value width
      int col_gap = 30;      // gap between columns
      int btn_h = 36;
      int btn_w = 180;
      int y_cursor = m_y + 16; // start below title
      int total_height = 0;
      // Calculate total height for all blocks
      total_height = 16 + block_h*8 + block_gap*7 + 60 + btn_h + 24;
      // Background rectangle (gray, behind all elements)
      string bg = m_prefix+"_bg";
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, m_x);
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, m_y);
      ObjectSetInteger(0, bg, OBJPROP_XSIZE, m_w);
      ObjectSetInteger(0, bg, OBJPROP_YSIZE, total_height);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'245,245,245');
      ObjectSetInteger(0, bg, OBJPROP_COLOR, C'200,200,200');
      ObjectSetInteger(0, bg, OBJPROP_CORNER, 5);
      ObjectSetInteger(0, bg, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bg, OBJPROP_HIDDEN, false);

      // Title/Header (large, bold, blue, centered)
      string title = m_prefix+"_title";
      ObjectCreate(0, title, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, title, OBJPROP_XDISTANCE, m_x + m_w/2 - 120);
      ObjectSetInteger(0, title, OBJPROP_YDISTANCE, m_y);
      ObjectSetInteger(0, title, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, title, OBJPROP_FONTSIZE, 18);
      ObjectSetString(0, title, OBJPROP_TEXT, "One Trade EA - Control Panel");
      ObjectSetInteger(0, title, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, title, OBJPROP_SELECTABLE, false);
      y_cursor += 36;

      // Magic Number Block (blue, centered)
      string magic_bg = m_prefix+"_magic_bg";
      ObjectCreate(0, magic_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, magic_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, magic_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, magic_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, magic_bg, OBJPROP_YSIZE, block_h);
      ObjectSetInteger(0, magic_bg, OBJPROP_BGCOLOR, C'232,240,255');
      ObjectSetInteger(0, magic_bg, OBJPROP_COLOR, C'197,202,233');
      ObjectSetInteger(0, magic_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, magic_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, magic_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, magic_bg, OBJPROP_HIDDEN, false);
      string obj = m_prefix+"_magic";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 10);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 13);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Magic Number: "+Symbol()+"-"+IntegerToString((int)AccountInfoInteger(ACCOUNT_LOGIN)));
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      y_cursor += block_h + block_gap;

      // Instrument Info Block
      string instr_bg = m_prefix+"_instr_bg";
      ObjectCreate(0, instr_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, instr_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, instr_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, instr_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, instr_bg, OBJPROP_YSIZE, block_h+16);
      ObjectSetInteger(0, instr_bg, OBJPROP_BGCOLOR, C'224,247,250');
      ObjectSetInteger(0, instr_bg, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, instr_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, instr_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, instr_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, instr_bg, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_instr";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      string instr = "Instrument: "+Symbol()+
         "\nDigits: "+IntegerToString((int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+ 
         "\nCurrent Price: "+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_BID),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+ 
         "\nWhat does 100 pips mean?"+
         "\n• For "+Symbol()+" ("+IntegerToString((int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+" digits), 1 pip = 0.01"+
         "\n• 100 pips = 1.00"+
         "\n• If price moves from ... to ..., that's a move of 100 pips.";
      ObjectSetString(0, obj, OBJPROP_TEXT, instr);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      string instr_tip = m_prefix+"_instr_tip";
      ObjectCreate(0, instr_tip, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, instr_tip, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, instr_tip, OBJPROP_YDISTANCE, y_cursor + block_h + 8);
      ObjectSetInteger(0, instr_tip, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, instr_tip, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, instr_tip, OBJPROP_TEXT, "This helps you set your Stop Loss and Take Profit correctly for this instrument.");
      ObjectSetInteger(0, instr_tip, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, instr_tip, OBJPROP_SELECTABLE, false);
      y_cursor += block_h + 16 + block_gap;

      // Mode/Lot Block (green)
      string row1_bg = m_prefix+"_row1_bg";
      ObjectCreate(0, row1_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, row1_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, row1_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, row1_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, row1_bg, OBJPROP_YSIZE, block_h);
      ObjectSetInteger(0, row1_bg, OBJPROP_BGCOLOR, C'232,245,233');
      ObjectSetInteger(0, row1_bg, OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, row1_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, row1_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, row1_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, row1_bg, OBJPROP_HIDDEN, false);
      // Mode
      obj = m_prefix+"_mode_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Mode:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_mode_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + 30);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Buy/Sell");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_mode_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 24);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Choose Buy or Sell mode");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Lot Size
      obj = m_prefix+"_lot_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Lot Size:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_lot_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap + label_w);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "0.10");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_lot_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 24);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Set your trade volume");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      y_cursor += block_h + block_gap;

      // SL/Max Replacements Block (yellow)
      string row2_bg = m_prefix+"_row2_bg";
      ObjectCreate(0, row2_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, row2_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, row2_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, row2_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, row2_bg, OBJPROP_YSIZE, block_h);
      ObjectSetInteger(0, row2_bg, OBJPROP_BGCOLOR, C'255,253,231');
      ObjectSetInteger(0, row2_bg, OBJPROP_COLOR, C'251,192,45');
      ObjectSetInteger(0, row2_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, row2_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, row2_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, row2_bg, OBJPROP_HIDDEN, false);
      // SL
      obj = m_prefix+"_sl_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'251,192,45');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Stop Loss:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_sl_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + 30);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "20");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_sl_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 24);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Distance from entry to SL");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Max Replacements
      obj = m_prefix+"_repl_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'109,76,65');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Max Repl.:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_repl_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap + label_w);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "2");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_repl_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 24);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "How many times to re-place after SL");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // What are replacements? info
      obj = m_prefix+"_repl_info";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 32);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'109,76,65');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "What are replacements? If a trade hits SL, the EA will re-place a new order. This repeats up to Max Replacements.");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      y_cursor += block_h + block_gap;

      // Risk/Reward Block (blue)
      string row3_bg = m_prefix+"_row3_bg";
      ObjectCreate(0, row3_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, row3_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, row3_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, row3_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, row3_bg, OBJPROP_YSIZE, block_h);
      ObjectSetInteger(0, row3_bg, OBJPROP_BGCOLOR, C'227,242,253');
      ObjectSetInteger(0, row3_bg, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, row3_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, row3_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, row3_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, row3_bg, OBJPROP_HIDDEN, false);
      // Risk
      obj = m_prefix+"_risk_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Risk:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_risk_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + 30);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "1.00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_risk_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 24);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Value at risk");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Reward
      obj = m_prefix+"_reward_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Reward:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_reward_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap + label_w);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "2.00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_reward_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 24);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Target value");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Risk:Reward note
      obj = m_prefix+"_rr_note";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 32);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Set your desired Risk:Reward as [1]:[2] in value (e.g., 1.00:2.00)");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      y_cursor += block_h + block_gap;

      // Opening/Closing Time Block (orange)
      string row4_bg = m_prefix+"_row4_bg";
      ObjectCreate(0, row4_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, row4_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, row4_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, row4_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, row4_bg, OBJPROP_YSIZE, block_h);
      ObjectSetInteger(0, row4_bg, OBJPROP_BGCOLOR, C'255,243,224');
      ObjectSetInteger(0, row4_bg, OBJPROP_COLOR, C'245,124,0');
      ObjectSetInteger(0, row4_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, row4_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, row4_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, row4_bg, OBJPROP_HIDDEN, false);
      // Opening Time
      obj = m_prefix+"_open_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'245,124,0');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Open Time:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_open_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + 30);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "09:00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Closing Time
      obj = m_prefix+"_close_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'211,47,47');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Close Time:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_close_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap + label_w);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "17:00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      y_cursor += block_h + block_gap;

      // Time Window Block (purple)
      string row5_bg = m_prefix+"_row5_bg";
      ObjectCreate(0, row5_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, row5_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, row5_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, row5_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, row5_bg, OBJPROP_YSIZE, block_h);
      ObjectSetInteger(0, row5_bg, OBJPROP_BGCOLOR, C'243,229,245');
      ObjectSetInteger(0, row5_bg, OBJPROP_COLOR, C'94,53,177');
      ObjectSetInteger(0, row5_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, row5_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, row5_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, row5_bg, OBJPROP_HIDDEN, false);
      // Time Window Start
      obj = m_prefix+"_twstart_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'142,36,170');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "TW Start:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_twstart_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + 30);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Time Window End
      obj = m_prefix+"_twend_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'94,53,177');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "TW End:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_twend_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + label_w + value_w + col_gap + label_w);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      y_cursor += block_h + block_gap;

      // Status Panel (blue)
      string status_bg = m_prefix+"_status_bg";
      ObjectCreate(0, status_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, status_bg, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, status_bg, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, status_bg, OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, status_bg, OBJPROP_YSIZE, 60);
      ObjectSetInteger(0, status_bg, OBJPROP_BGCOLOR, C'227,242,253');
      ObjectSetInteger(0, status_bg, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, status_bg, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, status_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, status_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, status_bg, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_status";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, grid_x + 20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, y_cursor + 10);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Status: Awaiting user action.\nActive Trade: None\nPending Order: None\nReplacements Left: 2\nTime Window: Not active");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      y_cursor += 60 + block_gap;

      // Buttons Row
      string btn_start = m_prefix+"_btn_start";
      ObjectCreate(0, btn_start, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, btn_start, OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, btn_start, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, btn_start, OBJPROP_XSIZE, btn_w);
      ObjectSetInteger(0, btn_start, OBJPROP_YSIZE, btn_h);
      ObjectSetInteger(0, btn_start, OBJPROP_BGCOLOR, C'25,118,210');
      ObjectSetInteger(0, btn_start, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, btn_start, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, btn_start, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, btn_start, OBJPROP_HIDDEN, false);
      string btnText = m_prefix+"_btn_start_text";
      ObjectCreate(0, btnText, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, btnText, OBJPROP_XDISTANCE, grid_x + 54);
      ObjectSetInteger(0, btnText, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, btnText, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, btnText, OBJPROP_FONTSIZE, 13);
      ObjectSetString(0, btnText, OBJPROP_TEXT, "Start EA");
      ObjectSetInteger(0, btnText, OBJPROP_HIDDEN, false);

      string btn_replace = m_prefix+"_btn_replace";
      ObjectCreate(0, btn_replace, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, btn_replace, OBJPROP_XDISTANCE, grid_x + btn_w + 24);
      ObjectSetInteger(0, btn_replace, OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, btn_replace, OBJPROP_XSIZE, btn_w);
      ObjectSetInteger(0, btn_replace, OBJPROP_YSIZE, btn_h);
      ObjectSetInteger(0, btn_replace, OBJPROP_BGCOLOR, clrGray);
      ObjectSetInteger(0, btn_replace, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, btn_replace, OBJPROP_CORNER, 6);
      ObjectSetInteger(0, btn_replace, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, btn_replace, OBJPROP_HIDDEN, false);
      btnText = m_prefix+"_btn_replace_text";
      ObjectCreate(0, btnText, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, btnText, OBJPROP_XDISTANCE, grid_x + btn_w + 24 + 34);
      ObjectSetInteger(0, btnText, OBJPROP_YDISTANCE, y_cursor + 8);
      ObjectSetInteger(0, btnText, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, btnText, OBJPROP_FONTSIZE, 13);
      ObjectSetString(0, btnText, OBJPROP_TEXT, "Replace Order");
      ObjectSetInteger(0, btnText, OBJPROP_HIDDEN, false);

      // Instrument info block background (light blue rectangle)
      string instr_bg = m_prefix+"_instr_bg";
      ObjectCreate(0, instr_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, instr_bg, OBJPROP_XDISTANCE, m_x+10);
      ObjectSetInteger(0, instr_bg, OBJPROP_YDISTANCE, m_y+40);
      ObjectSetInteger(0, instr_bg, OBJPROP_XSIZE, m_w-30);
      ObjectSetInteger(0, instr_bg, OBJPROP_YSIZE, 70);
      ObjectSetInteger(0, instr_bg, OBJPROP_BGCOLOR, C'224,247,250'); // #e0f7fa
      ObjectSetInteger(0, instr_bg, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, instr_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, instr_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, instr_bg, OBJPROP_HIDDEN, false);

      // Instrument info block (multi-line, blue highlight, tip)
      obj = m_prefix+"_instr";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+48);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      string instr = "Instrument: "+Symbol()+
         "\nDigits: "+IntegerToString((int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+ 
         "\nCurrent Price: "+DoubleToString(SymbolInfoDouble(Symbol(),SYMBOL_BID),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+ 
         "\nWhat does 100 pips mean?"+
         "\n• For "+Symbol()+" ("+IntegerToString((int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+" digits), 1 pip = 0.01"+
         "\n• 100 pips = 1.00"+
         "\n• If price moves from ... to ..., that's a move of 100 pips.";
      ObjectSetString(0, obj, OBJPROP_TEXT, instr);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);

      // Blue tip below info block
      string instr_tip = m_prefix+"_instr_tip";
      ObjectCreate(0, instr_tip, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, instr_tip, OBJPROP_XDISTANCE, m_x+20);
      ObjectSetInteger(0, instr_tip, OBJPROP_YDISTANCE, m_y+105);
      ObjectSetInteger(0, instr_tip, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, instr_tip, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, instr_tip, OBJPROP_TEXT, "This helps you set your Stop Loss and Take Profit correctly for this instrument.");
      ObjectSetInteger(0, instr_tip, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, instr_tip, OBJPROP_SELECTABLE, false);

      // Mode/Lot row (grouped, green background, visually separated)
      string row1_bg = m_prefix+"_row1_bg";
      ObjectCreate(0, row1_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, row1_bg, OBJPROP_XDISTANCE, m_x+10);
      ObjectSetInteger(0, row1_bg, OBJPROP_YDISTANCE, m_y+125);
      ObjectSetInteger(0, row1_bg, OBJPROP_XSIZE, m_w-30);
      ObjectSetInteger(0, row1_bg, OBJPROP_YSIZE, 38);
      ObjectSetInteger(0, row1_bg, OBJPROP_BGCOLOR, C'232,245,233');
      ObjectSetInteger(0, row1_bg, OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, row1_bg, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, row1_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, row1_bg, OBJPROP_HIDDEN, false);
      // Mode
      obj = m_prefix+"_mode_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+130);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Mode:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_mode_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+90);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+130);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Buy/Sell");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Mode info/tooltip
      obj = m_prefix+"_mode_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+20);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+145);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Choose Buy or Sell mode");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Lot Size
      obj = m_prefix+"_lot_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+250);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+130);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Lot Size:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_lot_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+340);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+130);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "0.10");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Lot info/tooltip
      obj = m_prefix+"_lot_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+250);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+145);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Set your trade volume");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);

      // SL/MaxRepl row (yellow background)
      obj = m_prefix+"_row2_bg";
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+5);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+130);
      ObjectSetInteger(0, obj, OBJPROP_XSIZE, m_w-20);
      ObjectSetInteger(0, obj, OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, C'255,253,231'); // #fffde7
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'251,192,45'); // #fbc02d
      ObjectSetInteger(0, obj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // SL
      obj = m_prefix+"_sl_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+135);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'251,192,45');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Stop Loss:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_sl_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+80);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+135);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "20");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // SL tooltip
      obj = m_prefix+"_sl_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+147);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Distance from entry to SL");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Max Replacements
      obj = m_prefix+"_repl_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+135);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'109,76,65');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Max Repl.:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_repl_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+280);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+135);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "2");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Max Replacements tooltip
      obj = m_prefix+"_repl_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+147);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "How many times to re-place after SL");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // What are replacements? block
      obj = m_prefix+"_repl_info";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+160);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'109,76,65');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "What are replacements? If a trade hits SL, the EA will re-place a new order. This repeats up to Max Replacements.");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);

      // Risk/Reward row (blue background)
      obj = m_prefix+"_row3_bg";
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+5);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+160);
      ObjectSetInteger(0, obj, OBJPROP_XSIZE, m_w-20);
      ObjectSetInteger(0, obj, OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, C'227,242,253'); // #e3f2fd
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Risk
      obj = m_prefix+"_risk_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+165);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Risk:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_risk_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+80);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+165);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "1.00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Reward
      obj = m_prefix+"_reward_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+165);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Reward:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_reward_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+280);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+165);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "2.00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Risk/Reward tooltip
      obj = m_prefix+"_risk_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+177);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Value at risk");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_reward_tip";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+177);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Target value");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Risk:Reward note
      obj = m_prefix+"_rr_note";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+192);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 8);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Set your desired Risk:Reward as [1]:[2] in value (e.g., 1.00:2.00)");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);

      // Opening/Closing Time row (orange background)
      obj = m_prefix+"_row4_bg";
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+5);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+195);
      ObjectSetInteger(0, obj, OBJPROP_XSIZE, m_w-20);
      ObjectSetInteger(0, obj, OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, C'255,243,224'); // #fff3e0
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'245,124,0'); // #f57c00
      ObjectSetInteger(0, obj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Opening Time
      obj = m_prefix+"_open_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+200);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'245,124,0');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Open Time:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_open_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+80);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+200);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "09:00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Closing Time
      obj = m_prefix+"_close_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+200);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'211,47,47'); // #d32f2f
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Close Time:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_close_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+280);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+200);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "17:00");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);

      // Time Window row (purple background)
      obj = m_prefix+"_row5_bg";
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+5);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+225);
      ObjectSetInteger(0, obj, OBJPROP_XSIZE, m_w-20);
      ObjectSetInteger(0, obj, OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, C'243,229,245'); // #f3e5f5
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'94,53,177'); // #5e35b1
      ObjectSetInteger(0, obj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Time Window Start
      obj = m_prefix+"_twstart_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+230);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'142,36,170'); // #8e24aa
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "TW Start:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_twstart_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+80);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+230);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Time Window End
      obj = m_prefix+"_twend_label";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+230);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'94,53,177');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "TW End:");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_twend_val";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+280);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+230);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 10);
      ObjectSetString(0, obj, OBJPROP_TEXT, "");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);

      // Status panel (blue background, below)
      obj = m_prefix+"_status_bg";
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+5);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+260);
      ObjectSetInteger(0, obj, OBJPROP_XSIZE, m_w-20);
      ObjectSetInteger(0, obj, OBJPROP_YSIZE, 48);
      ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, C'227,242,253'); // #e3f2fd
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, obj, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      obj = m_prefix+"_status";
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+15);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+265);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, obj, OBJPROP_TEXT, "Status: Awaiting user action.\nActive Trade: None\nPending Order: None\nReplacements Left: 2\nTime Window: Not active");
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);

      // Buttons (bottom row)
      // Start EA button (rectangle)
      obj = m_prefix+"_btn_start";
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+10);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+320);
      ObjectSetInteger(0, obj, OBJPROP_XSIZE, 160);
      ObjectSetInteger(0, obj, OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, obj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Start EA button text (label on top)
      string btnText = m_prefix+"_btn_start_text";
      ObjectCreate(0, btnText, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, btnText, OBJPROP_XDISTANCE, m_x+10+40);
      ObjectSetInteger(0, btnText, OBJPROP_YDISTANCE, m_y+320+7);
      ObjectSetInteger(0, btnText, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, btnText, OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, btnText, OBJPROP_TEXT, "Start EA");
      ObjectSetInteger(0, btnText, OBJPROP_HIDDEN, false);

      // Replace Order button (rectangle)
      obj = m_prefix+"_btn_replace";
      ObjectCreate(0, obj, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, m_x+200);
      ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, m_y+320);
      ObjectSetInteger(0, obj, OBJPROP_XSIZE, 160);
      ObjectSetInteger(0, obj, OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, obj, OBJPROP_BGCOLOR, clrGray);
      ObjectSetInteger(0, obj, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, obj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, obj, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, obj, OBJPROP_HIDDEN, false);
      // Replace Order button text (label on top)
      btnText = m_prefix+"_btn_replace_text";
      ObjectCreate(0, btnText, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, btnText, OBJPROP_XDISTANCE, m_x+200+20);
      ObjectSetInteger(0, btnText, OBJPROP_YDISTANCE, m_y+320+7);
      ObjectSetInteger(0, btnText, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, btnText, OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, btnText, OBJPROP_TEXT, "Replace Order");
      ObjectSetInteger(0, btnText, OBJPROP_HIDDEN, false);
     }
   void Delete()
     {
      string objs[] = {
        "_title","_bg","_magic","_instr_bg","_instr","_instr_tip",
        "_row1_bg","_mode_label","_mode_val","_mode_tip","_lot_label","_lot_val","_lot_tip",
        "_row2_bg","_sl_label","_sl_val","_repl_label","_repl_val",
        "_row3_bg","_risk_label","_risk_val","_reward_label","_reward_val",
        "_row4_bg","_open_label","_open_val","_close_label","_close_val",
        "_row5_bg","_twstart_label","_twstart_val","_twend_label","_twend_val",
        "_status_bg","_status",
        "_btn_start","_btn_start_text","_btn_replace","_btn_replace_text"
      };
      for(int i=0;i<ArraySize(objs);i++) ObjectDelete(0, m_prefix+objs[i]);
     }
   void SetStatus(string status)
     {
      string obj = m_prefix+"_status";
      ObjectSetString(0, obj, OBJPROP_TEXT, status);
     }
   // Add more setters/getters as needed for other fields
  };

#endif // __SIMPLE_PANEL_MQH__
