#ifndef XW_H_INCLUDED
#define XW_H_INCLUDED

typedef struct {
  bool _NET_WM_STATE_SHADED;
  bool _NET_WM_STATE_HIDDEN;
  Window id;
} WindowState;

typedef struct {
  Atom _NET_WM_STATE_SHADED;
  Atom _NET_WM_STATE_HIDDEN;
  Atom UTF8_STRING;
} MyAtoms;



#endif
