#!/bin/bash

DST="/mnt/d/app/World of Warcraft/_retail_/Interface/AddOns"

if test ! -d "$DST"; then
    echo "E: invalid wow addon dir"
    exit
fi

ADDON=thpack.wowui

DST="$DST/$ADDON"
mkdir -p "$DST"

cp thpack.wowui.toc bindings.xml -r res src "$DST"
