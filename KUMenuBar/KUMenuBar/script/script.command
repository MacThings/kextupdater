#!/bin/bash
#

ScriptHome=$(echo $HOME)
kuroot=`defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "KU Root"`

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
