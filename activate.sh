#!/bin/sh

id=`echo "$1" | awk -F'|' '{print $NF} END { exit $NF == "" ? 1 : 0}'` || {
    echo "usage: `basename "$0"` 'foo | bar | id'"
    exit 1
}

__filename=`readlink -f "$0"`
__dirname=`dirname "${__filename}"`

# shellcheck disable=2086
${__dirname}/_out/activate $id
