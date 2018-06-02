#!/bin/bash

MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

if [ ! -f /tmp/choice.tmp ]; then
echo "Updates" > /tmp/choice.tmp
fi

if [ -f /tmp/kextstats ]; then
rm /tmp/kextstats
fi

#========================= Script Version Info =========================#
ScriptVersion=2.0.6

#========================= Script Pathes =========================#
ScriptHome=$(echo $HOME)
ScriptDownloadPath="${ScriptHome}/Desktop/Kext-Updates"
ScriptTmpPath="/tmp"

#========================== Set Variables =========================#
url="kextupdater.slsoft.de"
myyear=`date +'%Y'`
lan2=`defaults read -g AppleLocale`
username="$(stat -f%Su /dev/console)"
realname="$(dscl . -read /Users/$username RealName | cut -d: -f2 | sed -e 's/^[ \t]*//' | grep -v "^$")"
osuser=`echo $realname`
hour=`date "+%H"`
efiroot=`./BDMESG |grep SelfDevicePath | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g"`
if [[ $efiroot = "" ]];then
efiroot=`./BDMESG |grep "Found Storage" | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g"`
fi
kexte=`cat /tmp/choice.tmp`

if [[ $lan2 = "de_DE" ]]; then
language="de"
elif [[ $lan2 = "tr_TR" ]]; then
language="tr"
elif [[ $lan2 = "ru_RU" ]]; then
language="ru"
elif [[ $lan2 = "uk_UK" ]]; then
language="uk"
elif [[ $lan2 = "es_ES" ]]; then
language="es"
else
language="en"
fi

cat $language.lproj/MainMenu.strings | sed -e '/BASH/,$!d' -e "s/\;//g" | tail -n +$((x+2)) > /tmp/locales.tmp
source /tmp/locales.tmp

#========================= Check Internet Connection =========================#
ping -c 1 $url >> /dev/null 2>&1
if [[ $? = 0 ]]; then
curl -sS -o ${ScriptTmpPath}/overview.html https://$url/overview.html
else
echo " "
echo $checkinet
sleep 5
killall Kext\ Updater
fi

#========================= Check APFS =========================#
apfscheck=`./BDMESG |grep "APFS driver"` # Checks if apfs.efi is used
if [[ $apfscheck != "" ]]; then
  if [ ! -d /Volumes/EFI ]; then
  efi="off"
  diskutil mount $efiroot >/dev/null 2>&1
    if [ -f /Volumes/EFI/.Trashes/501/apfs.efi ]; then # Deletes apfs.efi from Trashcan if its there
    rm /Volumes/EFI/.Trashes/501/apfs.efi
    fi
  fi
  if [ -d /Volumes/EFI ]; then
  apfspath=`find /Volumes/EFI/ -name "apfs.efi"`
    if [[ $apfspath = *apfs.efi* ]]; then # Check if apfs.efi is in place
    apfs=`cat "$apfspath" |xxd | grep -A 2 APFS | head -n 2 | tail -n 1 | sed -e "s/.*\ \ //g" -e "s/\.\.\..*//g" -e "s/\///g"`
    fi  
fi
  if [[ $efi = "off" ]]; then #If the EFI wasn´t mounted before executing the Kext Updater it will be unmounted "politely"
  diskutil umount $efiroot >/dev/null 2>&1
  fi
fi

#========================= Get loaded Kexts =========================#
kextstat >> ${ScriptTmpPath}/kextstats

#========================= Check for nVidia Webdriver =========================#
checkweb=`cat $ScriptTmpPath/kextstats |grep web.GeForceWeb`
if [[ $checkweb != "" ]]; then
locweb=`cat /Library/Extensions/NVDAStartupWeb.kext/Contents/Info.plist |grep NVDAStartupWeb\ | sed -e "s/.*Web\ //g" -e "s/<\/.*//g" |cut -c 10-99`
echo NVDAStartupWeb "($locweb)" >> ${ScriptTmpPath}/kextstats
fi

#========================= Add Non-Kext Values =========================#
./BDMESG |grep "Clover revision" |sed -e "s/.*revision:\ /Clover\ (/g" -e "s/\ on.*/)/g" >> ${ScriptTmpPath}/kextstats
sed -ib "s/IntelMausiEthernet\ (2.3.0d0)/IntelMausiEthernet\ (2.3.0)/g" ${ScriptTmpPath}/kextstats
rm ${ScriptTmpPath}/kextstatsb
echo "APFS ($apfs)" >> $ScriptTmpPath/kextstats

