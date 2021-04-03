#!/bin/sh

id=`echo "$1" | awk -F'|' '{print $NF} END { exit $NF == "" ? 1 : 0}'` || {
    echo "usage: `basename "$0"` 'foo | bar | id'"
    exit 1
}

_out/focus $id
