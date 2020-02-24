#!/bin/bash

if [[ "$BASH_SOURCE" == /* ]]; then
    TOP=$(realpath $(dirname $BASH_SOURCE)/..)
else
    TOP=$(realpath $(pwd)/$(dirname $BASH_SOURCE)/..)
fi

function buildAddon() {
    local ADDON=$1
    local UI_VERSION=$2
    local SRC_FILES=$3

    local NON_RES_FILES=""
    for i in $SRC_FILES; do
        if [[ "$i" != res/* ]]; then
            NON_RES_FILES="$NON_RES_FILES
$i"
        fi
    done

    local DATE=$(date +%Y-%m-%d)
    local ZIP_BASENAME=$ADDON.$UI_VERSION.$DATE.zip

    echo "building [$ZIP_BASENAME] ..."

    rm -rf $TOP/out/$ADDON
    mkdir -p $TOP/out/$ADDON

    cat > $TOP/out/$ADDON/$ADDON.toc << EOF
## Interface: $UI_VERSION
## Title: $ADDON
## Date: $DATE
$NON_RES_FILES
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

buildAddon thpack.Misc $UI_VERSION_CLASSIC "
bindings.xml
res/healthbar32.tga
res/tile32.tga
res/3p/glow.tga
res/3p/norm.tga
src/cvar.lua
src/util/A.lua
src/util/A.pixelPerfect.lua
src/util/A.Res.lua
src/util/A.Frame.lua
src/util/A.Util.lua
src/misc/autoDismount.lua
src/misc/buffCaster.lua
src/misc/castBarReskin.lua
src/misc/energyTick.lua
src/misc/fastLoot.lua
src/misc/filterErrorMessage.lua
src/misc/mostExpensiveReward.lua
src/misc/performanceTip.lua
src/misc/poisonCount.lua
src/misc/reagentCount.lua
src/misc/tabSwitchChannel.lua
src/misc/targetClassIcon.lua
src/misc/tooltipItemQuality.lua
src/misc/tooltipReskin.lua
src/misc/tooltipUnitTarget.lua
"

buildAddon thpack.Backpack $UI_VERSION_CLASSIC "
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
src/lang/table.lua
src/lang/proto.lua
src/adt/Color.lua
src/util/A.lua
src/util/A.Res.lua
src/util/A.Frame.lua
src/util/A.Util.lua
src/unitframe/FlatUnitFrame.lua
src/unitframe/FlatNamePlate.lua
"

buildAddon thpack.TargetDistance $UI_VERSION_CLASSIC "
src/lang/table.lua
src/hud/yard.lua
"

buildAddon thpack.Overpower $UI_VERSION_CLASSIC "
res/tile32.tga
src/util/A.Res.lua
src/util/A.Frame.lua
src/hud/overpower.lua
"
