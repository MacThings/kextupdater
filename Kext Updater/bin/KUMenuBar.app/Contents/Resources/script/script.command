#!/bin/bash
#

ScriptHome=$(echo $HOME)
interval=`defaults read "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "UpdateInterval"`
let interval="$interval*60*60"
kuroot=`defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "KU Root"`
kuroot="/Applications"

function runcheck()
{

    runcheck=$( ps -A | grep KUMenuBar | grep bash | grep kumenubar | awk '{print $1}' )
    if [[ "$runcheck" != "" ]]; then
        kill -kill "$runcheck"
    fi

}

function updatecheck()
{

    bash "$kuroot"/Kext\ Updater.app/Contents/Resources/script/script.command kudaemo

}

function open_kextupdater()
{

   open "$kuroot"/Kext\ Updater.app

}

function quitmenu()
{

    runcheck=$( ps -A | grep KUMenuBar | grep bash | grep kumenubar | awk '{print $1}' )
    if [[ "$runcheck" != "" ]]; then
        kill -kill "$runcheck"
    fi

}

$1
