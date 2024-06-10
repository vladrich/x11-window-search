/*
  produces line-delimited JSON of currently managed windows by an X
  window manager:

  {"desk":0,"host":"hm76","name":"xterm","resource":"xterm","class":"XTerm","id":67108878}
*/

#include <err.h>
#include <stdio.h>
#include <stdbool.h>
#include <math.h>

#include <X11/Xutil.h>
#include <jansson.h>

#include "lib.c"

typedef struct {
  Window *ids;
  ulong size;
} WinList;

// result (WinList.ids) should be freed
WinList winlist(Display *dpy) {
  WinList list = { .ids = NULL };
  u_char *result;

  if (!prop(dpy, DefaultRootWindow(dpy), XA_WINDOW, "_NET_CLIENT_LIST_STACKING",
            &result, &list.size)) {
    return list;
  }

  list.ids = (Window*)result;
  return list;
}

// result should be freed
char* wm_client_machine(Display *dpy, Window wid) {
  u_char *prop_val = NULL;
  ulong prop_size;
  prop(dpy, wid, XA_STRING, "WM_CLIENT_MACHINE", &prop_val, &prop_size);
  return prop_val ? (char*)prop_val : strdup("nil");
}

// result (XClassHint.*) should be freed
XClassHint wm_class(Display *dpy, Window wid) {
  XClassHint r = { .res_name = NULL };
  XGetClassHint(dpy, wid, &r);
  if (!r.res_name) r.res_name = strdup("nil");
  if (!r.res_class) r.res_class = strdup("nil");
  return r;
}

// result should be freed
char* wm_name(Display *dpy, Window wid) {
  u_char *prop_val = NULL;
  ulong prop_size;

  bool r = prop(dpy, wid, myAtoms.UTF8_STRING, "_NET_WM_NAME", &prop_val, &prop_size);
  if (r && prop_val) return (char*)prop_val;

  prop(dpy, wid, XA_STRING, "WM_NAME", &prop_val, &prop_size);
  return prop_val ? (char*)prop_val : strdup("nil");
}

long desktop_current(Display *dpy) {
  u_char *prop_val = NULL;
  ulong prop_size;
  long r = -1;
  if (!prop(dpy, DefaultRootWindow(dpy), XA_CARDINAL, "_NET_CURRENT_DESKTOP",
            &prop_val, &prop_size))
    return r;

  if (prop_val) r = ((long*)prop_val)[0];
  free(prop_val);
  return r;
}



int main() {
  Display *dpy = XOpenDisplay(getenv("DISPLAY"));
  if (!dpy) errx(1, "failed to open display %s", getenv("DISPLAY"));
  mk_atoms(dpy);

  WinList list = winlist(dpy);
  for (long idx = list.size-1; idx >= 0; idx--) {
    ulong wid = list.ids[idx];

    char *host = wm_client_machine(dpy, wid);
    char *name = wm_name(dpy, wid);
    XClassHint rc = wm_class(dpy, wid);
    long desk = desktop(dpy, wid);
    bool is_desk_cur = desk < 0 || desk == desktop_current(dpy);

    json_t *line = json_object();
    json_object_set_new(line, "desk", json_integer(desk));
    json_object_set_new(line, "desk_cur", json_boolean(is_desk_cur));
    json_object_set_new(line, "host", json_string(host));
    json_object_set_new(line, "name", json_string(name));
    json_object_set_new(line, "resource", json_string(rc.res_name));
    json_object_set_new(line, "class", json_string(rc.res_class));
    json_object_set_new(line, "id", json_integer(wid));

    char *dump = json_dumps(line, JSON_COMPACT);
    printf("%s\n", dump);
    free(dump);
    json_decref(line);

    free(host);
    free(name);
    free(rc.res_name);
    free(rc.res_class);
  }
  XFree(list.ids);
}
