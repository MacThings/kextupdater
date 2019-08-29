#!/bin/bash
#

ScriptHome=$(echo $HOME)
kuroot=`defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "KU Root"`
efi_mounted_check=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Mounted" )
efi_path=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "EFI Path" )
defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "EFI Path" "$efi_path"

if [[ "$efi_mounted_check" = "Yes" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "Yes"
else
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "No"
fi

function open_menu() {

if [[ "$efi_mounted_check" = "Yes" ]]; then
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "Yes"
else
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Mounted" "No"
fi

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
