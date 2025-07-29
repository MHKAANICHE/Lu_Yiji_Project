//+------------------------------------------------------------------+
//| Tooltip.mqh (extracted for project root)                        |
//+------------------------------------------------------------------+
class CTooltip
  {
private:
   string m_header;
public:
   CTooltip() : m_header("") {}
   void WindowPointer(void* wnd) {}
   void ElementPointer(void* element) {}
   void Header(string text) { m_header = text; }
   void AddString(string text) {}
   void Delete() {}
};
// ...minimal stub for compatibility...
