//+------------------------------------------------------------------+
//| RadioButtons.mqh (extracted for project root)                   |
//+------------------------------------------------------------------+
class CRadioButtons
  {
private:
   int m_selected_button_index;
public:
   CRadioButtons() : m_selected_button_index(0) {}
   void AddButton(int x_gap, int y_gap, string text, int width) {}
   void CreateRadioButtons(const long chart_id,const int window,const int x,const int y) {}
   void SelectionRadioButton(int index) { m_selected_button_index = index; }
   void Delete() {}
};
// ...minimal stub for compatibility...
