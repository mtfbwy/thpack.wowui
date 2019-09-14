#!/bin/bash

WOW="/mnt/d/app/World of Warcraft"
if test ! -d "$WOW"; then
    echo "E: invalid wow dir"
    exit
fi

for i in "_retail_" "_classic_"; do
    ADDON="$WOW/$i/Interface/AddOns/thpack.wowui"
    rm -rf "$ADDON"
    mkdir -p "$ADDON"
    cp *.toc *.xml -r res src "$ADDON"
done
