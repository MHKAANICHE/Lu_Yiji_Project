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
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_XSIZE, 100);
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_BGCOLOR, C'232,245,233');
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_ModeBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_ModeLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ModeLabel", OBJPROP_XDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_ModeLabel", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_ModeLabel", OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, m_prefix+"_ModeLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_ModeLabel", OBJPROP_TEXT, "Mode:");
      ObjectSetInteger(0, m_prefix+"_ModeLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_ModeValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_ModeValue", OBJPROP_XDISTANCE, 90);
      ObjectSetInteger(0, m_prefix+"_ModeValue", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_ModeValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_ModeValue", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_ModeValue", OBJPROP_TEXT, (m_mode == 0 ? "Buy" : "Sell"));
      ObjectSetInteger(0, m_prefix+"_ModeValue", OBJPROP_HIDDEN, false);

      // Lot block (green)
      ObjectCreate(0, m_prefix+"_LotBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_XDISTANCE, 130);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_XSIZE, 100);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_BGCOLOR, C'232,245,233');
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_LotBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_LotLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_LotLabel", OBJPROP_XDISTANCE, 140);
      ObjectSetInteger(0, m_prefix+"_LotLabel", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_LotLabel", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_LotLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_LotLabel", OBJPROP_TEXT, "Lot Size:");
      ObjectSetInteger(0, m_prefix+"_LotLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_LotValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_LotValue", OBJPROP_XDISTANCE, 200);
      ObjectSetInteger(0, m_prefix+"_LotValue", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_LotValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_LotValue", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_LotValue", OBJPROP_TEXT, DoubleToString(m_lot,2));
      ObjectSetInteger(0, m_prefix+"_LotValue", OBJPROP_HIDDEN, false);

      // SL block (yellow)
      ObjectCreate(0, m_prefix+"_SLBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_XDISTANCE, 240);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_XSIZE, 100);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_BGCOLOR, C'255,253,231');
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_COLOR, C'251,192,45');
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_SLBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_SLLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_SLLabel", OBJPROP_XDISTANCE, 250);
      ObjectSetInteger(0, m_prefix+"_SLLabel", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_SLLabel", OBJPROP_COLOR, C'251,192,45');
      ObjectSetInteger(0, m_prefix+"_SLLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_SLLabel", OBJPROP_TEXT, "Stop Loss:");
      ObjectSetInteger(0, m_prefix+"_SLLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_SLValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_SLValue", OBJPROP_XDISTANCE, 310);
      ObjectSetInteger(0, m_prefix+"_SLValue", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_SLValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_SLValue", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_SLValue", OBJPROP_TEXT, IntegerToString((int)m_sl));
      ObjectSetInteger(0, m_prefix+"_SLValue", OBJPROP_HIDDEN, false);

      // Risk block (blue)
      ObjectCreate(0, m_prefix+"_RiskBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_XDISTANCE, 350);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_XSIZE, 100);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_BGCOLOR, C'227,242,253');
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_RiskBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_RiskLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_RiskLabel", OBJPROP_XDISTANCE, 360);
      ObjectSetInteger(0, m_prefix+"_RiskLabel", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_RiskLabel", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_RiskLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_RiskLabel", OBJPROP_TEXT, "Risk:");
      ObjectSetInteger(0, m_prefix+"_RiskLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_RiskValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_RiskValue", OBJPROP_XDISTANCE, 420);
      ObjectSetInteger(0, m_prefix+"_RiskValue", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_RiskValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_RiskValue", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_RiskValue", OBJPROP_TEXT, DoubleToString(m_risk,2));
      ObjectSetInteger(0, m_prefix+"_RiskValue", OBJPROP_HIDDEN, false);

      // Reward block (blue)
      ObjectCreate(0, m_prefix+"_RewardBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_XDISTANCE, 460);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_XSIZE, 100);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_BGCOLOR, C'227,242,253');
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_RewardBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_RewardLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_RewardLabel", OBJPROP_XDISTANCE, 470);
      ObjectSetInteger(0, m_prefix+"_RewardLabel", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_RewardLabel", OBJPROP_COLOR, C'56,142,60');
      ObjectSetInteger(0, m_prefix+"_RewardLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_RewardLabel", OBJPROP_TEXT, "Reward:");
      ObjectSetInteger(0, m_prefix+"_RewardLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_RewardValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_RewardValue", OBJPROP_XDISTANCE, 530);
      ObjectSetInteger(0, m_prefix+"_RewardValue", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_RewardValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_RewardValue", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_RewardValue", OBJPROP_TEXT, DoubleToString(m_reward,2));
      ObjectSetInteger(0, m_prefix+"_RewardValue", OBJPROP_HIDDEN, false);

      // Open time block (orange)
      ObjectCreate(0, m_prefix+"_OpenBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_XDISTANCE, 570);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_XSIZE, 100);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_BGCOLOR, C'255,243,224');
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_COLOR, C'245,124,0');
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_OpenBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_OpenLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_OpenLabel", OBJPROP_XDISTANCE, 580);
      ObjectSetInteger(0, m_prefix+"_OpenLabel", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_OpenLabel", OBJPROP_COLOR, C'245,124,0');
      ObjectSetInteger(0, m_prefix+"_OpenLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_OpenLabel", OBJPROP_TEXT, "Open Time:");
      ObjectSetInteger(0, m_prefix+"_OpenLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_OpenValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_OpenValue", OBJPROP_XDISTANCE, 640);
      ObjectSetInteger(0, m_prefix+"_OpenValue", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_OpenValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_OpenValue", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_OpenValue", OBJPROP_TEXT, m_open_time);
      ObjectSetInteger(0, m_prefix+"_OpenValue", OBJPROP_HIDDEN, false);

      // Close time block (orange)
      ObjectCreate(0, m_prefix+"_CloseBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_XDISTANCE, 680);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_XSIZE, 100);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_BGCOLOR, C'255,243,224');
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_COLOR, C'245,124,0');
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_CloseBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_CloseLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_CloseLabel", OBJPROP_XDISTANCE, 690);
      ObjectSetInteger(0, m_prefix+"_CloseLabel", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_CloseLabel", OBJPROP_COLOR, C'211,47,47');
      ObjectSetInteger(0, m_prefix+"_CloseLabel", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_CloseLabel", OBJPROP_TEXT, "Close Time:");
      ObjectSetInteger(0, m_prefix+"_CloseLabel", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_CloseValue", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_CloseValue", OBJPROP_XDISTANCE, 750);
      ObjectSetInteger(0, m_prefix+"_CloseValue", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_CloseValue", OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, m_prefix+"_CloseValue", OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, m_prefix+"_CloseValue", OBJPROP_TEXT, m_close_time);
      ObjectSetInteger(0, m_prefix+"_CloseValue", OBJPROP_HIDDEN, false);

      // Status panel (blue)
      ObjectCreate(0, m_prefix+"_StatusBlock", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_XDISTANCE, 300);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_YDISTANCE, 70);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_XSIZE, 440);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_YSIZE, 40);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_BGCOLOR, C'227,242,253');
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_prefix+"_StatusBlock", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_StatusLabel", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_XDISTANCE, 310);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_YDISTANCE, 80);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, m_prefix+"_StatusLabel", OBJPROP_TEXT, m_status);
      ObjectSetInteger(0, m_prefix+"_StatusLabel", OBJPROP_HIDDEN, false);

      // Start EA button (blue)
      ObjectCreate(0, m_prefix+"_StartEAButton", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_XDISTANCE, 30);
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_YDISTANCE, 120);
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_XSIZE, 120);
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_YSIZE, 32);
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_BGCOLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_COLOR, C'25,118,210');
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_CORNER, 6);
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, m_prefix+"_StartEAButton", OBJPROP_HIDDEN, false);
      ObjectCreate(0, m_prefix+"_StartEAButtonText", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, m_prefix+"_StartEAButtonText", OBJPROP_XDISTANCE, 54);
      ObjectSetInteger(0, m_prefix+"_StartEAButtonText", OBJPROP_YDISTANCE, 128);
      ObjectSetInteger(0, m_prefix+"_StartEAButtonText", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, m_prefix+"_StartEAButtonText", OBJPROP_FONTSIZE, 13);
      ObjectSetString(0, m_prefix+"_StartEAButtonText", OBJPROP_TEXT, "Start EA");
      ObjectSetInteger(0, m_prefix+"_StartEAButtonText", OBJPROP_HIDDEN, false);

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
