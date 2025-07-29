//+------------------------------------------------------------------+
//| EventHandler.mqh - Minimal UI Event Handling for One Trade EA    |
//+------------------------------------------------------------------+
#ifndef __EVENTHANDLER_MQH__
#define __EVENTHANDLER_MQH__

#include <Trade/Trade.mqh>
#include "OneTradeEA_Core.mqh"
#include "InterfaceGui.mqh"

// Extern declaration for coreEA instance (must be defined in main EA file)
extern COneTradeEA_Core *coreEA;

// Extern declaration for logical UI panel (must be defined in main EA file)
extern CInterfaceGui mainPanel;

// User input fields (object names)
#define OBJ_MODE_INPUT           "ModeInput"
#define OBJ_LOT_INPUT            "LotInput"
#define OBJ_SL_INPUT             "SLInput"
#define OBJ_RR_INPUT             "RRInput"
#define OBJ_OPEN_TIME_INPUT      "OpenTimeInput"
#define OBJ_CLOSE_TIME_INPUT     "CloseTimeInput"
#define OBJ_REPLACE_INPUT        "ReplaceInput"
#define OBJ_TIME_WINDOW_INPUT    "TimeWindowInput"
#define OBJ_START_BUTTON         "StartEAButton"
#define OBJ_REPLACE_BUTTON       "ReplaceOrderButton"
#define OBJ_STATUS_LABEL         "StatusLabel"

// Error/status messages
#define MSG_INPUT_ERROR          "Input error: Please check all fields."
#define MSG_EA_STARTED           "EA started successfully."
#define MSG_REPLACE_ERROR        "Cannot replace order: Check conditions."
#define MSG_REPLACE_SUCCESS      "Replacement order placed."

//+------------------------------------------------------------------+
//| Validate numeric input                                          |
//+------------------------------------------------------------------+
bool ValidateNumeric(const string value, double &out)
{
   out = StringToDouble(value);
   return (StringLen(value) > 0 && out > 0);
}

//+------------------------------------------------------------------+
//| Validate time input (HH:MM or HH:MM:SS)                         |
//+------------------------------------------------------------------+
bool ValidateTime(const string value)
{
   string parts[];
   int count = StringSplit(value, ':', parts);
   return (count == 2 || count == 3);
}

//+------------------------------------------------------------------+
//| Show message to user                                            |
//+------------------------------------------------------------------+
void ShowStatus(const string msg)
{
   ObjectSetString(0, OBJ_STATUS_LABEL, OBJPROP_TEXT, msg);
}

