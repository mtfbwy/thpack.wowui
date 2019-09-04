#!/bin/bash

WOW="/mnt/d/app/World of Warcraft"
if test ! -d "$WOW"; then
    echo "E: invalid wow dir"
    exit
fi

ADDON="$WOW/_retail_/Interface/AddOns/thpack.wowui"
rm -rf "$ADDON"
mkdir -p "$ADDON"
cp *.toc *.xml -r res src "$ADDON"

ADDON="$WOW/_classic_/Interface/AddOns/thpack.classic"
rm -rf "$ADDON"
mkdir -p "$ADDON"
cp *.toc *.xml -r res src "$ADDON"
