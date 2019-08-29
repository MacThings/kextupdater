#!/bin/bash
#

ScriptHome=$(echo $HOME)
kuroot=`defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "KU Root"`
processid=$( pgrep KUMenuBar )
defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "PID" "$processid"


function runcheck()
{

    runcheck=$( ps -A | grep KUMenuBar | grep bash | grep kumenubar | awk '{print $1}' )
    if [[ "$runcheck" != "" ]]; then
        kill -kill "$runcheck"
    fi

}

function updatecheck()
{

    alertercheck=$( ps -A | grep alerter | grep appicon | awk '{print $1}' )
    if [[ "$alertercheck" = "" ]]; then
        bash "$kuroot"/Kext\ Updater.app/Contents/Resources/script/script.command kudaemon &
    fi
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
