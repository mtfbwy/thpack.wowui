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
## X-BuildDate: $DATE
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

buildAddon thpack.wowui $UI_VERSION_CLASSIC "
res/healthbar32.tga
res/tile32.tga
res/3p/glow.tga
res/3p/norm.tga

src/util/Proto.lua
src/util/Color.lua
src/util/Seg.lua
src/util/SpellBook.lua
src/util/A.lua
src/util/A.Util.lua
src/util/A.px.lua

src/misc/autoDismount.lua
src/misc/autoRepair.lua
src/misc/autoSell.lua
src/misc/backpack.lua
src/misc/backpackRemaining.lua
src/misc/buffCaster.lua
src/misc/buffCountdown.lua
src/misc/buffPoisonCount.lua
src/misc/castBarReskin.lua
src/misc/fastLoot.lua
src/misc/filterErrorMessage.lua
src/misc/mostExpensiveReward.lua
src/misc/performanceTip.lua
src/misc/reagentCount.lua
src/misc/stat.lua
src/misc/tabSwitchChatChannel.lua
src/misc/tooltipItemQuality.lua
src/misc/tooltipReskin.lua
src/misc/tooltipUnitTarget.lua

src/triggerwatch/TriggerWatch.lua
src/triggerwatch/tactic-warrior.lua

src/unitframe/ep2.lua
src/unitframe/targetClassIcon.lua
src/unitframe/targetRange.lua
"

buildAddon thpack.preference $UI_VERSION_CLASSIC "
src/preference/cvar.lua
"

buildAddon thpack.FlatNamePlate $UI_VERSION_CLASSIC "
res/3p/highlight.tga
res/3p/glow.tga
res/3p/impact.ttf
res/healthbar32.tga
res/tile32.tga
src/util/Proto.lua
src/util/Color.lua
src/util/A.lua
src/util/A.Util.lua
src/nameplate/FlatUnitFrame.lua
src/nameplate/FlatNamePlate.lua
"