//+------------------------------------------------------------------+
//| Collect all user inputs                                         |
//+------------------------------------------------------------------+
bool CollectInputs(string &mode, double &lot, double &sl, double &rr,
                  string &openTime, string &closeTime, int &replace, string &timeWindow)
{
   mode      = ObjectGetString(0, OBJ_MODE_INPUT, OBJPROP_TEXT);
   string lotStr = ObjectGetString(0, OBJ_LOT_INPUT, OBJPROP_TEXT);
   string slStr  = ObjectGetString(0, OBJ_SL_INPUT, OBJPROP_TEXT);
   string rrStr  = ObjectGetString(0, OBJ_RR_INPUT, OBJPROP_TEXT);
   openTime  = ObjectGetString(0, OBJ_OPEN_TIME_INPUT, OBJPROP_TEXT);
   closeTime = ObjectGetString(0, OBJ_CLOSE_TIME_INPUT, OBJPROP_TEXT);
   string replaceStr = ObjectGetString(0, OBJ_REPLACE_INPUT, OBJPROP_TEXT);
   timeWindow = ObjectGetString(0, OBJ_TIME_WINDOW_INPUT, OBJPROP_TEXT);

   if(!ValidateNumeric(lotStr, lot) || !ValidateNumeric(slStr, sl) || !ValidateNumeric(rrStr, rr))
   {
      ShowStatus(MSG_INPUT_ERROR);
      return false;
   }
   if(!ValidateTime(openTime) || !ValidateTime(closeTime))
   {
      ShowStatus(MSG_INPUT_ERROR);
      return false;
   }
   replace = (int)StringToInteger(replaceStr);
   if(replace < 0)
   {
      ShowStatus(MSG_INPUT_ERROR);
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Main event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == OBJ_START_BUTTON)
      {
         // ...existing code for start button...
         string modeStr = ObjectGetString(0, OBJ_MODE_INPUT, OBJPROP_TEXT);
         double lot = StringToDouble(ObjectGetString(0, OBJ_LOT_INPUT, OBJPROP_TEXT));
         double sl = StringToDouble(ObjectGetString(0, OBJ_SL_INPUT, OBJPROP_TEXT));
         int repl = (int)StringToInteger(ObjectGetString(0, OBJ_REPLACE_INPUT, OBJPROP_TEXT));
         double risk = StringToDouble(ObjectGetString(0, OBJ_RR_INPUT, OBJPROP_TEXT));
         double reward = StringToDouble(ObjectGetString(0, OBJ_RR_INPUT, OBJPROP_TEXT));
         string openTime = ObjectGetString(0, OBJ_OPEN_TIME_INPUT, OBJPROP_TEXT);
         string closeTime = ObjectGetString(0, OBJ_CLOSE_TIME_INPUT, OBJPROP_TEXT);
         string twstart = ObjectGetString(0, OBJ_TIME_WINDOW_INPUT, OBJPROP_TEXT);
         string twend = "";
         mainPanel.SetMode(modeStr == "Buy" ? 0 : 1);
         mainPanel.SetLot(lot);
         mainPanel.SetSL(sl);
         mainPanel.SetRepl(repl);
         mainPanel.SetRisk(risk);
         mainPanel.SetReward(reward);
         mainPanel.SetOpenTime(openTime);
         mainPanel.SetCloseTime(closeTime);
         mainPanel.SetTWStart(twstart);
         mainPanel.SetTWEnd(twend);
         mainPanel.ValidateInputs();
         ShowStatus(mainPanel.GetStatus());
         if(mainPanel.GetInputsValid())
         {
            ENUM_ORDER_TYPE orderType = (mainPanel.GetMode() == 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
            coreEA.Init(orderType, mainPanel.GetLot(), mainPanel.GetSL(), mainPanel.GetRisk(), mainPanel.GetReward(), mainPanel.GetOpenTime(), mainPanel.GetCloseTime(), mainPanel.GetRepl(), mainPanel.GetTWStart(), mainPanel.GetTWEnd(), Symbol());
            ShowStatus(MSG_EA_STARTED);
            // Lock input fields
            ObjectSetInteger(0, OBJ_MODE_INPUT, OBJPROP_READONLY, true);
            ObjectSetInteger(0, OBJ_LOT_INPUT, OBJPROP_READONLY, true);
            ObjectSetInteger(0, OBJ_SL_INPUT, OBJPROP_READONLY, true);
            ObjectSetInteger(0, OBJ_RR_INPUT, OBJPROP_READONLY, true);
            ObjectSetInteger(0, OBJ_OPEN_TIME_INPUT, OBJPROP_READONLY, true);
            ObjectSetInteger(0, OBJ_CLOSE_TIME_INPUT, OBJPROP_READONLY, true);
            ObjectSetInteger(0, OBJ_REPLACE_INPUT, OBJPROP_READONLY, true);
            ObjectSetInteger(0, OBJ_TIME_WINDOW_INPUT, OBJPROP_READONLY, true);
         }
      }
      else if(sparam == OBJ_REPLACE_BUTTON)
      {
         // ...existing code for replace button...
         double entryPrice = 0.0;
         double stopLoss = 0.0;
         bool canReplace = true;
         if(canReplace)
         {
            coreEA.OpenPendingOrder(entryPrice, stopLoss);
            ShowStatus(MSG_REPLACE_SUCCESS);
         }
         else
         {
            ShowStatus(MSG_REPLACE_ERROR);
         }
      }
      else if(sparam == "ResetButton")
      {
         // Unlock input fields and reset status
         ObjectSetInteger(0, OBJ_MODE_INPUT, OBJPROP_READONLY, false);
         ObjectSetInteger(0, OBJ_LOT_INPUT, OBJPROP_READONLY, false);
         ObjectSetInteger(0, OBJ_SL_INPUT, OBJPROP_READONLY, false);
         ObjectSetInteger(0, OBJ_RR_INPUT, OBJPROP_READONLY, false);
         ObjectSetInteger(0, OBJ_OPEN_TIME_INPUT, OBJPROP_READONLY, false);
         ObjectSetInteger(0, OBJ_CLOSE_TIME_INPUT, OBJPROP_READONLY, false);
         ObjectSetInteger(0, OBJ_REPLACE_INPUT, OBJPROP_READONLY, false);
         ObjectSetInteger(0, OBJ_TIME_WINDOW_INPUT, OBJPROP_READONLY, false);
         // Reset input fields to initial/default values
         ObjectSetString(0, OBJ_MODE_INPUT, OBJPROP_TEXT, "Buy");
         ObjectSetString(0, OBJ_LOT_INPUT, OBJPROP_TEXT, "0.10");
         ObjectSetString(0, OBJ_SL_INPUT, OBJPROP_TEXT, "20");
         ObjectSetString(0, OBJ_RR_INPUT, OBJPROP_TEXT, "1.00");
         ObjectSetString(0, OBJ_OPEN_TIME_INPUT, OBJPROP_TEXT, "09:00");
         ObjectSetString(0, OBJ_CLOSE_TIME_INPUT, OBJPROP_TEXT, "17:00");
         ObjectSetString(0, OBJ_REPLACE_INPUT, OBJPROP_TEXT, "2");
         ObjectSetString(0, OBJ_TIME_WINDOW_INPUT, OBJPROP_TEXT, "");
         mainPanel.Create("Gui", 30, 30, 540);
         mainPanel.ValidateInputs();
         ShowStatus("Fields reset to default. You may edit parameters.");
      }
   }
   // Handle input field changes for responsive UI
   if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      // Update mainPanel state and validate on any input field change
      string modeStr = ObjectGetString(0, OBJ_MODE_INPUT, OBJPROP_TEXT);
      double lot = StringToDouble(ObjectGetString(0, OBJ_LOT_INPUT, OBJPROP_TEXT));
      double sl = StringToDouble(ObjectGetString(0, OBJ_SL_INPUT, OBJPROP_TEXT));
      int repl = (int)StringToInteger(ObjectGetString(0, OBJ_REPLACE_INPUT, OBJPROP_TEXT));
      double risk = StringToDouble(ObjectGetString(0, OBJ_RR_INPUT, OBJPROP_TEXT));
      double reward = StringToDouble(ObjectGetString(0, OBJ_RR_INPUT, OBJPROP_TEXT));
      string openTime = ObjectGetString(0, OBJ_OPEN_TIME_INPUT, OBJPROP_TEXT);
      string closeTime = ObjectGetString(0, OBJ_CLOSE_TIME_INPUT, OBJPROP_TEXT);
      string twstart = ObjectGetString(0, OBJ_TIME_WINDOW_INPUT, OBJPROP_TEXT);
      string twend = "";
      mainPanel.SetMode(modeStr == "Buy" ? 0 : 1);
      mainPanel.SetLot(lot);
      mainPanel.SetSL(sl);
      mainPanel.SetRepl(repl);
      mainPanel.SetRisk(risk);
      mainPanel.SetReward(reward);
      mainPanel.SetOpenTime(openTime);
      mainPanel.SetCloseTime(closeTime);
      mainPanel.SetTWStart(twstart);
      mainPanel.SetTWEnd(twend);
      mainPanel.ValidateInputs();
      ShowStatus(mainPanel.GetStatus());
   }



}

#endif // __EVENTHANDLER_MQH__
//+------------------------------------------------------------------+
