#!/bin/bash

if [[ "$BASH_SOURCE" == /* ]]; then
    TOP=$(realpath $(dirname $BASH_SOURCE)/..)
else
    TOP=$(realpath $(pwd)/$(dirname $BASH_SOURCE)/..)
fi

function buildChatfilter() {
    local UI_VERSION=11300
    local ADDON_NAME="thpack.Chatfilter"
    local ADDON_DATE=$(date +%Y-%m-%d)
    local ADDON_FILES="
filterChatMessage.lua
"
    local ADDON_ZIP_NAME=$ADDON_NAME.$UI_VERSION.$ADDON_DATE.zip

    echo "building [$ADDON_ZIP_NAME] ..."

    local ADDON_OUT_ROOT=$TOP/out/$ADDON_NAME

    rm -rf $ADDON_OUT_ROOT
    mkdir -p $ADDON_OUT_ROOT

    cat > $ADDON_OUT_ROOT/$ADDON_NAME.toc << EOF
## Interface: $UI_VERSION
## Title: $ADDON_NAME
## X-BuildDate: $ADDON_DATE
$ADDON_FILES
EOF

    cd $TOP/chatfilter
    cp --parents -t $ADDON_OUT_ROOT $ADDON_FILES
    cd - >/dev/null

    cd $TOP/out
    zip -r $ADDON_ZIP_NAME $ADDON_NAME >/dev/null
    cd - >/dev/null
}

buildChatfilter
