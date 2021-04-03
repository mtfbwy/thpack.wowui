#!/bin/bash

if [[ "$BASH_SOURCE" == /* ]]; then
    TOP=$(realpath $(dirname $BASH_SOURCE)/..)
else
    TOP=$(realpath $(pwd)/$(dirname $BASH_SOURCE)/..)
fi

function buildPackage() {
    packageId=$1
    interfaceVersion=$2
    buildDate=$(date +%Y-%m-%d)
    tocFile=$TOP/$packageId.toc

    dstRoot=$TOP/out/$packageId
    rm -rf $dstRoot
    mkdir -p $dstRoot

    dstTocFile=$dstRoot/$packageId.toc
    cp $tocFile $dstTocFile
    sed "s/{Interface}/$interfaceVersion/" -i $dstTocFile
    sed "s/{BuildDate}/$buildDate/" -i $dstTocFile

    while read line; do
        if [[ "$line" =~ ^[^#]+ ]]; then
            cd ..
            cp --parents -t $dstRoot $line
            cd - >/dev/null
        fi
    done < $dstTocFile

    dstZipFile=$dstRoot/../$packageId.$interfaceVersion.$buildDate.zip
    cd $dstRoot/..
    zip -r $dstZipFile $packageId >/dev/null
    cd - >/dev/null
}

function installPackage() {
    local zipFile=$1
    local wowRoot=$2

    echo "deploying [$zipFile] ..."

    if test ! -d "$wowRoot"; then
        echo "E: invalid wow dir [$wowRoot]"
        return
    fi

    local INTERFACE_VERSION_CLASSIC=11300
    if [[ $zipFile == *.$INTERFACE_VERSION_CLASSIC.* ]]; then
        local wowBranch="_classic_"
    else
        local wowBranch="_retail_"
    fi
    unzip -o $zipFile -d "$wowRoot/$wowBranch/Interface/AddOns" >/dev/null
}

########################################

if [[ "$1" == "release" ]]; then
    wowRoot="$HOME/app/World of Warcraft"
    for f in `\ls $TOP/out/*.zip`; do
        installPackage $f "$wowRoot"
    done
else
    buildPackage thpack.scoreboard 11300
fi
