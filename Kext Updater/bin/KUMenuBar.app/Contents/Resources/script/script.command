#!/bin/bash
#

ScriptHome=$(echo $HOME)
kuroot=`defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "KU Root"`
efi_root=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "EFI Root" )
efi_mounted_check=$( diskutil info "$efi_root" |grep Mounted |sed 's/.*://g' |xargs )

if [[ "$efi_mounted_check" = "Yes" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "Yes"
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Mounted" "Yes"
else
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "No"
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Mounted" "No"
fi

function open_menu() {

if [[ "$efi_mounted_check" = "Yes" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "Yes"
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Mounted" "Yes"
else
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "No"
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Mounted" "No"
fi

}

function refreshtime() {

    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Refreshtime" "Yes"

}

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

function mount_bootefi()
{

    bash "$kuroot"/Kext\ Updater.app/Contents/Resources/script/script.command mountefi

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
