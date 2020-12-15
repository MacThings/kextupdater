#!/bin/bash
#

ScriptHome=$(echo $HOME)
ScriptTmpPath="$HOME"/.ku_temp
kuroot=`defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "KU Root"`
efi_root=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "EFI Root" )
download_path=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Downloadpath" )
defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "Downloadpath" "$download_path"

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

    runcheck=$( pgrep KUMenuBar )
    if [[ "$runcheck" != "" ]]; then
        kill -kill "$runcheck"
    fi
}

function updatecheck_now()
{

    notifications=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Notifications" )
    if [[ "$notifications" = "0" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Notifications" -bool YES
        waszero="yes"
    fi

    bash "$kuroot"/Kext\ Updater.app/Contents/Resources/script/script.command mainscript

    if [[ "$waszero" = "yes" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Notifications" -bool NO
    fi

}


function updatecheck()
{

    alertercheck=$( pgrep alerter )
    if [[ "$alertercheck" = "" ]]; then
        bash "$kuroot"/Kext\ Updater.app/Contents/Resources/script/script.command kudaemon &
    fi
}

function mount_bootefi()
{

    bash "$kuroot"/Kext\ Updater.app/Contents/Resources/script/script.command mountefi
    refreshtime

}

function open_kextupdater()
{

   open "$kuroot"/Kext\ Updater.app

}

function quitmenu()
{

    runcheck=$( pgrep KUMenuBar )
    if [[ "$runcheck" != "" ]]; then
        kill -kill "$runcheck"
    fi

}

function rebuild_kextcache()
{

    osascript -e 'do shell script "chmod -R 755 /System/Library/Extensions/*; sudo chown -R root:wheel /System/Library/Extensions/*; sudo touch /System/Library/Extensions; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo kextcache -u / -v 6" with administrator privileges' >/dev/null 2>&1

}

function reboot()
{

    osascript -e 'tell app "System Events" to restart'

}

function mounthelper()
{

    efi_mount=$( defaults read "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "EFIx" )
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "EFIx" "$efi_mount"
    
}

$1
