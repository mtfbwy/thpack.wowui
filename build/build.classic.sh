#!/bin/bash

ADDONS="/mnt/d/app/World of Warcraft/_classic_/Interface/AddOns"

if test ! -d "$ADDONS"; then
    echo "E: invalid wow addon dir"
    exit
fi

SELF="thpack.classic"
DST="$ADDONS/$SELF";

rm -rf "$DST"
mkdir -p "$DST"

cp $SELF.toc bindings.xml -r res src "$DST"
