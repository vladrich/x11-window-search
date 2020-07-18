#!/bin/sh

id=`echo "$1" | awk -F'|' '{print $NF} END { exit $NF == "" ? 1 : 0}'` || {
    echo "usage: `basename "$0"` 'name | class | id'"
    exit 1
}
xdotool windowactivate "$id" mousemove --window "$id" 0 0
