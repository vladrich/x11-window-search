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

  long r = -1;
  if (prop_val) r = ((long*)prop_val)[0];
  free(prop_val);
  return r;
}