#========================= Kext Array =========================#
## Script Name,kextstat Name, echo Name, Ersatz Name
#
kextArray=(
  "acpibatterymanager","org.rehabman.driver.AppleSmartBatteryManager","ACPI BatteryManager",""
  "airportbrcmfixup","BrcmWLFixup","BrcmWLFixup","AirportBrcmFixup"
  "airportbrcmfixup","AirportBrcmFixup","AirportBrcmFixup",""
  "apfs","APFS","APFS",""
  "applealc","ALC","AppleALC",""
  "ath9kfixup","ATH9KFixup","ATH9KFixup",""
  "atherose2200ethernet","AtherosE2200","AtherosE2200Ethernet",""
  "azulpatcher4600","AzulPatcher4600","AzulPatcher4600",""
  "bt4lecontiunityfixup","BT4LEContiunityFixup","BT4LEContiunityFixup",""
  "clover","Clover","Clover Bootloader",""
  "codeccommander","CodecCommander","CodecCommander",""
  "coredisplayfixup","CoreDisplayFixup","CoreDisplayFixup",""
  "cpufriend","CPUFriend","CPUFriend",""
  "enablelidwake","EnableLidWake","EnableLidWake",""
  "fakepciid","FakePCIID","FakePCIID",""
  "fakesmc","FakeSMC","FakeSMC",""
  "hibernationfixup","HibernationFixup","HibernationFixup",""
  "intelgraphicsdvmtfixup","IntelGraphicsDVMTFixup","IntelGraphicsDVMTFixup",""
  "intelgraphicsfixup","IntelGraphicsFixup","IntelGraphicsFixup",""
  "notouchid","NoTouchID","NoTouchID",""
  "intelmausiethernet","IntelMausi","IntelMausiEthernet",""
  "lilu","Lilu ","Lilu",""
  "lilufriend","LiluFriend","LiluFriend",""
  "nightshiftunlocker","NightShiftUnlocker","NightShiftUnlocker",""
  "nvidiagraphicsfixup","NvidiaGraphicsFixup","NvidiaGraphicsFixup",""
  "realtekrtl8111","RealtekRTL8111","RealtekRTL8111",""
  "shiki","Shiki","Shiki",""
  "usbinjectall","USBInjectAll","USBInjectAll",""
  "voodoohda","VoodooHDA","VoodooHDA",""
  "voodooi2c","VoodooI2C (","VoodooI2C",""
  "whatevergreen","WhateverGreen","WhateverGreen",""
  "intelmausiethernet","AppleIntelE1000","AppleIntelE1000","IntelMausiEthernet"
  "nvidiagraphicsfixup","LibValFix","NVWebDriverLibValFix","NvidiaGraphicsFixup"
  "voodoops2","PS2Controller","VoodooPS2",""
)

#========================= Ozmosis Warning =========================#
function _ozmosis()
{
./BDMESG | grep "Ozmosis" > /dev/null
if [[ $? = "0" ]]; then
  echo $ozmosis
echo " "
fi
}

#========================= Output Headline =========================#
function _printHeader()
{
#echo "==========================================================="
#echo "                   K E X T   U P D A T E R                 "
#echo "==========================================================="
#echo " "
  if [ $hour -lt 12 ]; then
		echo $greet1
  elif [ $hour -lt 18 ]; then
        echo $greet2
  else
        echo $greet3
  fi
  echo " "
sleep 0.2
}

