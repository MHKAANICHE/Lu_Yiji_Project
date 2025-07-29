//+------------------------------------------------------------------+
//| EventHandler.mqh - Minimal UI Event Handling for One Trade EA    |
//+------------------------------------------------------------------+
#ifndef __EVENTHANDLER_MQH__
#define __EVENTHANDLER_MQH__

#include <Trade/Trade.mqh>
#include "OneTradeEA_Core.mqh"

// Extern declaration for coreEA instance (must be defined in main EA file)
extern COneTradeEA_Core *coreEA;

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
         string mode, openTime, closeTime, timeWindow;
         double lot, sl, rr;
         int replace;
         if(CollectInputs(mode, lot, sl, rr, openTime, closeTime, replace, timeWindow))
         {
            // Link to core EA logic
            // You must map 'mode' string to ENUM_ORDER_TYPE, and provide all required parameters
            ENUM_ORDER_TYPE orderType = (mode == "Buy") ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
            // Dummy values for missing parameters (adjust as needed)
            double tp = 0.0;
            string symbol = Symbol();
            string comment = "OneTradeEA";
            int magic = 123456;
            coreEA.Init(orderType, lot, magic, sl, tp, symbol, comment, replace, openTime, closeTime, timeWindow);
            ShowStatus(MSG_EA_STARTED);
            // Lock input fields if needed
         }
      }
      else if(sparam == OBJ_REPLACE_BUTTON)
      {
         // Example: call coreEA replacement logic
         // You must provide entryPrice and sl for OpenPendingOrder
         double entryPrice = 0.0; // Get from last trade or UI as needed
         double stopLoss = 0.0;   // Get from last trade or UI as needed
         bool canReplace = true;  // Replace with actual logic if needed
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
   }
}

#endif // __EVENTHANDLER_MQH__
//+------------------------------------------------------------------+
