//+------------------------------------------------------------------+
//|                 InterfaceGui.mqh                                 |
//|   Inspired by One_Trade_EA_UI_Mockup.html                       |
//|   Cross-platform, no chart objects                              |
//+------------------------------------------------------------------+
#ifndef __INTERFACE_GUI_MQH__
#define __INTERFACE_GUI_MQH__

// This file defines a stub interface for the EA GUI, inspired by the HTML mockup.
// No chart object code. Only class, member variables, and stub methods.

class CInterfaceGui
  {
private:
   string m_prefix;
   int m_x, m_y, m_w;
   // Controls (stub representations)
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
   string m_status;
   bool m_inputs_valid;
public:
   CInterfaceGui() : m_prefix("Gui"), m_x(30), m_y(30), m_w(540), m_mode(0), m_lot(0.10), m_sl(20), m_repl(2), m_risk(1.0), m_reward(2.0), m_open_time("09:00"), m_close_time("17:00"), m_twstart(""), m_twend(""), m_status("Status: Awaiting user action."), m_inputs_valid(false) {}
   void Create(const string prefix, int x, int y, int w=540)
     {
      m_prefix = prefix; m_x = x; m_y = y; m_w = w;
      // Initialize controls (stub logic)
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
     }
   void ValidateInputs()
     {
      m_inputs_valid = true;
      if(m_lot <= 0) { m_inputs_valid = false; }
      if(m_sl < 1) { m_inputs_valid = false; }
      if(m_repl < 0) { m_inputs_valid = false; }
      if(m_risk <= 0) { m_inputs_valid = false; }
      if(m_reward <= 0) { m_inputs_valid = false; }
      // ...validate time fields as needed...
      if(m_inputs_valid)
         m_status = "Status: Ready to start EA.";
      else
         m_status = "Status: Invalid input(s).";
     }
   void OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     {
      // Handle input changes, button clicks, etc. (stub)
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
  };

#endif // __INTERFACE_GUI_MQH__
