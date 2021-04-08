#include <stdlib.h>
#include <err.h>
#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <limits.h>
#include <libgen.h>
#include <sys/stat.h>
#include <errno.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <jansson.h>

#include "lib.c"

ulong str2id(const char *s) {
    ulong id;
    if (sscanf(s, "0x%lx", &id) != 1 &&
        sscanf(s, "0X%lx", &id) != 1 &&
        sscanf(s, "%lu", &id) != 1) return 0;
    return id;
}

bool client_msg(Display *dpy, Window id, const char *msg,
                unsigned long data0, unsigned long data1,
                unsigned long data2, unsigned long data3,
                unsigned long data4) {
    XEvent event;
    long mask = SubstructureRedirectMask | SubstructureNotifyMask;

    event.xclient.type = ClientMessage;
    event.xclient.serial = 0;
    event.xclient.send_event = True;
    event.xclient.message_type = XInternAtom(dpy, msg, False);
    event.xclient.window = id;
    event.xclient.format = 32;
    event.xclient.data.l[0] = data0;
    event.xclient.data.l[1] = data1;
    event.xclient.data.l[2] = data2;
    event.xclient.data.l[3] = data3;
    event.xclient.data.l[4] = data4;

    if (XSendEvent(dpy, DefaultRootWindow(dpy), False, mask, &event))
      return true;
    warnx("cannot send %s event", msg);
    return false;
}

bool window_activate(Display *dpy, Window id) {
  long desk = desktop(dpy, id);
  if (-1 != desk) {
    client_msg(dpy, DefaultRootWindow(dpy), "_NET_CURRENT_DESKTOP",
               desk, 0, 0, 0, 0);
  }

  bool active = client_msg(dpy, id, "_NET_ACTIVE_WINDOW", 0, 0, 0, 0, 0);

  const int _net_wm_state_rm = 0;
  bool unshaded = client_msg(dpy, id, "_NET_WM_STATE", _net_wm_state_rm,
                             myAtoms._NET_WM_STATE_SHADED, 0, 0, 0);

  XMapRaised(dpy, id);
  return active && unshaded;
}

bool window_center_mouse(Display *dpy, ulong id) {
  XWindowAttributes attrs;
  if (!XGetWindowAttributes(dpy, id, &attrs)) return false;
  if (!XWarpPointer(dpy, 0, id, 0, 0, 0, 0, attrs.width/2, attrs.height/2))
    return false;
  XFlush(dpy);
  return true;
}

// the result shout be freed
char* config() {
  char xdg_runtime_home[PATH_MAX-64];
  if (getenv("XDG_RUNTIME_HOME")) {
    snprintf(xdg_runtime_home, PATH_MAX-64, "%s", getenv("XDG_RUNTIME_HOME"));
  } else {
    snprintf(xdg_runtime_home, PATH_MAX-64, "/run/user/%d", getuid());
  }
  char *file = (char*)malloc(PATH_MAX);
  snprintf(file, PATH_MAX, "%s/%s/%s",
           xdg_runtime_home, "fvwm-window-search", "last_window.json");

  char *dir = dirname(strdup(file));
  mkdir(xdg_runtime_home, 0755);
  int r = mkdir(dir, 0755); if (-1 == r && EEXIST != errno) {
    warn("failed to create %s", dir);
    return NULL;
  }
  free(dir);
  return file;
}

void state_save(Display *dpy, Window id) {
  char *file = config();
  int fd = open(file, O_WRONLY | O_CREAT | O_TRUNC, 0644); if (-1 == fd) {
    warn("failed to truncate %s", file);
    return;
  }
  free(file);

  WindowState ws = state(dpy, id);
  json_t *o = json_object();
  json_object_set_new(o, "id", json_integer(ws.id));
  json_object_set_new(o, "_NET_WM_STATE_SHADED", json_boolean(ws._NET_WM_STATE_SHADED));
  json_object_set_new(o, "_NET_WM_STATE_HIDDEN", json_boolean(ws._NET_WM_STATE_HIDDEN));

  char *dump = json_dumps(o, JSON_COMPACT);
  write(fd, dump, strlen(dump));
  free(dump);
  json_decref(o);

  close(fd);
}

Window state_load(Display *dpy, Window  id_current) {
  char *file = config();
  json_t *root = json_load_file(file, 0, NULL);
  free(file);
  if (!root) return 0;

  bool change_layer = true;
  Window id = json_integer_value(json_object_get(root, "id"));
  if (id == id_current) return id;

  const int _net_wm_state_add = 1;
  bool is_shaded = json_boolean_value(json_object_get(root, "_NET_WM_STATE_SHADED"));
  if (is_shaded) client_msg(dpy, id, "_NET_WM_STATE", _net_wm_state_add,
                            myAtoms._NET_WM_STATE_SHADED, 0, 0, 0);
  bool is_hidden = json_boolean_value(json_object_get(root, "_NET_WM_STATE_HIDDEN"));
  if (is_hidden) client_msg(dpy, id, "_NET_WM_STATE", _net_wm_state_add,
                            myAtoms._NET_WM_STATE_HIDDEN, 0, 0, 0);

  if (is_shaded || is_hidden) change_layer = false;
  if (change_layer) XLowerWindow(dpy, id); /* FIXME */

  json_decref(root);
  return id;
}



int main(int argc, char **argv) {
  Display *dpy = XOpenDisplay(getenv("DISPLAY"));
  if (!dpy) errx(1, "failed to open display %s", getenv("DISPLAY"));
  if (argc != 2) errx(1, "usage: activate window-id");

  mk_atoms(dpy);

  ulong id = str2id(argv[1]);
  if (!id) errx(1, "invalid window id: `%s`", argv[1]);

  Window prev_id = state_load(dpy, id);
  if (prev_id != id) state_save(dpy, id);

  XSynchronize(dpy, True); // snake oil?
  bool r = window_activate(dpy, id);
  if (!r) return 1;
  r = window_center_mouse(dpy, id);
  return !r;
}
