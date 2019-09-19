#!/bin/bash

#echo BASH_SOURCE: $BASH_SOURCE
TOP=$(readlink -f $(dirname $BASH_SOURCE)/..)

function buildAddon() {
    local UI_VERSION=$1
    local DATE=$2
    local ADDON_NAME=$3
    local ADDON_FILES=$4
    local ADDON_ZIP=$5

    echo "building [$ADDON_ZIP] ..."

    rm -rf $TOP/out/$ADDON_NAME
    mkdir -p $TOP/out/$ADDON_NAME

    cat > $TOP/out/$ADDON_NAME/$ADDON_NAME.toc << EOF
## Interface: $UI_VERSION
## Title: $ADDON_NAME
## Date: $DATE
$ADDON_FILES
EOF

    cd $TOP
    cp --parents -t $TOP/out/$ADDON_NAME $ADDON_FILES
    cd - >/dev/null

    cd $TOP/out
    zip -r $ADDON_ZIP $ADDON_NAME >/dev/null
    cd - >/dev/null
}

function deployAddon() {
    local WOW_ROOT=$1
    local ADDON_ZIP=$2

    echo "deploying [$ADDON_ZIP] ..."

    if test ! -d "$WOW_ROOT"; then
        echo "E: invalid wow dir [$WOW_ROOT]"
        return
    fi

    if [[ $ADDON_ZIP == *.$UI_VERSION_CLASSIC.* ]]; then
        WOW_BRANCH=_classic_
    else
        WOW_BRANCH=_retail_
    fi
    unzip -o $TOP/out/$ADDON_ZIP -d "$WOW_ROOT/$WOW_BRANCH/Interface/AddOns" >/dev/null
}

function deployAll() {
    local WOW_ROOT=$1

    echo "deploying all ..."

    if test ! -d "$WOW_ROOT"; then
        echo "E: invalid wow dir [$WOW_ROOT]"
        return
    fi

    for i in _retail_ _classic_; do
        local WOW_ADDON_ROOT=$WOW_ROOT/$i/Interface/AddOns
        mkdir -p "$WOW_ADDON_ROOT/thpack.wowui"
        cd $TOP
        cp --parents -t "$WOW_ADDON_ROOT/thpack.wowui" \
            *.toc *.xml \
            -r src \
            -r res
        cd - >/dev/null
    done
}

WOW_ROOT="/mnt/d/app/World of Warcraft"

UI_VERSION_CLASSIC=11302
DATE=$(date +%Y-%m-%d)

BACKPACK=thpack.backpack
BACKPACK_FILES="
src/A.lua
src/tweak/backpack.lua
src/tweak/backpackRemaining.lua
src/tweak/autoRepair.lua
src/tweak/autoSell.lua
"
BACKPACK_ZIP=$BACKPACK.$UI_VERSION_CLASSIC.$DATE.zip

buildAddon $UI_VERSION_CLASSIC $DATE \
    $BACKPACK "$BACKPACK_FILES" $BACKPACK_ZIP
#deployAddon "$WOW_ROOT" $BACKPACK_ZIP

deployAll "$WOW_ROOT"
