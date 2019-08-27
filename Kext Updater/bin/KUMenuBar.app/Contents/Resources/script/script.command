#!/bin/bash
#

ScriptHome=$(echo $HOME)
intervall=`defaults read "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "UpdateIntervall"`

function runcheck()
{

    runcheck=$( ps -A | grep KUMenuBar | grep bash | grep kumenubar | awk '{print $1}' )
    if [[ "$runcheck" != "" ]]; then
        kill -kill "$runcheck"
    fi

}


function kumenubar()
{
    kuroot=`defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "KU Root"`
    kuroot="/Applications"

    if [[ $? = "1" ]]; then
        intervall="240"
    fi

    while true
    do
        bash "$kuroot"/Kext\ Updater.app/Contents/Resources/script/script.command kudaemon
        sleep "$intervall"
    done
}

function quitmenu()
{

    runcheck=$( ps -A | grep KUMenuBar | grep bash | grep kumenubar | awk '{print $1}' )
    if [[ "$runcheck" != "" ]]; then
        kill -kill "$runcheck"
    fi

}

$1
