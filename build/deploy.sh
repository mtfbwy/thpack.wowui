#!/bin/bash

#echo BASH_SOURCE: $BASH_SOURCE
TOP=$(readlink -f $(dirname $BASH_SOURCE)/..)

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
    unzip -o $ADDON_ZIP -d "$WOW_ROOT/$WOW_BRANCH/Interface/AddOns" >/dev/null
}

function deployAll() {
    local WOW_ROOT=$1

    echo "deploying all ..."

    if test ! -d "$WOW_ROOT"; then
        echo "E: invalid wow dir [$WOW_ROOT]"
        return
    fi

    for br in _retail_ _classic_; do
        local WOW_ADDON_ROOT=$WOW_ROOT/$br/Interface/AddOns
        mkdir -p "$WOW_ADDON_ROOT/thpack.wowui"
        cd $TOP
        cp --parents -t "$WOW_ADDON_ROOT/thpack.wowui" \
            *.toc *.xml \
            -r src \
            -r res
        cd - >/dev/null
    done
}

########################################

WOW_ROOT="$HOME/app/World of Warcraft"

UI_VERSION_CLASSIC=11300
DATE=$(date +%Y-%m-%d)

for f in `\ls $TOP/out/*.zip`; do
    echo $f
done
#deployAddon "$WOW_ROOT" $TOP/out/$BACKPACK_ZIP

#deployAll "$WOW_ROOT"
