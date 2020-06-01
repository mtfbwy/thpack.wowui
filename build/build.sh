#!/bin/bash

if [[ "$BASH_SOURCE" == /* ]]; then
    TOP=$(realpath $(dirname $BASH_SOURCE)/..)
else
    TOP=$(realpath $(pwd)/$(dirname $BASH_SOURCE)/..)
fi

function buildAddon() {
    local ADDON=$1
    local UI_VERSION=$2
    local INPUT_FILES=$3
    local ADDON_ROOT=$TOP/out/$ADDON

    local TO_COPY_FILES=""
    local IN_TOC_FILES=""
    for i in $INPUT_FILES; do
        if [[ "$i" == \#* ]]; then
            local j=${i#"#"}
            TO_COPY_FILES="$TO_COPY_FILES $j"
        else
            TO_COPY_FILES="$TO_COPY_FILES $i"
        fi
        if [[ "$i" != res/* ]]; then
            IN_TOC_FILES="$IN_TOC_FILES
$i"
        fi
    done

    local DATE=$(date +%Y-%m-%d)
    local ZIP_BASENAME=$ADDON.$UI_VERSION.$DATE.zip

    echo "building [$ZIP_BASENAME] ..."

    rm -rf $ADDON_ROOT
    mkdir -p $ADDON_ROOT

    cat > $ADDON_ROOT/$ADDON.toc << EOF
## Interface: $UI_VERSION
## Title: $ADDON
## X-BuildDate: $DATE
$IN_TOC_FILES
EOF

    cd $TOP
    cp --parents -t $ADDON_ROOT $TO_COPY_FILES
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
src/misc/ep2.lua
src/misc/fastLoot.lua
src/misc/filterErrorMessage.lua
src/misc/mostExpensiveReward.lua
src/misc/performanceTip.lua
src/misc/reagentCount.lua
src/misc/stat.lua
src/misc/tabSwitchChatChannel.lua
src/misc/targetClassIcon.lua
src/misc/targetRange.lua
src/misc/tooltipItemQuality.lua
src/misc/tooltipReskin.lua
src/misc/tooltipUnitTarget.lua

src/triggerwatch/CellCtrl.lua
src/triggerwatch/TriggerWatch.lua
src/triggerwatch/fury.lua

src/wtf/cvar.lua
#src/wtf/hotKey.lua
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
src/unitframe/FlatUnitFrame.lua
src/unitframe/FlatNamePlate.lua
"
