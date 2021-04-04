#include <stdlib.h>
#include <err.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>

#include "lib.c"

typedef struct {
  Window *ids;
  ulong size;
} WinList;

// result should be freed
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
  char *p = strchr(s, ch);
  if (!p) return -1;
  return (ulong)(p - s);
}

typedef struct {
  char *resource;
  char *class_name;
} ResClass;

// result should be freed
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

  Atom utf8_str = XInternAtom(dpy, "UTF8_STRING", False);
  bool r = prop(dpy, wid, utf8_str, "_NET_WM_NAME", &prop_val, &prop_size);
  if (r && prop_val) return (char*)prop_val;

  prop(dpy, wid, XA_STRING, "WM_NAME", &prop_val, &prop_size);
  return (char*)prop_val;
}



int main() {
  Display *dpy = XOpenDisplay(getenv("DISPLAY"));
  if (!dpy) errx(1, "failed to open display %s", getenv("DISPLAY"));

  WinList list = winlist(dpy);
  for (ulong idx = 0; idx < list.size; idx++) {
    ulong wid = list.ids[idx];

    char *host = wm_client_machine(dpy, wid);
    char *name = wm_name(dpy, wid);
    ResClass rc = wm_class(dpy, wid);

    long desk = desktop(dpy, wid);
    desk < 0 ? printf("*") : printf("%ld", desk);

    printf(" | %s | %s | %s | 0x%lx\n", host, rc.class_name, name, wid);

    free(host);
    free(name);
    free(rc.resource);
    free(rc.class_name);
  }

  XFree(list.ids);
}
