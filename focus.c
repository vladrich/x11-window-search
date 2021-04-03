#include <stdlib.h>
#include <err.h>
#include <stdio.h>
#include <stdbool.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>

ulong str2id(const char *s) {
    ulong id;
    if (sscanf(s, "0x%lx", &id) != 1 &&
        sscanf(s, "0X%lx", &id) != 1 &&
        sscanf(s, "%lu", &id) != 1) return 0;
    return id;
}

ulong prop_desktop(Display *dpy, ulong id) {
  Atom type;
  int format;
  ulong nitems, bytes_after;
  u_char *prop;

  Atom atom = XInternAtom(dpy, "_NET_WM_DESKTOP", False);
  int r = XGetWindowProperty(dpy, id, atom, 0L, sizeof(Atom), False,
                             XA_CARDINAL, &type, &format,
                             &nitems, &bytes_after, &prop);
  if ( !(r == Success && prop)) return -1;
  ulong val = ((ulong*)prop)[0];
  XFree(prop);
  return val;
}

bool client_msg(Display *dpy, Window id, char *msg,
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
  ulong desktop = prop_desktop(dpy, id);
  if (-1 != desktop) {
    client_msg(dpy, DefaultRootWindow(dpy), "_NET_CURRENT_DESKTOP",
               desktop, 0, 0, 0, 0);
  } else
    warnx("cannot switch desktop");

  bool r = client_msg(dpy, id, "_NET_ACTIVE_WINDOW", 0, 0, 0, 0, 0);
  XMapRaised(dpy, id);
  return r;
}

bool window_center_mouse(Display *dpy, ulong id) {
  XWindowAttributes attrs;
  if (!XGetWindowAttributes(dpy, id, &attrs)) return false;
  if (!XWarpPointer(dpy, 0, id, 0, 0, 0, 0, attrs.width/2, attrs.height/2))
    return false;
  XFlush(dpy);
  return true;
}

int main(int argc, char **argv) {
  Display *dpy = XOpenDisplay(getenv("DISPLAY"));
  if (!dpy) errx(1, "failed to open display %s", getenv("DISPLAY"));
  if (argc != 2) errx(1, "usage: focus window-id");

  ulong id = str2id(argv[1]);
  if (!id) errx(1, "invalid window id: `%s`", argv[1]);

  bool r = window_activate(dpy, id);
  if (!r) return 1;
  r = window_center_mouse(dpy, id);
  return !r;
}
