#!/bin/sh

id=`echo "$1" | awk -F'|' '{print $NF} END { exit $NF == "" ? 1 : 0}'` || {
    echo "usage: `basename "$0"` 'name | class | id'"
    exit 1
}

# tries to put a mouse pointer as shown on the picture below (▲ is the
# pointer):
#
# +-------------+
# |    Title    |
# +-------------+
# |      ▲      |
# |             |
# |             |
# +-------------+

eval "`xdotool getwindowgeometry --shell "$id"`"
x=$((WIDTH/2))

xdotool windowactivate "$id" mousemove --window "$id" "$x" 0
