#!/bin/bash

MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

if [ -f $ScriptHome/Library/Preferences/kextupdater.cfg ]; then
echo $lastcheck
cat $ScriptHome/Library/Preferences/kextupdater.cfg
date '+%A %e %B %Y, %H:%M' > $ScriptHome/Library/Preferences/kextupdater.cfg
else
date '+%A %e %B %Y, %H:%M' > $ScriptHome/Library/Preferences/kextupdater.cfg
fi
