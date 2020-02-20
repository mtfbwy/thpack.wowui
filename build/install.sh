#!/bin/bash

if [[ "$BASH_SOURCE" == /* ]]; then
     TOP=$(realpath $(dirname $BASH_SOURCE)/..)
else
     TOP=$(realpath $(pwd)/$(dirname $BASH_SOURCE)/..)
fi

function installAddon() {
    local ADDON_ZIP=$1
    local WOW_ROOT=$2

    echo "deploying [$ADDON_ZIP] ..."

    if test ! -d "$WOW_ROOT"; then
        echo "E: invalid wow dir [$WOW_ROOT]"
        return
    fi

    # TODO extract version from file basename
    local UI_VERSION_CLASSIC=11300
    if [[ $ADDON_ZIP == *.$UI_VERSION_CLASSIC.* ]]; then
        local WOW_BRANCH="_classic_"
    else
        local WOW_BRANCH="_retail_"
    fi
    unzip -o $ADDON_ZIP -d "$WOW_ROOT/$WOW_BRANCH/Interface/AddOns" >/dev/null
}

########################################

WOW_ROOT="$HOME/app/World of Warcraft"
if test ! -d "$WOW_ROOT"; then
    echo "E: invalid wow dir [$WOW_ROOT]"
else
    for f in `\ls $TOP/out/*.zip`; do
        installAddon $f "$WOW_ROOT"
    done
fi
