#!/bin/bash

#echo BASH_SOURCE: $BASH_SOURCE
TOP=$(readlink -f $(dirname $BASH_SOURCE)/..)

function buildAddon() {
    local ADDON=$1
    local UI_VERSION=$2
    local SRC_FILES=$3

    local DATE=$(date +%Y-%m-%d)
    local ZIP_BASENAME=$ADDON.$UI_VERSION.$DATE.zip

    echo "building [$ZIP_BASENAME] ..."

    rm -rf $TOP/out/$ADDON
    mkdir -p $TOP/out/$ADDON

    cat > $TOP/out/$ADDON/$ADDON.toc << EOF
## Interface: $UI_VERSION
## Title: $ADDON
## Date: $DATE
$SRC_FILES
EOF

    cd $TOP
    cp --parents -t $TOP/out/$ADDON $SRC_FILES
    cd - >/dev/null

    cd $TOP/out
    zip -r $ZIP_BASENAME $ADDON >/dev/null
    cd - >/dev/null
}

########################################

WOW_ROOT="$HOME/app/World of Warcraft"

UI_VERSION_CLASSIC=11300

buildAddon thpack.backpack $UI_VERSION_CLASSIC "
src/util/A.lua
src/backpack/backpack.lua
src/backpack/backpackRemaining.lua
src/backpack/autoRepair.lua
src/backpack/autoSell.lua
"

buildAddon thpack.FlatNamePlate $UI_VERSION_CLASSIC "
res/3p/highlight.tga
res/3p/glow.tga
res/3p/impact.ttf
res/healthbar32.tga
res/tile32.tga
src/util/A.Frame.lua
src/util/A.getUnitClassColorByUnit.lua
src/util/A.getUnitNameColorByUnit.lua
src/util/A.getUnitHealthColorByUnit.lua
src/util/A.getUnitCastInfoByUnit.lua
src/unitframe/FlatUnitFrame.lua
src/unitframe/FlatNamePlate.lua
"
