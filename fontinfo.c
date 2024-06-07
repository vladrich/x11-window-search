// Prints a triptych of 'screenWidth charWidth userTextWidth' to stdout.

#include <stdbool.h>
#include <err.h>
#include <X11/Xft/Xft.h>
#include "lib.c"

long desktop_width(Display *dpy) {
  u_char *prop_val = NULL;
  ulong prop_size;
  if (!prop(dpy, DefaultRootWindow(dpy), XA_CARDINAL, "_NET_DESKTOP_GEOMETRY", &prop_val, &prop_size))
    return -1;

  long r = ((long*)prop_val)[0];
  free(prop_val);
  return r;
}

int main(int argc, char **argv) {
  Display *dpy = XOpenDisplay(getenv("DISPLAY"));
  if (!dpy) errx(1, "failed to open display %s", getenv("DISPLAY"));
  if (argc != 3) errx(1, "usage: fontinfo font text-string");

  XftFont *font = XftFontOpenName(dpy, DefaultScreen(dpy), argv[1]);
  if (!font) errx(1, "no font match");

  XGlyphInfo info_text, info_char;
  XftTextExtentsUtf8(dpy, font, (FcChar8*)"@", 1, &info_char);
  XftTextExtentsUtf8(dpy, font, (FcChar8*)argv[2], strlen(argv[2]), &info_text);

  printf("%ld %d %d\n", desktop_width(dpy), info_char.width, info_text.width);
}