#========================= Kext Updater Version Check =========================#
function _kucheck ()
{
sleep 0.5
if [[ $kexte == *Updates* ]]; then
name="kextupdater"
lecho=`cat script.command |grep ScriptVersion | head -n1 | sed -e "s/.*\=//g"`
local=`echo $lecho | sed -e "s/\.//g"`
echo $upd
remote=`cat $ScriptTmpPath/overview.html |grep kextupdater |sed -e "s/.*-//g" -e "s/+.*//g" -e "s/\.//g"`
recho=`cat $ScriptTmpPath/overview.html |grep kextupdater |sed "s/.*+//g"`

if [ -f ~/Desktop/Kext-Updates/$name/.version.htm ]; then
dupe=`cat ~/Desktop/Kext-Updates/$name/.version.htm`
    if [[ $dupe = $remote ]]; then
      echo $latest
    echo "-----------------------------------------------------"
    fi
else
    if [[ $local < $remote ]]; then
    mkdir -p ~/Desktop/Kext-Updates ~/Desktop/Kext-Updates/
    echo "$upd1"
    echo "$upd2" "$lecho"
    echo "$upd3" "$recho"
    curl -sS -o $ScriptTmpPath/$name.zip https://$url/$name/$name.zip
    unzip -o $ScriptTmpPath/$name.zip -d ~/Desktop/Latest\ Kext\ Updater > /dev/null
    ln -sf /Applications ~/Desktop/Latest\ Kext\ Updater/Applications
    if [ -d ~/Desktop/Latest\ Kext\ Updater/__MACOSX ]; then
    rm -rf ~/Desktop/Latest\ Kext\ Updater/__MACOSX
    fi
    echo " "
    sleep 0.5
    echo $latest2
    _tmpcleanup
    sleep 6
    open ~/Desktop/Latest\ Kext\ Updater/
    killall "Kext Updater"
    exit
    else
    echo $upd4 "("$lecho")"
    echo "-----------------------------------------------------"
    fi
fi

fi
}

#========================= Output Footer =========================#
function _printFooter()
{
  echo " "
#echo "==========================================================="
#echo $footer
  echo "==========================================================="
  echo " "
  exit 0
}

#========================= KextUpdate =========================#
function _kextUpdate()
{
for kextList in "${kextArray[@]}"
  do
    sleep = 0.5
    IFS=","
    data=($kextList)
    name=${data[0]}
    lecho=`cat ${ScriptTmpPath}/kextstats |grep ${data[1]} | sed -e "s/.*(//g" -e "s/).*//g"`
    local=`echo $lecho | sed -e "s/\.//g"`
    if ! [[ $local = "" ]]; then
       echo "$checkver ${data[2]} ..."
     if ! [[ -z ${data[3]} ]] ; then # veralteter Kext
     _obsoleteKext
     fi
     remote=`cat ${ScriptTmpPath}/overview.html |grep -w $name |sed -e "s/.*-//g" -e "s/+.*//g"`
     recho=`cat ${ScriptTmpPath}/overview.html |grep -w $name |sed "s/.*+//g"`
     if [ -f ${ScriptDownloadPath}/${name}/.version.htm ]; then
     dupe=`cat ${ScriptDownloadPath}/${name}/.version.htm`
       if [[ $dupe = $remote ]]; then
    sleep 0.2
        _dupeKext
        fi
     else
        returnVALUE=$(expr $local '<' $remote)
		if [[ $returnVALUE == "1" ]]; then
          mkdir -p ${ScriptDownloadPath} ${ScriptDownloadPath}/${name}
          _toUpdate
          curl -sS -o ${ScriptTmpPath}/${name}.zip https://$url/${name}/${name}.zip
          curl -sS -o ${ScriptDownloadPath}/$name/.version.htm https://$url/${name}/version.htm
          unzip -o -q ${ScriptTmpPath}/${name}.zip -d ${ScriptDownloadPath}/${name}
          rm ${ScriptTmpPath}/${name}.zip 2> /dev/null
        else
        sleep 0.3
        _noUpdate
        fi
      fi
    fi
	done
}

#============================== KextLoad ==============================#
function _kextLoader()
{
for kextLoadList in "${kextLoadArray[@]}"
  do
    IFS=","
    data=($kextLoadList)
    name=${data[0]}
if [ ${name} = "*Clover*" ] | [ -f /tmp/nightly.tmp ]; then
name="clovernightly"
fi
mkdir -p ${ScriptDownloadPath} ${ScriptDownloadPath}/${name}
_toUpdateLoad
curl -sS -o ${ScriptTmpPath}/${name}.zip https://$url/${name}/${name}.zip
curl -sS -o ${ScriptDownloadPath}/$name/.version.htm https://$url/${name}/version.htm
unzip -o -q ${ScriptTmpPath}/${name}.zip -d ${ScriptDownloadPath}/${name}
rm ${ScriptTmpPath}/${name}.zip 2> /dev/null
done
}

