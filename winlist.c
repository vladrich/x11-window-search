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

#include "lib.c"
#include "util.h"

extern struct item *items;
extern unsigned int lines;


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



int get_windows(Display *dpy) {
  mk_atoms(dpy);

  size_t i = 0;
  size_t itemsiz = 0;

  //printf("id,desk,desk_cur,host,name,resource,class\n");

  WinList list = winlist(dpy);
  for (long idx = list.size-1; idx >= 0; i++, idx--) {

    char *line = NULL;
    size_t linesiz = 0;

    ulong wid = list.ids[idx];

    char *host = wm_client_machine(dpy, wid);
    char *name = wm_name(dpy, wid);
    XClassHint rc = wm_class(dpy, wid);
    long desk = desktop(dpy, wid);
    bool is_desk_cur = desk < 0 || desk == desktop_current(dpy);

    //printf("%lu,%ld,%d,%s,%s,%s,%s\n", wid, desk, is_desk_cur, host, name, rc.res_name, rc.res_class);

    /* Determine required size */

    char *fmt = "%10lu    %-10.10s  %s\n";

    linesiz = snprintf(line, linesiz, fmt, wid, rc.res_class, name);

    if (linesiz < 0)
        return -1;

    linesiz++;             /* For '\0' */
    line = malloc(linesiz);
    if (line == NULL)
        return -1;

    linesiz = snprintf(line, linesiz, fmt, wid, rc.res_class, name);

    if (linesiz < 0) {
        free(line);
        return -1;
    }


    if (i + 1 >= itemsiz) {
	    itemsiz += 256;
	    if (!(items = realloc(items, itemsiz * sizeof(*items))))
		    die("cannot realloc %zu bytes:", itemsiz * sizeof(*items));
    }
    if (line[linesiz - 1] == '\n')
	    line[linesiz - 1] = '\0';
    items[i].text = line;

    items[i].out = 0;



    free(host);
    free(name);
    free(rc.res_name);
    free(rc.res_class);
  }
  if (items)
    items[i].text = NULL;
  lines = MIN(lines, i);
  XFree(list.ids);
  return lines;
}
