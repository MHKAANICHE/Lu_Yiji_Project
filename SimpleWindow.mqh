//+------------------------------------------------------------------+
//|                 SimpleWindow.mqh                                 |
//|   Inspired by EasyAndFastGUI, minimal window for MQL5            |
//+------------------------------------------------------------------+
#ifndef __SIMPLE_WINDOW_MQH__
#define __SIMPLE_WINDOW_MQH__

#include <ChartObjects/ChartObjectsTxtControls.mqh>

class CSimpleWindow
  {
private:
   string m_name;
   int    m_x, m_y, m_w, m_h;
   string m_caption;
   string m_bgObj, m_captionObj;
   color  m_bgColor, m_captionColor;
   bool   m_visible;
public:
   CSimpleWindow() : m_name(""), m_x(0), m_y(0), m_w(200), m_h(100), m_caption("Window"), m_bgColor(clrWhite), m_captionColor(clrDodgerBlue), m_visible(false) {}
   void Create(const string name, int x, int y, int w, int h, string caption)
     {
      m_name = name;
      m_x = x; m_y = y; m_w = w; m_h = h; m_caption = caption;
      m_bgObj = m_name+"_bg";
      m_captionObj = m_name+"_caption";
      // Background
      if(!ObjectCreate(0, m_bgObj, OBJ_RECTANGLE_LABEL, 0, 0, 0)) return;
      ObjectSetInteger(0, m_bgObj, OBJPROP_XDISTANCE, m_x);
      ObjectSetInteger(0, m_bgObj, OBJPROP_YDISTANCE, m_y);
      ObjectSetInteger(0, m_bgObj, OBJPROP_XSIZE, m_w);
      ObjectSetInteger(0, m_bgObj, OBJPROP_YSIZE, m_h);
      ObjectSetInteger(0, m_bgObj, OBJPROP_BGCOLOR, m_bgColor);
      ObjectSetInteger(0, m_bgObj, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, m_bgObj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, m_bgObj, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, m_bgObj, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_bgObj, OBJPROP_HIDDEN, false);
      // Caption
      if(!ObjectCreate(0, m_captionObj, OBJ_LABEL, 0, 0, 0)) return;
      ObjectSetInteger(0, m_captionObj, OBJPROP_XDISTANCE, m_x+8);
      ObjectSetInteger(0, m_captionObj, OBJPROP_YDISTANCE, m_y+4);
      ObjectSetInteger(0, m_captionObj, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, m_captionObj, OBJPROP_COLOR, m_captionColor);
      ObjectSetInteger(0, m_captionObj, OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, m_captionObj, OBJPROP_TEXT, m_caption);
      ObjectSetInteger(0, m_captionObj, OBJPROP_HIDDEN, false);
      m_visible = true;
     }
   void SetCaption(string caption)
     {
      m_caption = caption;
      ObjectSetString(0, m_captionObj, OBJPROP_TEXT, m_caption);
     }
   void SetBgColor(color clr)
     {
      m_bgColor = clr;
      ObjectSetInteger(0, m_bgObj, OBJPROP_BGCOLOR, m_bgColor);
     }
   void SetCaptionColor(color clr)
     {
      m_captionColor = clr;
      ObjectSetInteger(0, m_captionObj, OBJPROP_COLOR, m_captionColor);
     }
   void Show()
     {
      ObjectSetInteger(0, m_bgObj, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, m_captionObj, OBJPROP_HIDDEN, false);
      m_visible = true;
     }
   void Hide()
     {
      ObjectSetInteger(0, m_bgObj, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, m_captionObj, OBJPROP_HIDDEN, true);
      m_visible = false;
     }
   void Delete()
     {
      ObjectDelete(0, m_bgObj);
      ObjectDelete(0, m_captionObj);
      m_visible = false;
     }
   bool Visible() { return m_visible; }
  };

#endif // __SIMPLE_WINDOW_MQH__