#========================= Helpfunction Update =========================
function _toUpdate()
{
  _PRINT_MSG "$upd1\n
  $upd2 = $lecho
  $upd3 = $recho\n\n
  $loading\n-----------------------------------------------------\n"
}

function _toUpdateLoad()
{
_PRINT_MSG "$name $dloading -----------------------------------------------------"
}

#========================= Helpfunction no Duplicates =========================#
function _dupeKext()
{
  _PRINT_MSG "$dupekext\n-----------------------------------------------------"
}

#========================= Helpfunction no Kext =========================#
function _noUpdate()
{
  _PRINT_MSG "$upd4 (Version $lecho)\n-----------------------------------------------------"
}

#========================= Helpfunction obsolete Kext =========================#
function _obsoleteKext()
{
  _PRINT_MSG "$obsolete\n"
}
#========================= Helpfunction Message =========================#
function _PRINT_MSG()
{
  local message=$1
  printf "${message}\n"
}

#============================== Webdriver ==============================#
function _nvwebdriver()
{
build=`sw_vers | grep Build |sed "s/.*\://g" |xargs`
mkdir -p "$ScriptDownloadPath/nVidia Webdriver"
webdr2=`cat /tmp/webdriver.tmp |sed "s/.*-\ //g"`
echo Build $webdr2 $webdrload
curl -sS -o "${ScriptHome}/Desktop/Kext-Updates/nVidia Webdriver/$webdr2.pkg" https://$url/nvwebdriver/$webdr2.pkg
sleep 1
echo " "
echo $fertig
_tmpcleanup
exit 0
}

#============================== Cleanup Files ==============================#
function _cleanup()
{
find $ScriptDownloadPath/ -name *.dSYM -exec rm -r {} \; >/dev/null 2>&1
}

#============================== Kext Updater Last Run ==============================#
function _lastcheck()
{
if [ -f $ScriptHome/Library/Preferences/kextupdater.cfg ]; then
echo $lastcheck
cat $ScriptHome/Library/Preferences/kextupdater.cfg
date '+%A %e %B %Y, %H:%M' > $ScriptHome/Library/Preferences/kextupdater.cfg
else
date '+%A %e %B %Y, %H:%M' > $ScriptHome/Library/Preferences/kextupdater.cfg
fi
echo " "
}

#============================== Main Function ==============================#
function _main()
{
if [[ $1 == kextUpdate ]]; then
    _printHeader
    _lastcheck
fi
sleep 0.5
_kucheck
if [[ $1 == kextUpdate ]]; then
    sleep 0.5
    _kextUpdate
elif [[ $1 == kextLoader ]]; then
    sleep 0.5
    _kextLoader
fi
_ozmosis
_cleanup
#_printFooter
}

if [[ $kexte == *Updates* ]]; then
  _main "kextUpdate"
  exit 0
fi
if [[ $kexte == *Grund* ]] || [[ $kexte == *Basic* ]]; then
  kextLoadArray=("fakesmc" "usbinjectall" "voodoops2")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
fi
if [[ $kexte == *Audio* ]]; then
  kextLoadArray=("applealc" "lilu" "codeccommander")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
fi
if [[ $kexte == *APFS* ]]; then
  kextLoadArray=("apfs")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
fi
if [[ $kexte == *Intel* ]]; then
  kextLoadArray=("intelgraphicsfixup" "lilu")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
  fi
if [[ $kexte == *nVidia* ]]; then
  kextLoadArray=("lilu" "nvidiagraphicsfixup")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
  fi
if [[ $kexte == *AMD* ]]; then
  kextLoadArray=("lilu" "whatevergreen")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
fi
if [[ $kexte == *Ethernet* ]]; then
  kextLoadArray=("atherose2200ethernet" "intelmausiethernet" "realtekrtl8111")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
fi
if [[ $kexte == *Clover* ]]; then
  kextLoadArray=("clover")
  recho="Kexte"
  _main "kextLoader"
  echo $fertig
  exit 0
fi
if [[ $kexte == *Webdriver* ]]; then
  _nvwebdriver
  exit 0
fi

#=========================== START ===========================#
_main "kextUpdate"
exit 0
#=============================================================#







