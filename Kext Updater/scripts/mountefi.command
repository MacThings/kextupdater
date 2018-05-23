#!/bin/bash

MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

efiroot=`./BDMESG |grep SelfDevicePath | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g"`
if [[ $efiroot = "" ]];then
efiroot=`./BDMESG |grep "Found Storage" | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g"`
fi

if [ -d /Volumes/EFI ]; then
diskutil unmount $efiroot
else
diskutil mount $efiroot
fi
exit 0
