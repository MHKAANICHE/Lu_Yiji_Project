//+------------------------------------------------------------------+
//| SimpleButton.mqh (extracted for project root)                   |
//+------------------------------------------------------------------+
class CSimpleButton
  {
private:
   bool m_button_state;
   bool m_two_state;
public:
   CSimpleButton() : m_button_state(true), m_two_state(false) {}
   void CreateSimpleButton(const long chart_id,const int subwin,const string button_text,const int x,const int y) {}
   void ButtonState(const bool state) { m_button_state = state; }
   bool IsPressed(void) const { return m_button_state; }
   void Delete() {}
};
// ...minimal stub for compatibility...
