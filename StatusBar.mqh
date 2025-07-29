//+------------------------------------------------------------------+
//| StatusBar.mqh (extracted for project root)                      |
//+------------------------------------------------------------------+
class CStatusBar
  {
private:
   string m_status;
public:
   CStatusBar() : m_status("") {}
   void AddItem(int width) {}
   void CreateStatusBar(const long chart_id,const int subwin,const int x,const int y) {}
   void ValueToItem(int index, string value) { m_status = value; }
   void Delete() {}
};
// ...minimal stub for compatibility...
