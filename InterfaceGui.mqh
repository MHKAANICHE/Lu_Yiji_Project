//+------------------------------------------------------------------+
//|                 InterfaceGui.mqh                                 |
//|   Inspired by One_Trade_EA_UI_Mockup.html                       |
//|   Cross-platform, no chart objects                              |
//+------------------------------------------------------------------+
#ifndef __INTERFACE_GUI_MQH__
#define __INTERFACE_GUI_MQH__

// This file defines a stub interface for the EA GUI, inspired by the HTML mockup.
// No chart object code. Only class, member variables, and stub methods.


// Enhanced graphical interface inspired by HTML mockup and SimplePanel.mqh
class CInterfaceGui
  {
private:
   string m_prefix;
   int m_x, m_y, m_w;
   // Controls
   int m_mode; // 0=Buy, 1=Sell
   double m_lot;
   double m_sl;
   int m_repl;
   double m_risk;
   double m_reward;
   string m_open_time;
   string m_close_time;
   string m_twstart;
   string m_twend;
   // Status panel
   string m_status;
   bool m_inputs_valid;
   // Tooltips
   string m_tip_mode, m_tip_lot, m_tip_sl, m_tip_repl, m_tip_risk, m_tip_reward, m_tip_open, m_tip_close, m_tip_twstart, m_tip_twend;
   // Color blocks (logical, for grouping)
   string m_block_mode, m_block_lot, m_block_sl, m_block_repl, m_block_risk, m_block_reward, m_block_open, m_block_close, m_block_twstart, m_block_twend, m_block_status;

public:
   CInterfaceGui() : m_prefix("Gui"), m_x(30), m_y(30), m_w(540),
      m_mode(0), m_lot(0.10), m_sl(20), m_repl(2), m_risk(1.0), m_reward(2.0),
      m_open_time("09:00"), m_close_time("17:00"), m_twstart(""), m_twend(""),
      m_status("Status: Awaiting user action."), m_inputs_valid(false),
      m_tip_mode("Choose Buy or Sell mode"), m_tip_lot("Set your trade volume"),
      m_tip_sl("Distance from entry to SL"), m_tip_repl("How many times to re-place after SL"),
      m_tip_risk("Value at risk"), m_tip_reward("Target value"),
      m_tip_open("Time to open first trade"), m_tip_close("Time to close all trades"),
      m_tip_twstart("Start of time window (no replacements)"), m_tip_twend("End of time window (no replacements)") {}

   // Chart object rendering: creates all UI elements on the chart
   void RenderUI()
     {
      // Mode block (green)
      ObjectCreate(0, m_prefix+"_ModeBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_XDISTANCE, 20);
      // --- GRAY BACKGROUND ---
      int panel_x = 10, panel_y = 10, panel_w = 400, panel_h = 340;
      ObjectCreate(0, m_prefix+"_PanelBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_XDISTANCE, panel_x);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_YDISTANCE, panel_y);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_XSIZE, panel_w);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_YSIZE, panel_h);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_BGCOLOR, C'245,245,245');
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_COLOR, C'197,197,197');
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_CORNER, 14);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_PanelBG", OBJPROP_HIDDEN, false);

      // --- TWO COLUMN GRID ---
      int grid_x = panel_x+18, grid_y = panel_y+18, grid_w = panel_w-36, row_h = 48, col_gap = 16, row_gap = 10;
      int col_w = (grid_w - col_gap) / 2;
      int y_cursor = grid_y;

      // Title/Status row (full width)
      ObjectCreate(0, m_prefix+"_TitleBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_YSIZE, row_h);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_BGCOLOR, C'227,242,253');
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_CORNER, 10);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_TitleBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_TitleLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_TitleLabel", OBJPROP_XDISTANCE, grid_x+16);
      ObjectSetInteger(0, m_prefix+"_TitleLabel", OBJPROP_YDISTANCE, y_cursor+12);
      ObjectSetInteger(0, m_prefix+"_TitleLabel", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_TitleLabel", OBJPROP_FONTSIZE, 15);
      ObjectSetString(0, m_prefix+"_TitleLabel", OBJPROP_TEXT, "One Trade EA - Compact Panel");
      ObjectSetInteger(0, m_prefix+"_TitleLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_StatusLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_XDISTANCE, grid_x+16);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_YDISTANCE, y_cursor+28);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_StatusLabel", OBJPROP_TEXT, m_status);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_HIDDEN, false);
      y_cursor += row_h + row_gap;

      // First grid row: Mode (left), Lot (right)
      int x_left = grid_x, x_right = grid_x+col_w+col_gap;
      string blocksA[2] = {"_ModeBlock","_LotBlock"};
      string labelsA[2] = {"Mode","Lot Size"};
      string tipsA[2] = {m_tip_mode,m_tip_lot};
      string valuesA[2] = {(m_mode==0?"Buy":"Sell"),DoubleToString(m_lot,2)};
      color block_colorsA[2] = {C'232,245,233',C'232,245,233'};
      color label_colorsA[2] = {C'56,142,60',C'25,118,210'};
      for(int i=0;i<2;i++) {
        int x = (i==0)?x_left:x_right;
        ObjectCreate(0, m_prefix+blocksA[i], OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_YDISTANCE, y_cursor);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_XSIZE, col_w);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_YSIZE, row_h);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_BGCOLOR, block_colorsA[i]);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_COLOR, label_colorsA[i]);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_CORNER, 8);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_prefix+blocksA[i], OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksA[i]+"Label", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Label", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Label", OBJPROP_YDISTANCE, y_cursor+12);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Label", OBJPROP_COLOR, label_colorsA[i]);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Label", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksA[i]+"Label", OBJPROP_TEXT, labelsA[i]);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Label", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksA[i]+"Value", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Value", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Value", OBJPROP_YDISTANCE, y_cursor+28);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Value", OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Value", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksA[i]+"Value", OBJPROP_TEXT, valuesA[i]);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Value", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksA[i]+"Tip", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Tip", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Tip", OBJPROP_YDISTANCE, y_cursor+40);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Tip", OBJPROP_COLOR, C'120,144,156');
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Tip", OBJPROP_FONTSIZE, 9);
        ObjectSetString(0, m_prefix+blocksA[i]+"Tip", OBJPROP_TEXT, tipsA[i]);
        ObjectSetInteger(0, m_prefix+blocksA[i]+"Tip", OBJPROP_HIDDEN, false);
      }
      y_cursor += row_h + row_gap;

      // Second grid row: SL (left), Max Repl (right)
      string blocksB[2] = {"_SLBlock","_ReplBlock"};
      string labelsB[2] = {"Stop Loss","Max Repl."};
      string tipsB[2] = {m_tip_sl,m_tip_repl};
      string valuesB[2] = {IntegerToString((int)m_sl),IntegerToString(m_repl)};
      color block_colorsB[2] = {C'255,253,231',C'255,253,231'};
      color label_colorsB[2] = {C'251,192,45',C'109,76,65'};
      for(int i=0;i<2;i++) {
        int x = (i==0)?x_left:x_right;
        ObjectCreate(0, m_prefix+blocksB[i], OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_YDISTANCE, y_cursor);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_XSIZE, col_w);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_YSIZE, row_h);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_BGCOLOR, block_colorsB[i]);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_COLOR, label_colorsB[i]);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_CORNER, 8);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_prefix+blocksB[i], OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksB[i]+"Label", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Label", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Label", OBJPROP_YDISTANCE, y_cursor+12);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Label", OBJPROP_COLOR, label_colorsB[i]);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Label", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksB[i]+"Label", OBJPROP_TEXT, labelsB[i]);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Label", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksB[i]+"Value", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Value", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Value", OBJPROP_YDISTANCE, y_cursor+28);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Value", OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Value", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksB[i]+"Value", OBJPROP_TEXT, valuesB[i]);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Value", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksB[i]+"Tip", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Tip", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Tip", OBJPROP_YDISTANCE, y_cursor+40);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Tip", OBJPROP_COLOR, C'120,144,156');
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Tip", OBJPROP_FONTSIZE, 9);
        ObjectSetString(0, m_prefix+blocksB[i]+"Tip", OBJPROP_TEXT, tipsB[i]);
        ObjectSetInteger(0, m_prefix+blocksB[i]+"Tip", OBJPROP_HIDDEN, false);
      }
      y_cursor += row_h + row_gap;

      // Third grid row: Risk (left), Reward (right)
      string blocksC[2] = {"_RiskBlock","_RewardBlock"};
      string labelsC[2] = {"Risk","Reward"};
      string tipsC[2] = {m_tip_risk,m_tip_reward};
      string valuesC[2] = {DoubleToString(m_risk,2),DoubleToString(m_reward,2)};
      color block_colorsC[2] = {C'227,242,253',C'227,242,253'};
      color label_colorsC[2] = {C'25,118,210',C'56,142,60'};
      for(int i=0;i<2;i++) {
        int x = (i==0)?x_left:x_right;
        ObjectCreate(0, m_prefix+blocksC[i], OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_YDISTANCE, y_cursor);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_XSIZE, col_w);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_YSIZE, row_h);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_BGCOLOR, block_colorsC[i]);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_COLOR, label_colorsC[i]);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_CORNER, 8);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_prefix+blocksC[i], OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksC[i]+"Label", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Label", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Label", OBJPROP_YDISTANCE, y_cursor+12);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Label", OBJPROP_COLOR, label_colorsC[i]);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Label", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksC[i]+"Label", OBJPROP_TEXT, labelsC[i]);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Label", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksC[i]+"Value", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Value", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Value", OBJPROP_YDISTANCE, y_cursor+28);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Value", OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Value", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksC[i]+"Value", OBJPROP_TEXT, valuesC[i]);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Value", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksC[i]+"Tip", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Tip", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Tip", OBJPROP_YDISTANCE, y_cursor+40);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Tip", OBJPROP_COLOR, C'120,144,156');
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Tip", OBJPROP_FONTSIZE, 9);
        ObjectSetString(0, m_prefix+blocksC[i]+"Tip", OBJPROP_TEXT, tipsC[i]);
        ObjectSetInteger(0, m_prefix+blocksC[i]+"Tip", OBJPROP_HIDDEN, false);
      }
      y_cursor += row_h + row_gap;

      // Fourth grid row: Open Time (left), Close Time (right)
      string blocksD[2] = {"_OpenBlock","_CloseBlock"};
      string labelsD[2] = {"Open Time","Close Time"};
      string tipsD[2] = {m_tip_open,m_tip_close};
      string valuesD[2] = {m_open_time,m_close_time};
      color block_colorsD[2] = {C'255,243,224',C'255,243,224'};
      color label_colorsD[2] = {C'245,124,0',C'211,47,47'};
      for(int i=0;i<2;i++) {
        int x = (i==0)?x_left:x_right;
        ObjectCreate(0, m_prefix+blocksD[i], OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_YDISTANCE, y_cursor);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_XSIZE, col_w);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_YSIZE, row_h);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_BGCOLOR, block_colorsD[i]);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_COLOR, label_colorsD[i]);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_CORNER, 8);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, m_prefix+blocksD[i], OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksD[i]+"Label", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Label", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Label", OBJPROP_YDISTANCE, y_cursor+12);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Label", OBJPROP_COLOR, label_colorsD[i]);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Label", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksD[i]+"Label", OBJPROP_TEXT, labelsD[i]);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Label", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksD[i]+"Value", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Value", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Value", OBJPROP_YDISTANCE, y_cursor+28);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Value", OBJPROP_COLOR, clrBlack);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Value", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+blocksD[i]+"Value", OBJPROP_TEXT, valuesD[i]);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Value", OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+blocksD[i]+"Tip", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Tip", OBJPROP_XDISTANCE, x+10);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Tip", OBJPROP_YDISTANCE, y_cursor+40);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Tip", OBJPROP_COLOR, C'120,144,156');
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Tip", OBJPROP_FONTSIZE, 9);
        ObjectSetString(0, m_prefix+blocksD[i]+"Tip", OBJPROP_TEXT, tipsD[i]);
        ObjectSetInteger(0, m_prefix+blocksD[i]+"Tip", OBJPROP_HIDDEN, false);
      }
      y_cursor += row_h + row_gap;

      // Fifth grid row: Time Window (full width)
      ObjectCreate(0, m_prefix+"_TWBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_YSIZE, row_h);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_BGCOLOR, C'243,229,245');
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_COLOR, C'94,53,177');
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_CORNER, 8);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_TWBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_TWBlockLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_TWBlockLabel", OBJPROP_XDISTANCE, grid_x+10);
      ObjectSetInteger(0, m_prefix+"_TWBlockLabel", OBJPROP_YDISTANCE, y_cursor+12);
      ObjectSetInteger(0, m_prefix+"_TWBlockLabel", OBJPROP_COLOR, C'94,53,177');
      ObjectSetInteger(0, m_prefix+"_TWBlockLabel", OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, m_prefix+"_TWBlockLabel", OBJPROP_TEXT, "Time Window");
      ObjectSetInteger(0, m_prefix+"_TWBlockLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_TWBlockValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_TWBlockValue", OBJPROP_XDISTANCE, grid_x+10);
      ObjectSetInteger(0, m_prefix+"_TWBlockValue", OBJPROP_YDISTANCE, y_cursor+28);
      ObjectSetInteger(0, m_prefix+"_TWBlockValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_TWBlockValue", OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, m_prefix+"_TWBlockValue", OBJPROP_TEXT, m_twstart+((m_twend!="")?" - "+m_twend:"") );
      ObjectSetInteger(0, m_prefix+"_TWBlockValue", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_TWBlockTip", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_TWBlockTip", OBJPROP_XDISTANCE, grid_x+10);
      ObjectSetInteger(0, m_prefix+"_TWBlockTip", OBJPROP_YDISTANCE, y_cursor+40);
      ObjectSetInteger(0, m_prefix+"_TWBlockTip", OBJPROP_COLOR, C'120,144,156');
      ObjectSetInteger(0, m_prefix+"_TWBlockTip", OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, m_prefix+"_TWBlockTip", OBJPROP_TEXT, m_tip_twstart);
      ObjectSetInteger(0, m_prefix+"_TWBlockTip", OBJPROP_HIDDEN, false);
      y_cursor += row_h + row_gap;

      // Button row (full width)
      ObjectCreate(0, m_prefix+"_ButtonRow", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_XDISTANCE, grid_x);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_YDISTANCE, y_cursor);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_XSIZE, grid_w);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_BGCOLOR, C'245,245,245');
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_COLOR, C'197,197,197');
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_CORNER, 10);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_ButtonRow", OBJPROP_HIDDEN, false);
      int btn_w = 100, btn_h = 28, btn_gap = 18;
      int btn_x = grid_x+16;
      string btns[3] = {"_StartEAButton","_ReplaceOrderButton","_ResetButton"};
      string btnLabels[3] = {"Start EA","Replace Order","Reset"};
      color btnColors[3] = {C'25,118,210',clrGray,clrGray};
      for(int i=0;i<3;i++) {
        ObjectCreate(0, m_prefix+btns[i], OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_XDISTANCE, btn_x);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_YDISTANCE, y_cursor+6);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_XSIZE, btn_w);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_YSIZE, btn_h);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_BGCOLOR, btnColors[i]);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_COLOR, btnColors[i]);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_CORNER, 6);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_SELECTABLE, true);
        ObjectSetInteger(0, m_prefix+btns[i], OBJPROP_HIDDEN, false);
        ObjectCreate(0, m_prefix+btns[i]+"Text", OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, m_prefix+btns[i]+"Text", OBJPROP_XDISTANCE, btn_x+18);
        ObjectSetInteger(0, m_prefix+btns[i]+"Text", OBJPROP_YDISTANCE, y_cursor+13);
        ObjectSetInteger(0, m_prefix+btns[i]+"Text", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, m_prefix+btns[i]+"Text", OBJPROP_FONTSIZE, 12);
        ObjectSetString(0, m_prefix+btns[i]+"Text", OBJPROP_TEXT, btnLabels[i]);
        ObjectSetInteger(0, m_prefix+btns[i]+"Text", OBJPROP_HIDDEN, false);
        btn_x += btn_w + btn_gap;
      }
      ChartRedraw(0);

      // Replace Order button (gray)
      ObjectCreate(0, m_prefix+"_ReplaceOrderButton", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_XDISTANCE, 160);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_YDISTANCE, 120);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_XSIZE, 120);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_BGCOLOR, clrGray);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButton", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_ReplaceOrderButtonText", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButtonText", OBJPROP_XDISTANCE, 194);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButtonText", OBJPROP_YDISTANCE, 128);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButtonText", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButtonText", OBJPROP_FONTSIZE, 13);
      ObjectSetString(0, m_prefix+"_ReplaceOrderButtonText", OBJPROP_TEXT, "Replace Order");
      ObjectSetInteger(0, m_prefix+"_ReplaceOrderButtonText", OBJPROP_HIDDEN, false);

      // Reset button (gray)
      ObjectCreate(0, m_prefix+"_ResetButton", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_XDISTANCE, 300);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_YDISTANCE, 120);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_XSIZE, 120);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_BGCOLOR, clrGray);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, m_prefix+"_ResetButton", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_ResetButtonText", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ResetButtonText", OBJPROP_XDISTANCE, 334);
      ObjectSetInteger(0, m_prefix+"_ResetButtonText", OBJPROP_YDISTANCE, 128);
      ObjectSetInteger(0, m_prefix+"_ResetButtonText", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, m_prefix+"_ResetButtonText", OBJPROP_FONTSIZE, 13);
      ObjectSetString(0, m_prefix+"_ResetButtonText", OBJPROP_TEXT, "Reset");
      ObjectSetInteger(0, m_prefix+"_ResetButtonText", OBJPROP_HIDDEN, false);

      ChartRedraw(0);
     }

   void UpdatePanel()
     {
      // TODO: Update chart objects with current values and status
      // Example: ObjectSetString(0, m_prefix+"_status", OBJPROP_TEXT, m_status);
     }

   void DeletePanel()
     {
      // TODO: Delete all chart objects created by RenderPanel
      // Example: ObjectDelete(0, m_prefix+"_mode_bg");
     }

   void Create(const string prefix, int x, int y, int w=540)
     {
      m_prefix = prefix; m_x = x; m_y = y; m_w = w;
      // Initialize controls
      m_mode = 0; // Default to Buy
      m_lot = 0.10;
      m_sl = 20;
      m_repl = 2;
      m_risk = 1.0;
      m_reward = 2.0;
      m_open_time = "09:00";
      m_close_time = "17:00";
      m_twstart = "";
      m_twend = "";
      m_status = "Status: Awaiting user action.";
      m_inputs_valid = false;
      // Logical color blocks for grouping (for UI rendering)
      m_block_mode = "green";
      m_block_lot = "green";
      m_block_sl = "yellow";
      m_block_repl = "yellow";
      m_block_risk = "blue";
      m_block_reward = "blue";
      m_block_open = "orange";
      m_block_close = "orange";
      m_block_twstart = "purple";
      m_block_twend = "purple";
      m_block_status = "blue";
     }

   void ValidateInputs()
     {
      m_inputs_valid = true;
      if(m_lot <= 0) { m_inputs_valid = false; m_tip_lot = "Lot size must be greater than 0."; }
      if(m_sl < 1) { m_inputs_valid = false; m_tip_sl = "Stop Loss must be at least 1 pip."; }
      if(m_repl < 0) { m_inputs_valid = false; m_tip_repl = "Max Replacements must be 0 or more."; }
      if(m_risk <= 0) { m_inputs_valid = false; m_tip_risk = "Risk value must be greater than 0."; }
      if(m_reward <= 0) { m_inputs_valid = false; m_tip_reward = "Reward value must be greater than 0."; }
      // ...validate time fields as needed...
      if(m_inputs_valid)
         m_status = "Status: Ready to start EA.";
      else
         m_status = "Status: Invalid input(s). Hover for details.";
     }

   void OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
      // Handle input changes, button clicks, etc.
      // Call ValidateInputs() on relevant events
     }

   void Delete()
     {
      // Stub: Delete panel controls only
     }

   void SetStatus(string status)
     {
      m_status = status;
     }

   // Setters
   void SetMode(int mode) { m_mode = mode; }
   void SetLot(double lot) { m_lot = lot; }
   void SetSL(double sl) { m_sl = sl; }
   void SetRepl(int repl) { m_repl = repl; }
   void SetRisk(double risk) { m_risk = risk; }
   void SetReward(double reward) { m_reward = reward; }
   void SetOpenTime(string open_time) { m_open_time = open_time; }
   void SetCloseTime(string close_time) { m_close_time = close_time; }
   void SetTWStart(string twstart) { m_twstart = twstart; }
   void SetTWEnd(string twend) { m_twend = twend; }
   void SetInputsValid(bool valid) { m_inputs_valid = valid; }

   // Getters
   int GetMode() const { return m_mode; }
   double GetLot() const { return m_lot; }
   double GetSL() const { return m_sl; }
   int GetRepl() const { return m_repl; }
   double GetRisk() const { return m_risk; }
   double GetReward() const { return m_reward; }
   string GetOpenTime() const { return m_open_time; }
   string GetCloseTime() const { return m_close_time; }
   string GetTWStart() const { return m_twstart; }
   string GetTWEnd() const { return m_twend; }
   string GetStatus() const { return m_status; }
   bool GetInputsValid() const { return m_inputs_valid; }

   // Tooltips
   string GetTipMode() const { return m_tip_mode; }
   string GetTipLot() const { return m_tip_lot; }
   string GetTipSL() const { return m_tip_sl; }
   string GetTipRepl() const { return m_tip_repl; }
   string GetTipRisk() const { return m_tip_risk; }
   string GetTipReward() const { return m_tip_reward; }
   string GetTipOpen() const { return m_tip_open; }
   string GetTipClose() const { return m_tip_close; }
   string GetTipTWStart() const { return m_tip_twstart; }
   string GetTipTWEnd() const { return m_tip_twend; }

   // Color blocks (for UI rendering)
   string GetBlockMode() const { return m_block_mode; }
   string GetBlockLot() const { return m_block_lot; }
   string GetBlockSL() const { return m_block_sl; }
   string GetBlockRepl() const { return m_block_repl; }
   string GetBlockRisk() const { return m_block_risk; }
   string GetBlockReward() const { return m_block_reward; }
   string GetBlockOpen() const { return m_block_open; }
   string GetBlockClose() const { return m_block_close; }
   string GetBlockTWStart() const { return m_block_twstart; }
   string GetBlockTWEnd() const { return m_block_twend; }
   string GetBlockStatus() const { return m_block_status; }
  };

#endif // __INTERFACE_GUI_MQH__
