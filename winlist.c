/*
  produces line-delimited JSON of currently managed windows by an X
  window manager:

  {"desk":0,"host":"hm76","name":"xterm","resource":"xterm","class":"XTerm","id":67108878}
*/

#include <stdlib.h>
#include <err.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <jansson.h>

#include "lib.c"

typedef struct {
  Window *ids;
  ulong size;
} WinList;

// result (WinList.ids) should be freed
WinList winlist(Display *dpy) {
  WinList list;
  u_char *result;

  if (!prop(dpy, DefaultRootWindow(dpy), XA_WINDOW, "_NET_CLIENT_LIST",
            &result, &list.size)) {
    list.size = -1;
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
  return (char*)prop_val;
}

ulong str_index(const char *s, char ch) {
  const char *p = strchr(s, ch);
  if (!p) return -1;
  return (ulong)(p - s);
}

typedef struct {
  char *resource;
  char *class_name;
} ResClass;

// result (ResClass.*) should be freed
ResClass wm_class(Display *dpy, Window wid) {
  ResClass r = {.resource = NULL};

  u_char *prop_val = NULL;
  ulong prop_size;
  if (!prop(dpy, wid, XA_STRING, "WM_CLASS", &prop_val, &prop_size))
    return r;

  ulong idx = str_index((char*)prop_val, '\0');
  if (idx < prop_size) {
    r.resource = (char*)malloc(idx+2);
    snprintf(r.resource, idx+1, "%s", prop_val);

    ulong len = prop_size-idx;
    r.class_name = (char*)malloc(len+1);
    snprintf(r.class_name, len, "%s", prop_val+idx+1);
  }

  free(prop_val);
  return r;
}

// result should be freed
char* wm_name(Display *dpy, Window wid) {
  u_char *prop_val = NULL;
  ulong prop_size;

  bool r = prop(dpy, wid, myAtoms.UTF8_STRING, "_NET_WM_NAME", &prop_val, &prop_size);
  if (r && prop_val) return (char*)prop_val;

  prop(dpy, wid, XA_STRING, "WM_NAME", &prop_val, &prop_size);
  return (char*)prop_val;
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
  for (ulong idx = 0; idx < list.size; idx++) {
    ulong wid = list.ids[idx];

    char *host = wm_client_machine(dpy, wid);
    char *name = wm_name(dpy, wid);
    ResClass rc = wm_class(dpy, wid);
    long desk = desktop(dpy, wid);
    bool is_desk_cur = desk < 0 || desk == desktop_current(dpy);

    json_t *line = json_object();
    json_object_set_new(line, "desk", json_integer(desk));
    json_object_set_new(line, "desk_cur", json_boolean(is_desk_cur));
    json_object_set_new(line, "host", json_string(host));
    json_object_set_new(line, "name", json_string(name));
    json_object_set_new(line, "resource", json_string(rc.resource));
    json_object_set_new(line, "class", json_string(rc.class_name));
    json_object_set_new(line, "id", json_integer(wid));

    char *dump = json_dumps(line, JSON_COMPACT);
    printf("%s\n", dump);
    free(dump);
    json_decref(line);

    free(host);
    free(name);
    free(rc.resource);
    free(rc.class_name);
  }
  XFree(list.ids);
}
