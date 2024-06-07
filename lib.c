#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>

bool prop(Display *dpy, Window wid, Atom expected_type, const char *name,
          u_char **result, ulong *size) {
  Atom type;
  int format;
  ulong bytes_after;

  Atom atom = XInternAtom(dpy, name, False);
  int r = XGetWindowProperty(dpy, wid, atom, 0L, ~0L, False,
                             expected_type, &type, &format,
                             size, &bytes_after, result);
  return r == Success && result;
}

long desktop(Display *dpy, Window wid) {
  u_char *prop_val = NULL;
  ulong prop_size;
  if (!prop(dpy, wid, XA_CARDINAL, "_NET_WM_DESKTOP", &prop_val, &prop_size))
    return -2;

  long r = -1; // means a window is in a 'sticky' mode
  if (prop_val) r = ((long*)prop_val)[0];
  free(prop_val);
  return r;
}

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

MyAtoms myAtoms;

void mk_atoms(Display *dpy) {
  myAtoms._NET_WM_STATE_SHADED = XInternAtom(dpy, "_NET_WM_STATE_SHADED", False);
  myAtoms._NET_WM_STATE_HIDDEN = XInternAtom(dpy, "_NET_WM_STATE_HIDDEN", False);
  myAtoms.UTF8_STRING = XInternAtom(dpy, "UTF8_STRING", False);
}

WindowState state(Display *dpy, Window id) {
  WindowState r = { .id = id };
  u_char *prop_val = NULL;
  ulong prop_size;
  if (!prop(dpy, id, XA_ATOM, "_NET_WM_STATE", &prop_val, &prop_size)) return r;

  Atom *atoms = (Atom*)prop_val;
  for (int idx = 0; idx < prop_size; idx++) {
    if (atoms[idx] == myAtoms._NET_WM_STATE_SHADED) r._NET_WM_STATE_SHADED = true;
    if (atoms[idx] == myAtoms._NET_WM_STATE_HIDDEN) r._NET_WM_STATE_HIDDEN = true;
  }
  XFree(prop_val);

  return r;
}

bool mkdir_p(const char *s, mode_t mode) {
  char *component = strdup(s);
  char *p = component;

  bool status = true;
  while (*p && *p == '/') p++; // skip leading '/'

  do {
    while (*p && *p != '/') p++;

    if (!*p)
      p = NULL;
    else
      *p = '\0';

    if (-1 == mkdir(component, mode) && errno != EEXIST) {
      status = false;
      break;
    } else if (p) {
      *p++ = '/';
      while (*p && *p == '/') p++;
    }

  } while (p);

  free(component);
  return status;
}
