#!/bin/bash
#

function _helpDefaultRead()
{
    VAL=$1

    if [ ! -z "$VAL" ]; then
    defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "$VAL"
    fi
}

ScriptHome=$(echo $HOME)
ScriptTmpPath="$HOME"/.ku_temp
ScriptTmpPath2="$HOME"/.mu_temp
MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"
if [ ! -d "$ScriptTmpPath" ]; then
    mkdir "$ScriptTmpPath"
fi
OS=$( _helpDefaultRead "OSVersion" | cut -c 1-2 )

checkchime=$( _helpDefaultRead "Chime" )


################################################################
####################### Helper Function ########################
################################################################

function _helpDefaultWrite()
{
    VAL=$1
    local VAL1=$2

    if [ ! -z "$VAL" ] || [ ! -z "$VAL1" ]; then
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "$VAL" "$VAL1"
    fi
}

function _helpDefaultDelete()
{
    VAL=$1

    if [ ! -z "$VAL" ]; then
    defaults delete "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "$VAL"
    fi
}

function _playchime()
{
    speakervolume=$( _helpDefaultRead "Speakervolume" | sed "s/\,.*//g" )
    speakervolume=$( echo 0."$speakervolume" )
    afplay -v "$speakervolume" ../sounds/done.mp3 &
}

function _playchimedeath()
{
    speakervolume=$( _helpDefaultRead "Speakervolume" | sed "s/\,.*//g" )
    speakervolume=$( echo 0."$speakervolume" )
    afplay -v "$speakervolume" ../sounds/quadradeath.mp3 &
}

function _checkpass() {

    user=$( _helpDefaultRead "Rootuser" )
    passw=$( security find-generic-password -a "Kext Updater" -w | sed "s/\"/\\\\\"/g")

    osascript -e 'do shell script "dscl /Local/Default -u '$user'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1

    if [ $? != 0 ]; then
      _helpDefaultWrite "Passwordok" "No"
    else
      _helpDefaultWrite "Passwordok" "Yes"
    fi
}

function _checkpass_initial() {

    user=$( _helpDefaultRead "Rootuser" )
    passw=$( security find-generic-password -a "Kext Updater" -w | sed "s/\"/\\\\\"/g" )

    osascript -e 'do shell script "dscl /Local/Default -u '$user'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1

    if [ $? != 0 ]; then
      defaults delete "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Keychain"
    fi
}

function _getsecret() {
    secret=$(security find-generic-password -a "Kext Updater" -w)
    if [[ $secret = "44" ]]; then
        _helpDefaultWrite "Passwordok" "No"
    else
        passw="$secret"
    fi
}

### kextadd ###
allkextsupper="ACPIBatteryManager AMFIPass AirportBrcmFixup AirportItlwm AppleALC AppleBacklightFixup AsusSMC ATH9KFixup AtherosE2200Ethernet AtherosWiFiInjector AzulPatcher4600 BigSurface BrcmPatchRam BrightnessKeys BT4LEContinuityFixup Clover CodecCommander CoreDisplayFixup CPUFriend CpuTscSync CryptexFixup ECEnabler EFI-Driver EnableLidWake FakePCIID FakeSMC FeatureUnlock GenericUSBXHCI HibernationFixup HoRNDIS IntelBluetootFirmware IntelGraphicsFixup IntelGraphicsDVMTFixup IntelMausi IntelMausiWOL IntelMausiEthernet itlwm Lilu LiluFriend LucyRTL8125Ethernet MacHyperVSupport NightShiftUnlocker NoTouchID NoVPAJpeg NullCpuPowerManagement NullEthernet NvidiaGraphicsFixup NVMeFix OpenCore RadeonSensor RealtekRTL8111 RestrictEvents RTCMemoryFixup SMCAMDProcessor Shiki SinetekRTSX SystemProfilerMemoryFixup ThunderboltReset TSCAdjustReset USBInjectAll USBToolBox VirtualSMC VoodooHDA VoodooI2C VoodooInput VoodooPS2 VoodooSDHC VoodooSMBus VoodooTSCSync WhateverGreen YogaSMC"
allkextslower=$( echo "$allkextsupper" | tr '[:upper:]' '[:lower:]' )

#======================== Excluded Kexts =========================#

function _excludedkexts()
{
    kextstatsori=$( kextstat | grep -v com.apple | grep -v "VoodooI2C[A-Z]" | grep -v "PS2Keyboard" | grep -v "PS2Trackpad" | grep -v "PS2Mouse" | grep -v "BrcmPatchRAM" | sed -e 's/IntelMausi-WOL/IntelMausiWOL/g' -e  's/AppleALCU/AppleALC/g' )
    bdmesg=$( ../bin/./BDMESG |grep "Clover revision" |sed 's/.*revision:\ //g' |cut -c 1-4 |sed -e 's/^/Clover\ (/' -e 's/$/)/g' )
    kextstatsori=$( echo -e "$kextstatsori" "\n$bdmesg" )
    kextstatsori=$( echo -e "$kextstatsori" |sed "s/d*)/)/g" )
    bootloader=$( _helpDefaultRead "Bootloader" )
    if [[ $bootloader = "OpenCore" ]]; then
      ocversion=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version |sed -e "s/.*REL/REL/g" -e "s/REL-//g" -e "s/.*DBG/DBG/g" -e "s/DBG-//g" -e "s/-.*//g" )
        if [[ $ocversion != "" ]]; then
          kextstatsori=$( echo -e "$kextstatsori" "\nOpenCore ($ocversion)" )
        fi
    fi

    ### DEBUG area. Testing Kexts without really loaded ###
    #kextstatsori=$( echo -e "$kextstatsori" |grep -vw  "AppleALC" )
    #kextstatsori=$( echo -e "$kextstatsori" "\n CryptexFixup (0.0.1)" )
    #kextstatsori=$( echo -e "$kextstatsori" "\n  FeatureUnlock (0.0.1)" )
    #kextstatsori=$( echo -e "$kextstatsori" "\n  AMFIPass (1.3.3)" )

    if [[ "$offline_efi" = "yes" ]]; then
        rm "$ScriptTmpPath"/offline_efi_kexts
        kextstatsori=""
        offline_node=$( _helpDefaultRead "EFIx" )
        offline_path=$( df -h |grep $offline_node |sed 's/.*\/Vol/\/Vol/g')
        find "$offline_path" -name "Info.plist" |grep -v Sensor |grep -v 501 | while read fname; do
        kext_name=$( /usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "$fname" )
        kext_version=$( /usr/libexec/PlistBuddy -c "print CFBundleVersion" "$fname" )
        echo "$kext_name (""$kext_version"")" >> "$ScriptTmpPath"/offline_efi_kexts
        done
        
        find "$offline_path" -name "CLOVERX64.efi" |grep -v 501 | while read fname; do
        kext_version=$( strings "$fname" |grep "Clover revision" |sed 's/.*revision:\ //g' |cut -c 1-4 |sed -e 's/^/Clover\ (/' -e 's/$/)/g' )
        echo "Clover (""$kext_version"")" >> "$ScriptTmpPath"/offline_efi_kexts
        done

        sort -u "$ScriptTmpPath"/offline_efi_kexts |uniq > "$ScriptTmpPath"/offline_efi_kexts2
        rm "$ScriptTmpPath"/offline_efi_kexts
        mv "$ScriptTmpPath"/offline_efi_kexts2 "$ScriptTmpPath"/offline_efi_kexts
        kextstatsori=$( cat "$ScriptTmpPath"/offline_efi_kexts )
    fi

    if [[ "$custom_efi" = "yes" ]]; then
        rm "$ScriptTmpPath"/custom_efi_kexts
        kextstatsori=""
        custom_path=$( _helpDefaultRead "CustomEfiPath" )
        find "$custom_path" -name "Info.plist" |grep -v Sensor |grep -v 501 | while read fname; do
        kext_name=$( /usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "$fname" )
        kext_version=$( /usr/libexec/PlistBuddy -c "print CFBundleVersion" "$fname" )
        echo "$kext_name (""$kext_version"")" >> "$ScriptTmpPath"/custom_efi_kexts
        done

        find "$custom_path" -name "CLOVERX64.efi" |grep -v 501 | while read fname; do
        kext_version=$( strings "$fname" |grep "Clover revision" |sed 's/.*revision:\ //g' |cut -c 1-4 |sed -e 's/^/Clover\ (/' -e 's/$/)/g' )
        echo "Clover (""$kext_version"")" >> "$ScriptTmpPath"/custom_efi_kexts
        done

        sort -u "$ScriptTmpPath"/custom_efi_kexts |uniq > "$ScriptTmpPath"/custom_efi_kexts2
        rm "$ScriptTmpPath"/custom_efi_kexts
        mv "$ScriptTmpPath"/custom_efi_kexts2 "$ScriptTmpPath"/custom_efi_kexts
        kextstatsori=$( cat "$ScriptTmpPath"/custom_efi_kexts )
    fi

    kext="ACPIBatteryManager"
    check=$( echo "$content" | grep -w ex-$kext | sed "s/.*=\ //g" )
    if [[ $check = "true" ]]; then
        kextstats=$( echo "$kextstatsori" | grep -vw $kext )
        else
        kextstats=$( echo "$kextstatsori" )
    fi

    array=($allkextsupper)
    for i in "${array[@]}"; do
        if [[ "$i" = "BrcmPatchRam" ]]; then
            i="BrcmFirmwareStore"
        fi
        check=$( echo "$content" | grep -w ex-$i | sed "s/.*=\ //g" )
        if [[ "$i" = "VoodooPS2" ]]; then
            i="PS2Controller"
        fi
        if [[ $check = "true" ]]; then
            kextstats=$( echo "$kextstats" | grep -vw $i )
            else
            kextstats=$( echo "$kextstats" )
        fi
    done
    
}

################################################################
####################### Helper Function End ####################
################################################################



#========================= Kext Array =========================#
## Script Name,kextstat Name, echo Name, Ersatz Name
#

kextArray=(
"acpibatterymanager","org.rehabman.driver.AppleSmartBatteryManager","ACPIBatteryManager",""
"airportbrcmfixup","BrcmWLFixup","BrcmWLFixup","AirportBrcmFixup"
"airportbrcmfixup","AirportBrcmFixup","AirportBrcmFixup",""
"amfipass","AMFIPass","AMFIPass",""
"applealc","AppleALC","AppleALC",""
"applebacklightfixup","AppleBacklightFixup","AppleBacklightFixup","WhateverGreen","Alarm"
"applebacklightsmoother","AppleBacklightSmoother","AppleBacklightSmoother",""
"asussmc","AsusSMC","AsusSMC",""
"ath9kfixup","ATH9KFixup","ATH9KFixup",""
"atherose2200ethernet","AtherosE2200Ethernet","AtherosE2200Ethernet",""
"azulpatcher4600","AzulPatcher4600","AzulPatcher4600",""
"bigsurface","BigSurface","BigSurface",""
"brcmpatchram","BrcmFirmwareStore","BrcmPatchRam",""
"brightnesskeys","BrightnessKeys","BrightnessKeys",""
"bt4lecontinuityfixup","BT4LEContinuityFixup","BT4LEContinuityFixup",""
"clover","Clover","Clover",""
"codeccommander","CodecCommander","CodecCommander",""
"coredisplayfixup","CoreDisplayFixup","CoreDisplayFixup","WhateverGreen","Alarm"
"cpufriend","CPUFriend","CPUFriend",""
"cputscsync","CpuTscSync","CpuTscSync",""
"cryptexfixup","CryptexFixup","CryptexFixup",""
"ecenabler","ECEnabler","ECEnabler",""
"enablelidwake","EnableLidWake","EnableLidWake",""
"fakepciid","FakePCIID","FakePCIID",""
"fakesmc","FakeSMC","FakeSMC",""
"featureunlock","FeatureUnlock","FeatureUnlock",""
"genericusbxhci","GenericUSBXHCI","GenericUSBXHCI",""
"hibernationfixup","HibernationFixup","HibernationFixup",""
"horndis","HoRNDIS","HoRNDIS",""
"intelbluetoothfirmware","IntelBluetoothFirmware","IntelBluetoothFirmware",""
"intelgraphicsdvmtfixup","IntelGraphicsDVMTFixup","IntelGraphicsDVMTFixup","WhateverGreen","Alarm"
"intelgraphicsfixup","IntelGraphicsFixup","IntelGraphicsFixup","WhateverGreen","Alarm"
"intelmausi","AppleIntelE1000","AppleIntelE1000","IntelMausi"
"intelmausiethernet","IntelMausiEthernet","IntelMausiEthernet",""
"intelmausi","IntelMausi","IntelMausi",""
"intelmausiwol","IntelMausiWOL","IntelMausi-WOL",""
"airportitlwm","AirportItlwm","AirportItlwm",""
"itlwm","itlwm","itlwm",""
"lilu","Lilu","Lilu",""
"lilufriend","LiluFriend","LiluFriend",""
"lucyrtl8125ethernet","LucyRTL8125Ethernet","LucyRTL8125Ethernet",""
"macpromnd","MacProMemoryNotificationDisabler","MacProMemoryNotificationDisabler",""
"nightshiftunlocker","NightShiftUnlocker","NightShiftUnlocker",""
"machypervsupport","MacHyperVSupport","MacHyperVSupport",""
"notouchid","NoTouchID","NoTouchID",""
"novpajpeg","NoVPAJpeg","NoVPAJpeg",""
"nullcpupowermanagement","NullCpuPower","NullCpuPowerManagement",""
"nullethernet","NullEthernet","NullEthernet",""
"nvidiagraphicsfixup","LibValFix","NVWebDriverLibValFix","WhateverGreen","Alarm"
"nvidiagraphicsfixup","NvidiaGraphicsFixup","NvidiaGraphicsFixup","WhateverGreen","Alarm"
"nvmefix","NVMeFix","NVMeFix",""
"opencore","OpenCore","OpenCore",""
"radeonsensor","RadeonSensor","RadeonSensor",""
"realtekrtl8111","RealtekRTL8111","RealtekRTL8111",""
"rtcmemoryfixup","RTCMemoryFixup","RTCMemoryFixup",""
"restrictevents","RestrictEvents","RestrictEvents",""
"smcamdprocessor","SMCAMDProcessor","SMCAMDProcessor",""
"shiki","Shiki","Shiki","WhateverGreen","Alarm"
"sinetekrtsx","Sinetek-rtsx","Sinetekrtsx",""
"smalltreeintel82576","SmallTreeIntel82576","SmallTreeIntel82576",""
"systemprofilermemoryfixup","SystemProfilerMemoryFixup","SystemProfilerMemoryFixup",""
"thunderboltreset","ThunderboltReset ","ThunderboltReset",""
"tscadjustreset","TSCAdjustReset","TSCAdjustReset",""
"usbinjectall","USBInjectAll","USBInjectAll",""
"usbtoolbox","USBToolBox","USBToolBox",""
"virtualsmc","VirtualSMC","VirtualSMC",""
"voodoohda","VoodooHDA","VoodooHDA",""
"voodooi2c","VoodooI2C","VoodooI2C",""
"voodooinput","VoodooInput","VoodooInput",""
"voodoops2","PS2Controller","VoodooPS2",""
"voodoosdhc","VoodooSDHC","VoodooSDHC",""
"voodoosmbus","VoodooSMBus","VoodooSMBus",""
"voodootscsync","VoodooTSCSync","VoodooTSCSync",""
"whatevergreen","WhateverGreen","WhateverGreen",""
"yogasmc","YogaSMC","YogaSMC",""
)

#========================= Language Detection =========================#
function _languageselect()
{

    if [[ $lan2 = de* ]]; then
      export LC_ALL=de_DE
      language="de"
    else
      export LC_ALL=en_EN
      language="en"
    fi
    if [ ! -d "$ScriptTmpPath" ]; then
        mkdir "$ScriptTmpPath"
    fi

    cat ../bashstrings/$language.bashstrings > ${ScriptTmpPath}/locale.tmp

    source ${ScriptTmpPath}/locale.tmp
}

###################################################################
########################### Set Root User #########################
###################################################################

function _setrootuser()
{

    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    user=$( id -un )
    userfull=$( id -F "$user" )
    OK="0"

    admin=$( _helpDefaultRead "Admin" ) >/dev/null 2>&1
    if [[ $admin = "" ]]; then

    groups "$user" | grep -q -w admin
    if [ $? = 0 ]; then
      _helpDefaultWrite "Admin" "Yes"
      _helpDefaultWrite "Rootuser" "$user"
      _helpDefaultWrite "RootuserFull" "$userfull"
    else
      _helpDefaultWrite "Admin" "No"
      admin="No"
    fi

    _languageselect

    if [[ $admin = "No" ]]; then

    echo -e "read -r -d '' applescriptCode <<'EOF'" > "$ScriptTmpPath"/result
    echo -e "set dialogText to text returned of (display dialog \"$textadmin\" default answer \"$answeradmin\" with icon file \":..:pics:admin.png\")" >> "$ScriptTmpPath"/result
    echo -e "return dialogText" >> "$ScriptTmpPath"/result
    echo -e "EOF" >> "$ScriptTmpPath"/result
    echo -e "dialogText=\$(osascript -e \"\$applescriptCode\");" >> "$ScriptTmpPath"/result
    source "$ScriptTmpPath"/result
    userfull=$( id -F $dialogText )
    user=$( id -un $dialogText )

        if [ "$?" != "0" ]; then
          echo -e "$warnnouser\n"
          _helpDefaultWrite "Rootuser" "$user"
          _helpDefaultWrite "RootuserFull" "$userfull"
            if [[ $checkchime = "1" ]]; then
              afplay -v "$speakervolume" ../sounds/error.aif &
            fi
          echo -e "$noadmin\n"
        else
            if id "$user" >/dev/null 2>&1; then
              _helpDefaultWrite "Rootuser" "$user"
              _helpDefaultWrite "RootuserFull" "$userfull"
              groups "$user" | grep -q -w admin
                if [ $? = 0 ]; then
                  _helpDefaultWrite "Admin" "Yes"
                else
                if [[ $checkchime = "1" ]]; then
                  afplay -v "$speakervolume" ../sounds/error.aif &
                fi
                echo -e "$noadmin\n"
                fi
                if [[ $checkchime = "1" ]]; then
                  afplay -v "$speakervolume" ../sounds/passok.aif &
                fi
            else
              echo -e "$usernoexist\n"
                until [[ $OK = "1" ]]; do
                  source "$ScriptTmpPath"/result
                    if [ "$?" != "0" ]; then
                      OK="1"
                      _helpDefaultWrite "Rootuser" "$user"
                      _helpDefaultWrite "RootuserFull" "$userfull"
                      groups "$user" | grep -q -w admin
                        if [ $? = 0 ]; then
                          _helpDefaultWrite "Admin" "Yes"
                        fi
                        if [[ $checkchime = "1" ]]; then
                          afplay -v "$speakervolume" ../sounds/passok.aif &
                        fi
                    else
                        if id "$dialogText" >/dev/null 2>&1; then
                          OK="1"
                          _helpDefaultWrite "Rootuser" "$user"
                          _helpDefaultWrite "RootuserFull" "$userfull"
                          groups "$user" | grep -q -w admin
                            if [ $? = 0 ]; then
                              _helpDefaultWrite "Admin" "Yes"
                                if [[ $checkchime = "1" ]]; then
                                  afplay -v "$speakervolume" ../sounds/passok.aif &
                                fi
                            else
                              echo -e "$noadmin\n"
                            fi
                        else
                          echo -e "$usernoexist\n"
                            if [[ $checkchime = "1" ]]; then
                              afplay -v "$speakervolume" ../sounds/error.aif &
                            fi
                        fi
                    fi
                done
              fi
        fi
    fi
fi
}

function _resetrootuser()
{

    /usr/libexec/PlistBuddy -c "Delete Rootuser" "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" >/dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Delete Admin" "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" >/dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Delete Passwordok" "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" >/dev/null 2>&1
    _setrootuser

}
###################################################################
######################### Seek all EFIs ###########################
###################################################################

function scanallefis()
{

    if [ -f "$ScriptTmpPath"/drives ]; then
      rm "$ScriptTmpPath"/drives*
    fi

    bootnode=$( _helpDefaultRead "EFI Root" )
    
    diskutil info "$bootnode" > /dev/null

    if [[ "$?" = "0" ]]; then
        excludebootefi=$( diskutil info "$bootnode" |grep "Node" | sed "s/.*dev\///g" | rev | sed 's/[0-9]s//g' | rev )
        efis=$( diskutil list | grep "EFI" | sed "s/.*disk/disk/g" | rev | sed 's/[0-9]s//g' | rev | grep -v "$excludebootefi$")
    else
        efis=$( diskutil list | grep "EFI" | sed "s/.*disk/disk/g" | rev | sed 's/[0-9]s//g' | rev )
    fi
   
    while read -r line; do
    node=$( echo $line )
    efiname=$( diskutil info $node |grep "Media Name:" | sed "s/.*://g" |xargs )
    echo -e "$line"";""$efiname" >> "$ScriptTmpPath"/drives
    done <<< "$efis"

    checkdrives=$( cat "$ScriptTmpPath"/drives )

    num="0"
    while read -r line; do
    num=$(( $num + 1 ))
    node=$( cat "$ScriptTmpPath"/drives | head -$num | tail -1 | cut -d";" -f1-1 )
    name=$( cat "$ScriptTmpPath"/drives | head -$num | tail -1 | cut -d";" -f2-2 )
    echo "$node - $name" >> "$ScriptTmpPath"/drives_pulldown
    done < "$ScriptTmpPath"/drives

    cp "$ScriptTmpPath"/drives_pulldown "$ScriptTmpPath"/drives_pulldown2
    awk 'BEGIN{print""}1' "$ScriptTmpPath"/drives_pulldown2 > "$ScriptTmpPath"/drives_pulldown
    rm "$ScriptTmpPath"/drives_pulldown2
    perl -e 'truncate $ARGV[0], ((-s $ARGV[0]) - 1)' "$ScriptTmpPath"/drives_pulldown  2> /dev/null
    
    drives_size=$( stat -f%z "$ScriptTmpPath"/drives_pulldown )
    
    if [[ "$drives_size" -lt "8" ]]; then
        rm "$ScriptTmpPath"/drives_pulldown
    fi
    
}

function mountefiall()
{

    initial

    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )

    _languageselect

    offlineefi=$( _helpDefaultRead "OfflineEFI" )
    node=$( _helpDefaultRead "EFIx" )
    if [[ $keychain = "1" ]]; then
    _getsecret
    osascript -e 'do shell script "diskutil mount '$node'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
    else
    osascript -e 'do shell script "diskutil mount '$node'" with administrator privileges' >/dev/null 2>&1
    fi

    if [ $? != 0 ]; then
        if [[ $checkchime = "1" ]]; then
          _playchimedeath
        fi
        echo "$error"
    else
        _helpDefaultWrite "Mounted" "No"

    if [[ $mountpoint != "" ]];then
      if [[ $bootloader = "Ozmosis" ]]; then
        efipath=$( find "$mountpoint" -name "*efaults.plist" |grep -v "Trashes" | grep -v "._" | sed -e 's/Defaul.*//g' -e 's/defaul.*//g' -e 's/DEFAUL.*//g' |head -n 1 )
      fi
      if [[ $bootloader = Clover* ]]; then
        cloverconfig=$( _helpDefaultRead "Cloverconfig" )
        efipath=$( find "$mountpoint" -maxdepth 3 -name "$cloverconfig" |sed -e "s/\.//g" -e "s/CLOVER\/.*/CLOVER\//g" | grep -v "Trashes" | grep -w "CLOVER" | head -n 1 )
      fi
      if [[ $bootloader = "OpenCore" ]]; then
        efipath=$( find "$mountpoint" -name "OpenCore.efi" |sed -e "s/\.//g" -e "s/OpenC.*//g" |grep -v "Trashes" |head -n 1 )
      fi
    fi

    _helpDefaultWrite "EFI Path" "$efipath"
    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "EFI Path" "$efipath"

        if [[ $checkchime = "1" ]]; then
            if [[ "$offlineefi" = "0" ]]; then
                _playchime
            fi
        fi
        echo "$alldone"
    fi

}

function unmountefi()
{

    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )

    _languageselect

    node=$( _helpDefaultRead "EFIx" )
    if [[ $keychain = "1" ]]; then
    _getsecret
    osascript -e 'do shell script "diskutil unmount '$node'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
    else
    osascript -e 'do shell script "diskutil unmount '$node'" with administrator privileges' >/dev/null 2>&1
    fi

    _helpDefaultWrite "Mounted" "No"

    if [[ $checkchime = "1" ]]; then
      _playchime
    fi

    echo "$alldone"

}

function unmountefiall()
{

    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )

    user=$( _helpDefaultRead "Rootuser" )

    _languageselect

    cp "$ScriptTmpPath"/drives_pulldown "$ScriptTmpPath"/drives_pulldown_unmount
    echo "" >> "$ScriptTmpPath"/drives_pulldown_unmount

    while IFS= read -r line
    do
        if [[ "$line" != "" ]]; then
            disk=$( echo "$line" | sed 's/\ -\ .*//g' )
            disk=$( echo "$disk"s1 )
            if [[ $keychain = "1" ]]; then
                _getsecret
            osascript -e 'do shell script "diskutil unmount '$disk'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
                else
            osascript -e 'do shell script "diskutil unmount '$disk'" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    done < ""$ScriptTmpPath"/drives_pulldown_unmount"

    _helpDefaultWrite "Mounted" "No"

    if [[ $checkchime = "1" ]]; then
      _playchime
    fi

    echo "$alldone"

}

################################################################
####################### Initial Function #######################
################################################################

function initial()
{

    /usr/libexec/PlistBuddy -c "Print RootuserFull" "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" >/dev/null 2>&1
    if [[ $? = "1" ]]; then
    /usr/libexec/PlistBuddy -c "Delete Admin" "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" >/dev/null 2>&1
    /usr/libexec/PlistBuddy -c "Delete Rootuser" "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" >/dev/null 2>&1
    fi

    _languageselect

    efiscan=$( ../bin/./BDMESG |grep -e "SelfDevicePath" -e "Found Storage" | head -n 1 | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )

    if [[ $efiscan = "" ]]; then
        efiscan=$( ../bin/./BDMESG |grep -B3 "SelfVolume" | head -n 1 | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
    fi

    if [[ $efiscan = "" ]]; then
        efiscan=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:boot-path | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
    fi

    diskscan=$( diskutil info $efiscan )

    efiroot=$( echo -e "$efiscan" )
    efiname=$( echo -e "$diskscan" | grep "Volume Name:" | sed "s/.*://g" | xargs )
    clovermode=$( ../bin/./BDMESG |grep -i "starting clover" |sed "s/.*EFI/UEFI/g" |tr -d '\r' |grep UEFI |xargs )
    cloverconfig=$( ../bin/./BDMESG |grep -w "loaded: Success" |sed -e "s/.*\\\//g" -e 's/.plist.*/.plist/g' |xargs )
    ozmosischeck=$( ../bin/./BDMESG | grep "Ozmosis" )
    ozmosischeck2=$( nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:UserInterface 2> /dev/null )
    ozmosischeck3=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:BaseBoardSerial 2> /dev/null )
    ozmosischeck4=$( nvram 1F8E0C02-58A9-4E34-AE22-2B63745FA101:DarwinDiskTemplate 2> /dev/null )
    devicenode=$( echo -e "$diskscan" | grep "Device Node:" | sed "s/.*://g" | xargs )
    devicenodemain=$( echo -e "$devicenode" | sed "s/s[0-9]//g" )
    drivemodel=$( diskutil info $devicenodemain |grep "Media Name:" | sed "s/.*://g" |xargs )
    devicelocation=$( echo -e "$diskscan" | grep "Device Location:" | sed "s/.*://g" | xargs )
    removablemedia=$( echo -e "$diskscan" | grep "Removable Media:" | sed "s/.*://g" | xargs )
    mounted=$( echo -e "$diskscan" | grep "Mounted:" | sed "s/.*://g" | xargs )
    mountpoint=$( echo -e "$diskscan" | grep "Mount Point:" | sed "s/.*://g" | xargs )
    solidstate=$( echo -e "$diskscan" | grep "Solid State:" | sed "s/.*://g" | xargs )
    protocol=$( echo -e "$diskscan" | grep "Protocol:" | sed "s/.*://g" | xargs )
    kuroot=$( pwd | sed "s/\/Kext.*//g" )
    osversion=$( sw_vers | grep ProductVersion | cut -d':' -f2 | xargs )
    #oswriteprotected=$( diskutil info / |grep "Only Volume" | sed 's/.*://g' | xargs )

    check_silicon=$( _helpDefaultRead "AppleSilicon" )
    if [ "$check_silicon" = "1" ]; then
        _helpDefaultWrite "Bootloaderversion" "AppleSilicon"
    fi

    if [[ "$ozmosischeck" != "" ]] || [[ "$ozmosischeck2" != "" ]] || [[ "$ozmosischeck3" != "" ]] || [[ "$ozmosischeck4" != "" ]]; then
        bootloader="Ozmosis"
        _helpDefaultWrite "Bootloaderversion" "$bootloader" &
        choosed="1"
    fi

    if [[ "$clovermode" != "" ]]; then
        bootloader="Clover - Legacy"
        cloverrevision=$( ../bin/./BDMESG |grep "revision:" | sed "s/.*revision\://g" | xargs | cut -c 1-4 )
        _helpDefaultWrite "Bootloaderversion" "$bootloader r$cloverrevision"
        _helpDefaultWrite "Cloverconfig" "$cloverconfig" &
        choosed="1"
    fi

    if [[ "$clovermode" = "UEFI" ]]; then
        bootloader="Clover - UEFI"
        cloverrevision=$( ../bin/./BDMESG |grep "revision:" | sed "s/.*revision\://g" | xargs | cut -c 1-4 )
        _helpDefaultWrite "Bootloaderversion" "$bootloader r$cloverrevision"
        _helpDefaultWrite "Cloverconfig" "$cloverconfig" &
        choosed="1"
    fi

    if [[ "$choosed" != "1" ]]; then
        bootloader="OpenCore"
        ocversion=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version |sed -e "s/.*REL/REL/g" -e "s/REL-//g" -e "s/.*DBG/DBG/g" -e "s/DBG-//g" -e "s/-202/\ 202/g" -e 's/./&./1' -e 's/./&./3' -e "s/.*0/(&/" -e "s/./&)/6" )
        _helpDefaultWrite "Bootloaderversion" "'OC $ocversion'"
    fi

    nohack=$( _helpDefaultRead "Bootloaderversion" )
    if [[ "$nohack" = "OpenCore v" ]]; then
        lang=$( osascript -e 'user locale of (get system info)' )
        if [[ "$lang" = "de_DE" ]]; then
            _helpDefaultWrite "Bootloaderversion" "😢 Kein Hackintosh!"
        else
            _helpDefaultWrite "Bootloaderversion" "😢 Get a Hackintosh!"
        fi
    fi

    if [[ $mountpoint != "" ]];then
      if [[ $bootloader = "Ozmosis" ]]; then
        efipath=$( find "$mountpoint" -name "*efaults.plist" |grep -v "Trashes" | grep -v "._" | sed -e 's/Defaul.*//g' -e 's/defaul.*//g' -e 's/DEFAUL.*//g' |head -n 1 )
      fi
      if [[ $bootloader = Clover* ]]; then
        efipath=$( find "$mountpoint" -maxdepth 3 -name "$cloverconfig" |sed -e "s/\.//g" -e "s/CLOVER\/.*/CLOVER\//g" | grep -v "Trashes" | grep -w "CLOVER" | head -n 1 )
      fi
      if [[ $bootloader = "OpenCore" ]]; then
        efipath=$( find "$mountpoint" -name "OpenCore.efi" |sed -e "s/\.//g" -e "s/OpenC.*//g" |grep -v "Trashes" |grep -w "/Volumes/.*./EFI/OC/" |head -n 1 )
      fi
    fi

    _helpDefaultWrite "EFI Path" "$efipath" &
    _helpDefaultWrite "EFI Root" "$efiroot" &
    _helpDefaultWrite "EFI Name" "$efiname" &
    _helpDefaultWrite "KU Root" "$kuroot" &
    _helpDefaultWrite "Device Node" "$devicenode" &
    _helpDefaultWrite "Device Location" "$devicelocation" &
    _helpDefaultWrite "Removable Media" "$removablemedia" &
    _helpDefaultWrite "Solid State" "$solidstate" &
    _helpDefaultWrite "Removable Media" "$removablemedia" &
    _helpDefaultWrite "Mounted" "$mounted" &
    _helpDefaultWrite "Mount Point" "$mountpoint" &
    _helpDefaultWrite "Drive Model" "$drivemodel" &
    _helpDefaultWrite "Device Protocol" "$protocol" &
    _helpDefaultWrite "Bootloader" "$bootloader" &
    _helpDefaultWrite "OSVersion" "$osversion" &
    #_helpDefaultWrite "RW" "$oswriteprotected" &
    
    check_silicon=$( _helpDefaultRead "AppleSilicon" )
    if [ "$check_silicon" = "1" ]; then
        _helpDefaultWrite "Bootloaderversion" "Apple Silicon"
    fi

    defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "EFI Path" "$efipath"

    menubar_version_running=$( defaults read "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "AppVersion" )
    menubar_pid=$( defaults read "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "PID" )
    menubar_version_bundle=$( defaults read "${kuroot}/Kext Updater.app/Contents/Resources/bin/KUMenuBar.app/Contents/Info.plist" "CFBundleShortVersionString" )
    menubar_prefs_activated=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "MenuBarItem" )

    if [[ "$menubar_version_running" = "" || "$menubar_version_bundle" = "" ]]; then
        pkill -f KUMenuBar
        menubar_version_running="ToChange"
    fi

    if [[ "$menubar_version_running" != "$menubar_version_bundle" ]]; then
        if [[ "$menubar_prefs_activated" = "1" ]]; then
            pkill -f KUMenuBar
            kill -kill "$menubar_pid" >/dev/null 2>&1
            open "${kuroot}/Kext Updater.app/Contents/Resources/bin/KUMenuBar.app"
        fi
    fi

    if [[ "$menubar_pid" = "" ]] && [[ "$menubar_prefs_activated" = "1" ]]; then
        open "${kuroot}/Kext Updater.app/Contents/Resources/bin/KUMenuBar.app"
    fi

    _setrootuser

    rootuser=$( _helpDefaultRead "Rootuser" )

    if [[ $bootloader = "OpenCore" ]]; then
    check_opencore_conf
    fi

    keychain=$( _helpDefaultRead "Keychain" )

    if [[ "$keychain" = 1 ]]; then ### Checks if the Rootpassword is still valid
        passw=$( security find-generic-password -a "Kext Updater" -w | sed "s/\"/\\\\\"/g" )
            if [[ "$passw" != 44 ]]; then
                osascript -e 'do shell script "sudo date" user name "'"$rootuser"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
                if [[ $? != "0" ]]; then
                    echo "$rootpass_wrong"
                fi
            fi
    fi

    ### Checks if Hackintosh Kexts are in /L/E and /S/L/E and warns the user
    basename /Library/Extensions/*.kext | sed 's/\.kext//g' > "$ScriptTmpPath"/le_sle_list
    basename /System/Library/Extensions/*.kext | sed 's/\.kext//g' >> "$ScriptTmpPath"/le_sle_list

    #echo "AppleALC" >> "$ScriptTmpPath"/le_sle_list
    #echo "SystemProfilerMemoryFixup" >> "$ScriptTmpPath"/le_sle_list
    #echo "Lilu" >> "$ScriptTmpPath"/le_sle_list
    #echo "VoodooPS2" >> "$ScriptTmpPath"/le_sle_list

    array=($allkextsupper)
    for i in "${array[@]}"; do
        echo "$i" >> "$ScriptTmpPath"/le_sle_array
    done
    
    grep -Ff "$ScriptTmpPath"/le_sle_array "$ScriptTmpPath"/le_sle_list > "$ScriptTmpPath"/le_sle_result

    if [ -s "$ScriptTmpPath"/le_sle_result ]
    then
        perl -e 'truncate $ARGV[0], ((-s $ARGV[0]) - 1)' "$ScriptTmpPath"/le_sle_result  2> /dev/null
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "LESLE Warning" -bool YES
    else
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "LESLE Warning" -bool NO
    fi

    #osversion2=$( echo "$osversion" | cut -c 1-2 )
    #if [[ "$osversion2" > "10" ]]; then
        #mkdir /private/tmp/mount_root 2> /dev/null
        #check_auth_root=$( csrutil authenticated-root status )
        #if [[ "$check_auth_root" = *"disabled"* ]]; then
            #_helpDefaultWrite "AuthRoot" "Yes"
        #else
            #_helpDefaultWrite "AuthRoot" "No"
        #fi
    #fi
}

#################################################################
####################### Mount Bootefi  ##########################
#################################################################

function mountefi()
{

    initial

    efiroot=$( _helpDefaultRead "EFI Root" )
    mounted=$( _helpDefaultRead "Mounted" )
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    admin=$( _helpDefaultRead "Admin" )

    if [[ $mounted = "Yes" ]]; then
        if [[ $keychain = "1" ]]; then
          _getsecret
          osascript -e 'do shell script "diskutil unmount '$efiroot'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
          osascript -e 'do shell script "diskutil unmount '$efiroot'" with administrator privileges' >/dev/null 2>&1
        fi
        if [ $? = 0 ]; then
          _helpDefaultWrite "Mounted" "No"
        fi
    else
        if [[ $keychain = "1" ]]; then
          _getsecret
          osascript -e 'do shell script "diskutil mount '$efiroot'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
          osascript -e 'do shell script "diskutil mount '$efiroot'" with administrator privileges' >/dev/null 2>&1
        fi
        status="$?"
        if [ $status = "0" ]; then
            _helpDefaultWrite "Mounted" "Yes"
        fi
        if [ $status != "0" ]; then
            node=$( ../bin/./BDMESG |grep -e "SelfDevicePath" -e "Found Storage" | head -n 1 |sed -e 's/.*GPT,//' -e 's/,0x.*//' )
            
            if [[ $node = "" ]]; then
                node=$( ../bin/./BDMESG |grep -B3 "SelfVolume" | head -n 1 | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
            fi
            
            if [[ $node = "" ]]; then
                node=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:boot-path | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
            fi

            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "diskutil mount '$node'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "diskutil mount '$node'" with administrator privileges' >/dev/null 2>&1
            fi
            if [ $? = 0 ]; then
                _helpDefaultWrite "Mounted" "Yes"
            fi
        fi
        efiscan=$( ../bin/./BDMESG |grep -e "SelfDevicePath" -e "Found Storage" | head -n 1 | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
        
        if [[ $efiscan = "" ]]; then
            efiscan=$( ../bin/./BDMESG |grep -B3 "SelfVolume" | head -n 1 | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
        fi
        
        if [[ $efiscan = "" ]]; then
            efiscan=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:boot-path | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
        fi

        diskscan=$( diskutil info $efiscan )
        mountpoint=$( echo -e "$diskscan" | grep "Mount Point:" | sed "s/.*://g" | xargs )
        _helpDefaultWrite "Mount Point" "$mountpoint"

    if [[ $mountpoint != "" ]];then
      if [[ $bootloader = "Ozmosis" ]]; then
        efipath=$( find "$mountpoint" -name "*efaults.plist" |grep -v "Trashes" | grep -v "._" | sed -e 's/Defaul.*//g' -e 's/defaul.*//g' -e 's/DEFAUL.*//g' |head -n 1 )
      fi
      if [[ $bootloader = Clover* ]]; then
        cloverconfig=$( _helpDefaultRead "Cloverconfig" )
        efipath=$( find "$mountpoint" -maxdepth 3 -name "$cloverconfig" |sed -e "s/\.//g" -e "s/CLOVER\/.*/CLOVER\//g" | grep -v "Trashes" | grep -w "CLOVER" | head -n 1 )
      fi
      if [[ $bootloader = "OpenCore" ]]; then
        efipath=$( find "$mountpoint" -name "OpenCore.efi" |sed -e "s/\.//g" -e "s/OpenC.*//g" |grep -v "Trashes" |head -n 1 )
      fi
    fi

        _helpDefaultWrite "EFI Path" "$efipath"
        defaults write "${ScriptHome}/Library/Preferences/kextupdaterhelper.slsoft.de.plist" "EFI Path" "$efipath"
    fi
    
    if [[ "$efi_backup_running" != "1" ]]; then
        exit 0
    fi
}

###################################################################
####################### Mainscript Function #######################
###################################################################

function mainscript()
{

    _languageselect

#========================= Script Pathes =========================#
    ScriptDownloadPath=$( _helpDefaultRead "Downloadpath" )

#========================== Set Variables =========================#
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    url=$( echo -e "$content" | grep "Updater URL" | sed "s/.*\=\ //g" | xargs )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    username=$( echo -e "$content" | grep "User Name" | sed "s/.*\=\ //g" | xargs )
    realname=$( echo -e "$content" | grep "Full Name" | sed "s/.*\=\ //g" | xargs )
    efiroot=$( echo -e "$content" | grep "EFI Root" | sed "s/.*\=\ //g" | xargs )
    kexte=$( echo -e "$content" | grep "Choice" | sed "s/.*\=\ //g" | xargs )
    webdr2=$( echo -e "$content" | grep "Webdriver Build" | sed "s/.*\ \-//g" | xargs )
    singlekext=$( echo -e "$content" | grep "Load Single Kext" | sed "s/.*\=\ //g" | xargs )
    nightly=$( echo -e "$content" | grep "Clover Nightly Build" | sed "s/.*\=\ //g" | xargs )
    osuser=$( echo $realname )
    hour=$( date "+%H" )
    notifications=$( echo -e "$content" | grep "Notifications" | sed "s/.*\=\ //g" | xargs )
    notificationsseconds=$( echo -e "$content" | grep "NotificationSeconds" | sed "s/.*\=\ //g" | xargs )

    _languageselect

    os=$( _helpDefaultRead "OSVersion" )
    overview=$( curl -k -sS -A "curl/osx - $os - $lan2" https://$url/overview.html )

    if [ -f "$ScriptTmpPath"/kextarraylist ]; then
        rm "$ScriptTmpPath"/kextarraylist
    fi

    for i in "${kextArray[@]}"; do echo "$i" >> "$ScriptTmpPath"/kextarraylist; done

#========================= Check for nVidia Webdriver =========================#
checkweb=$( echo -e "$kextstats" |grep web.GeForceWeb )
if [[ $checkweb != "" ]]; then
    locweb=$( cat /Library/Extensions/NVDAStartupWeb.kext/Contents/Info.plist |grep NVDAStartupWeb\ | sed -e "s/.*Web\ //g" -e "s/<\/.*//g" |cut -c 10-99 )
    kextstats=$( echo -e "$kextstats" "\nNVDAStartupWeb ($locweb)" )
fi

#========================= Add Non-Kext Values =========================#
bdmesg=$( ../bin/./BDMESG |grep "Clover revision" |sed 's/.*revision:\ //g' |cut -c 1-4 |sed -e 's/^/Clover\ (/' -e 's/$/)/g' )
kextstats=$( echo -e "$kextstats" "\n$bdmesg" )

    if [[ "$offline_efi" = "yes" ]]; then
        rm "$ScriptTmpPath"/offline_efi_kexts
        kextstats=""
        offline_node=$( _helpDefaultRead "EFIx" )
        offline_path=$( df -h |grep $offline_node |sed 's/.*\/Vol/\/Vol/g')
        find "$offline_path" -name "Info.plist" |grep -v Sensor |grep -v 501 | while read fname; do
        kext_name=$( /usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "$fname" )
        kext_version=$( /usr/libexec/PlistBuddy -c "print CFBundleVersion" "$fname" )
        echo "$kext_name (""$kext_version"")" >> "$ScriptTmpPath"/offline_efi_kexts
        done

        find "$offline_path" -name "CLOVERX64.efi" |grep -v 501 | while read fname; do
        kext_version=$( strings "$fname" |grep "Clover revision" |sed 's/.*revision:\ //g' |cut -c 1-4 |sed -e 's/^/Clover\ (/' -e 's/$/)/g' )
        echo "Clover (""$kext_version"")" >> "$ScriptTmpPath"/offline_efi_kexts
        done

        sort -u "$ScriptTmpPath"/offline_efi_kexts |uniq > "$ScriptTmpPath"/offline_efi_kexts2
        rm "$ScriptTmpPath"/offline_efi_kexts
        mv "$ScriptTmpPath"/offline_efi_kexts2 "$ScriptTmpPath"/offline_efi_kexts
        kextstats=$( cat "$ScriptTmpPath"/offline_efi_kexts )
    fi

    if [[ "$custom_efi" = "yes" ]]; then
        rm "$ScriptTmpPath"/custom_efi_kexts
        kextstats=""
        custom_path=$( _helpDefaultRead "CustomEfiPath" )
        find "$custom_path" -name "Info.plist" |grep -v Sensor |grep -v 501 | while read fname; do
        kext_name=$( /usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "$fname" )
        kext_version=$( /usr/libexec/PlistBuddy -c "print CFBundleVersion" "$fname" )
        echo "$kext_name (""$kext_version"")" >> "$ScriptTmpPath"/custom_efi_kexts
        done

        find "$custom_path" -name "CLOVERX64.efi" |grep -v 501 | while read fname; do
        kext_version=$( strings "$fname" |grep "Clover revision" |sed 's/.*revision:\ //g' |cut -c 1-4 |sed -e 's/^/Clover\ (/' -e 's/$/)/g' )
        echo "Clover (""$kext_version"")" >> "$ScriptTmpPath"/custom_efi_kexts
        done

        sort -u "$ScriptTmpPath"/custom_efi_kexts |uniq > "$ScriptTmpPath"/custom_efi_kexts2
        rm "$ScriptTmpPath"/custom_efi_kexts
        mv "$ScriptTmpPath"/custom_efi_kexts2 "$ScriptTmpPath"/custom_efi_kexts
        kextstats=$( cat "$ScriptTmpPath"/custom_efi_kexts )
    fi

#========================= Get loaded Kexts =========================#
_excludedkexts

#========================= Ozmosis Warning =========================#
function _ozmosis()
{
    ../bin/./BDMESG | grep "Ozmosis" > /dev/null
    if [[ $? = "0" ]]; then
        echo $ozmosis
        echo " "
    fi
}

#========================= Output Headline =========================#
function _printHeader()
{
    if [ $hour -lt 12 ]; then
        echo $greet1
    elif [ $hour -lt 18 ]; then
        echo $greet2
    else
        echo $greet3
    fi
        echo " "
}

#========================= KextUpdate =========================#
function _kextUpdate()
{
    for kextList in "${kextArray[@]}"
        do
            IFS=","
            data=($kextList)
            name=${data[0]}
            newname=$( grep -w "$name" "$ScriptTmpPath"/kextarraylist | cut -f3 -d',' | grep -v "AppleIntelE1000" | grep -v "BrcmWLFixup" |grep -v "NVWebDriverLibValFix" | grep -v "NvidiaGraphicsFixup"|xargs )
            lecho=$( echo -e "$kextstats" |grep -w ${data[1]} | sed -e "s/.*(//g" -e "s/).*//g" )
            local=$( echo $lecho | sed -e "s/\.//g" )
            if ! [[ $local = "" ]]; then
                echo "$checkver ${data[2]} ..."
                if ! [[ -z ${data[3]} ]] ; then # veralteter Kext
                    _obsoleteKext
                fi
                if ! [[ -z ${data[4]} ]] ; then # Needs Lilu Kext
                    echo ""
                    echo "$alarm"
                    echo ""
                fi
                remote=$( echo -e "$overview" |grep -w $name |sed -e "s/.*-//g" -e "s/+.*//g" )
                recho=$( echo -e "$overview" |grep -w $name |sed "s/.*+//g" )
                if [ -f ${ScriptDownloadPath}/${name}/.version.htm ]; then
                    dupe=$( cat ${ScriptDownloadPath}/${name}/.version.htm )
                    if [[ $dupe = $remote ]]; then
                        _dupeKext
                    fi
                else
                    returnVALUE=$(
                    awk -v num1="$lecho" -v num2="$recho" '
                    BEGIN {
                            {if (num1 < num2) print "smaller"}
                    }
                    '
                    )
                    
                    #returnVALUE=$(expr $local '<' $remote)
                    if [[ $returnVALUE == "smaller" ]]; then
                        mkdir -p ${ScriptDownloadPath} ${ScriptDownloadPath}/${newname}
                        _toUpdate
                        curl -k -sS -o ${ScriptTmpPath}/${name}.zip https://$url/${name}/${name}.zip
                        curl -k -sS -o ${ScriptDownloadPath}/$newname/.version.htm https://$url/${name}/version.htm
                        #../bin/./7za x ${ScriptTmpPath}/${name}.7z -o${ScriptDownloadPath}/${name} -aoa > /dev/null
                        unzip -o -q ${ScriptTmpPath}/${name}.zip -d ${ScriptDownloadPath}/${name}
                        rm ${ScriptTmpPath}/${name}.zip 2> /dev/null
                        find ${ScriptDownloadPath}/. -name "Debug" -exec rm -r "{}" \; >/dev/null 2>&1
                        find ${ScriptDownloadPath}/. -name "LICENSE" -exec rm -r "{}" \; >/dev/null 2>&1
                        find ${ScriptDownloadPath}/. -name "READM*" -exec rm -r "{}" \; >/dev/null 2>&1
                        mv ${ScriptDownloadPath}/$name/Release/* ${ScriptDownloadPath}/$name/ >/dev/null 2>&1; rm -r ${ScriptDownloadPath}/$name/Release >/dev/null 2>&1
                        echo "${data[2]}" >> ${ScriptTmpPath}/kextloaded
                    else
                        _noUpdate
                    fi
                fi
            fi
        done
}

#============================== KextLoad ==============================#
function _kextLoader()
{
    #backup_warning="1"

    if [ -f ${ScriptTmpPath}/eficreator ]; then
        rm ${ScriptTmpPath}/eficreator
    fi

    for kextLoadList in "${kextLoadArray[@]}"
        do
            IFS=","
            data=($kextLoadList)
            name=${data[0]}
            newname=$( grep -w "$name" "$ScriptTmpPath"/kextarraylist | cut -f3 -d',' | grep -v "AppleIntelE1000" | grep -v "BrcmWLFixup" |grep -v "NVWebDriverLibValFix" | grep -v "NvidiaGraphicsFixup"|xargs )
            vers=$( curl -k -sS https://update.kextupdater.de/${name}/version.html )
            mkdir ${ScriptDownloadPath}/${newname}
            mkdir -p ${ScriptDownloadPath} ${ScriptDownloadPath}/${name}
            echo "$newname" >> ${ScriptTmpPath}/eficreator
            _toUpdateLoad
            #curl -k -sS -o ${ScriptTmpPath}/${name}.7z https://$url/${name}/${name}.7z
            curl -k -sS -o ${ScriptTmpPath}/${name}.zip https://$url/${name}/${name}.zip
            curl -k -sS -o ${ScriptDownloadPath}/$newname/.version.htm https://$url/${name}/version.htm
            #../bin/./7za x ${ScriptTmpPath}/${name}.7z -o${ScriptDownloadPath}/${name} -aoa > /dev/null
            unzip -o -q ${ScriptTmpPath}/${name}.zip -d ${ScriptDownloadPath}/${name}
            #rm ${ScriptTmpPath}/${name}.7z 2> /dev/null
            rm ${ScriptTmpPath}/${name}.zip 2> /dev/null
    done
}

#========================= Helpfunction Update =========================
function _toUpdate()
{
    backup_warning="1"
    touch "$ScriptTmpPath"/kumenuitem
    _PRINT_MSG "☝🏼 $upd1\n
    $upd2 $lecho
    $upd3 $recho\n\n
    $loading\n─────────────────\n"
}

function _toUpdateLoad()
{
    if [[ "$newname" = "" ]]; then
        namec=$( echo $name | awk '{print toupper(substr($0,0,1))tolower(substr($0,2))}' )
        _PRINT_MSG "$namec ($vers) $dloading\n─────────────────"
    else
        _PRINT_MSG "$newname ($vers) $dloading\n─────────────────"
    fi
}

#========================= Helpfunction no Duplicates =========================#
function _dupeKext()
{
    _PRINT_MSG "$dupekext\n─────────────────"
}

#========================= Helpfunction no Kext =========================#
function _noUpdate()
{
    _PRINT_MSG "👍🏼 $upd4 ($lecho)\n─────────────────"
}

#========================= Helpfunction obsolete Kext =========================#
function _obsoleteKext()
{
    _PRINT_MSG "$obsolete1 ${data[2]} $obsolete2 ${data[3]} $obsolete3"
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
    mkdir -p "$ScriptDownloadPath/nVidia Webdriver"
    echo Build $webdr2 $webdrload
    curl -k -sS -o "$ScriptDownloadPath/nVidia Webdriver/$webdr2.pkg" https://$url/nvwebdriver/$webdr2.pkg
    echo " "
    if [[ $checkchime = "1" ]]; then
        _playchime
    fi
    echo $alldone
    exit 0
}

#============================== Cleanup Files ==============================#
function _cleanup()
{
    if [ -d $ScriptDownloadPath ]; then
    find $ScriptDownloadPath/ -name *.dSYM -exec rm -r {} \; >/dev/null 2>&1
    find $ScriptDownloadPath/ -name __MACOSX -exec rm -r {} \; >/dev/null 2>&1
    fi
    
    rm -rf ${ScriptTmpPath}
    
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "OfflineEFI" -bool NO
    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "CustomEFI" -bool NO
    
}

#============================== Kext Updater Last Run ==============================#
function _lastcheck()
{
        lastcheckfunc=$( _helpDefaultRead "Last Check" )
        if [[ $lastcheckfunc != "Never" ]]; then
            echo $lastcheck
            echo $lastcheckfunc
            echo " "
        fi
}

#============================== Main Function ==============================#
function _main()
{
    if [[ $1 == kextUpdate ]]; then
        _printHeader
        _lastcheck
    fi
    if [[ $1 == kextUpdate ]]; then
        _kextUpdate
        if [[ $notifications = "true" ]]; then
            if [ -f ${ScriptTmpPath}/kextloaded ]; then
                amount=$( cat "$ScriptTmpPath/kextloaded" | wc -l | xargs )
                ScriptDownloadPath=$( _helpDefaultRead "Downloadpath" )
            else
                amount="0"
            fi
            runcheck_ku=$( pgrep "Kext Updater" )
            if [[ "$runcheck_ku" = "" ]] && [[ -f "$ScriptTmpPath"/kumenuitem ]]; then
                echo ""
                ../bin/KUNotifier.app/Contents/MacOS/KUNotifier -message "$daemonnotify" -title "KU MenuBar" -appIcon https://update.kextupdater.de/kextupdater/appicon.png -activate 'kextupdater.slsoft.de'
            else
                ../bin/KUNotifier.app/Contents/MacOS/KUNotifier -message "$notify1 $amount" -title "Kext Updater" -timeout $notificationsseconds & > /dev/null
            fi
        fi
    elif [[ $1 == kextLoader ]]; then
        _kextLoader
        if [[ $notifications = "true" ]]; then
            ../bin/KUNotifier.app/Contents/MacOS/KUNotifier -message "$notify2" -title "Kext Updater" -timeout $notificationsseconds & > /dev/null
        fi
    elif [[ $1 == htmlreport ]]; then
        htmlreport
        if [[ $notifications = "true" ]]; then
            ../bin/KUNotifier.app/Contents/MacOS/KUNotifier -message "$notify3" -title "Kext Updater" -timeout $notificationsseconds & > /dev/null
        fi
    fi
    _ozmosis

    echo ""
    
    _efi_folder_creator
    
    echo "$alldone"
    echo " "

    if [[ "$backup_warning" = "1" ]]; then
        echo "$backup_reminder"
    fi
    
    _cleanup

    if [[ $name = "efidriver" ]]; then
    rm -r ${ScriptDownloadPath}/"EFI Driver"
    mv ${ScriptDownloadPath}/${name} ${ScriptDownloadPath}/"EFI Driver"
    fi
    if [ -d ${ScriptDownloadPath}/"clovernightly" ]; then
        if [ ! -d ${ScriptDownloadPath}/"Clover Nightly" ]; then
            mkdir ${ScriptDownloadPath}/"Clover Nightly"/
        fi
    mv ${ScriptDownloadPath}/clovernightly/* ${ScriptDownloadPath}/"Clover Nightly"/.
    rm -r ${ScriptDownloadPath}/clovernightly
    fi
    if [ -d ${ScriptDownloadPath}/"opencore" ]; then
    mv ${ScriptDownloadPath}/opencore ${ScriptDownloadPath}/"OpenCore"
    fi
    if [ -d ${ScriptDownloadPath}/"opencore-ndk" ]; then
    mv ${ScriptDownloadPath}/opencore-ndk ${ScriptDownloadPath}/"OpenCore (NDK Fork)"
    fi
    if [ -d ${ScriptDownloadPath}/"applesupport" ]; then
    mv ${ScriptDownloadPath}/applesupport ${ScriptDownloadPath}/"AppleSupport"
    fi
    if [ -d ${ScriptDownloadPath}/"ocsupportpkg" ]; then
    mv ${ScriptDownloadPath}/ocsupportpkg ${ScriptDownloadPath}/"OcSupportPkg"
    fi
    if [ -d ${ScriptDownloadPath}/"ocbinarydata" ]; then
    mv ${ScriptDownloadPath}/ocbinarydata ${ScriptDownloadPath}/"OcBinaryData"
    fi
    if [ -d ${ScriptDownloadPath}/"nvidiagraphicsfixup" ]; then
    mv ${ScriptDownloadPath}/nvidiagraphicsfixup ${ScriptDownloadPath}/"NvidiaGraphicsFixup"
    fi
    if [ -d ${ScriptDownloadPath}/"atheroswifiinjector" ]; then
    mv ${ScriptDownloadPath}/atheroswifiinjector ${ScriptDownloadPath}/"AtherosWiFiInjector"
    fi
    if [ -d ${ScriptDownloadPath}/"macpromnd" ]; then
    mv ${ScriptDownloadPath}/macpromnd ${ScriptDownloadPath}/"MacProMemoryNotificationDisabler"
    fi
    if [ -d ${ScriptDownloadPath}/"radeonboost" ]; then
    mv ${ScriptDownloadPath}/radeonboost ${ScriptDownloadPath}/"RadeonBoost"
    fi
    if [ -d ${ScriptDownloadPath}/"thunderboltreset" ]; then
    mv ${ScriptDownloadPath}/thunderboltreset ${ScriptDownloadPath}/"ThunderboltReset"
    fi
    if [ -d ${ScriptDownloadPath}/"tscadjustreset" ]; then
    mv ${ScriptDownloadPath}/tscadjustreset ${ScriptDownloadPath}/"TSCAdjustReset"
    fi
    if [ -d ${ScriptDownloadPath}/"intelbluetoothfirmware" ]; then
    mv ${ScriptDownloadPath}/tscadjustreset ${ScriptDownloadPath}/"IntelBluetoothFirmware"
    fi
    if [ -d ${ScriptDownloadPath}/"applealcnightly" ]; then
    mv ${ScriptDownloadPath}/applealcnightly ${ScriptDownloadPath}/"AppleALC Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"intelmausiethernet" ]; then
    mv ${ScriptDownloadPath}/lilunightly ${ScriptDownloadPath}/"IntelMausiEthernet"
    fi
    if [ -d ${ScriptDownloadPath}/"lilunightly" ]; then
    mv ${ScriptDownloadPath}/lilunightly ${ScriptDownloadPath}/"Lilu Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"whatevergreennightly" ]; then
    mv ${ScriptDownloadPath}/whatevergreennightly ${ScriptDownloadPath}/"WhateverGreen Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"voodooinputnightly" ]; then
    mv ${ScriptDownloadPath}/voodooinputnightly ${ScriptDownloadPath}/"VoodooInput Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"voodoops2nightly" ]; then
    mv ${ScriptDownloadPath}/voodoops2nightly ${ScriptDownloadPath}/"VoodooPS2 Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"hibernationfixupnightly" ]; then
    mv ${ScriptDownloadPath}/hibernationfixupnightly ${ScriptDownloadPath}/"HibernationFixup Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"virtualsmcnightly" ]; then
    mv ${ScriptDownloadPath}/virtualsmcnightly ${ScriptDownloadPath}/"VirtualSMC Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"brcmpatchramnightly" ]; then
    mv ${ScriptDownloadPath}/brcmpatchramnightly ${ScriptDownloadPath}/"BrcmPatchRAM Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"airportbrcmfixupnightly" ]; then
    mv ${ScriptDownloadPath}/airportbrcmfixupnightly ${ScriptDownloadPath}/"AirportBrcmFixup Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"applesupportnightly" ]; then
    mv ${ScriptDownloadPath}/applesupportnightly ${ScriptDownloadPath}/"AppleSupport Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"efidrivernightly" ]; then
    mv ${ScriptDownloadPath}/efidrivernightly ${ScriptDownloadPath}/"EFI Driver Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"opencorenightly" ]; then
    mv ${ScriptDownloadPath}/opencorenightly ${ScriptDownloadPath}/"OpenCore Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"opencorenightly-ndk" ]; then
    mv ${ScriptDownloadPath}/opencorenightly-ndk ${ScriptDownloadPath}/"OpenCore Nightly (NDK Fork)"
    fi
    if [ -d ${ScriptDownloadPath}/"applebacklightsmoother" ]; then
    mv ${ScriptDownloadPath}/opencorenightly-ndk ${ScriptDownloadPath}/"AppleBacklightSmoother"
    fi
    if [ -d ${ScriptDownloadPath}/"brightnesskeysnightly" ]; then
    mv ${ScriptDownloadPath}/brightnesskeysnightly ${ScriptDownloadPath}/"BrightnessKeys Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"nvmefixnightly" ]; then
    mv ${ScriptDownloadPath}/nvmefixnightly ${ScriptDownloadPath}/"NVMeFix Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"cputscsyncnightly" ]; then
    mv ${ScriptDownloadPath}/cputscsyncnightly ${ScriptDownloadPath}/"CpuTscSync Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"yogasmc" ]; then
    mv ${ScriptDownloadPath}/cputscsyncnightly ${ScriptDownloadPath}/"YogaSMC"
    fi
    if [ -d ${ScriptDownloadPath}/"restricteventsnightly" ]; then
    mv ${ScriptDownloadPath}/restricteventsnightly ${ScriptDownloadPath}/"RestrictEvents Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"restrictevents" ]; then
    mv ${ScriptDownloadPath}/restrictevents ${ScriptDownloadPath}/"RestrictEvents"
    fi
    if [ -d ${ScriptDownloadPath}/"intelmausiwol" ]; then
    mkdir ${ScriptDownloadPath}/"IntelMausi-WOL"
    mv ${ScriptDownloadPath}/intelmausiwol/* ${ScriptDownloadPath}/"IntelMausi-WOL"
    rm -rf ${ScriptDownloadPath}/"intelmausiwol"
    fi
    if [ -d ${ScriptDownloadPath}/"brcmpatchram" ]; then
    mv ${ScriptDownloadPath}/brcmpatchram ${ScriptDownloadPath}/"BrcmPatchRAM"
    fi
    if [ -d ${ScriptDownloadPath}/"itlwmnightly" ]; then
    mv ${ScriptDownloadPath}/itlwmnightly ${ScriptDownloadPath}/"itlwm Nightly"
    fi
    if [ -d ${ScriptDownloadPath}/"horndis" ]; then
    mv ${ScriptDownloadPath}/horndis ${ScriptDownloadPath}/"HoRNDIS"
    fi
    if [ -d ${ScriptDownloadPath}/"sinetekrtsx" ]; then
    mv ${ScriptDownloadPath}/sinetekrtsx ${ScriptDownloadPath}/"Sinetek-rtsx"
    fi
    if [ -d ${ScriptDownloadPath}/"ecenabler" ]; then
    mv ${ScriptDownloadPath}/ecenabler ${ScriptDownloadPath}/"ECEnabler"
    fi
    if [ -d ${ScriptDownloadPath}/"usbtoolbox" ]; then
    mv ${ScriptDownloadPath}/usbtoolbox ${ScriptDownloadPath}/"USBToolBox"
    fi
    if [ -d ${ScriptDownloadPath}/"amfipass" ]; then
    mv ${ScriptDownloadPath}/amfipass ${ScriptDownloadPath}/"AMFIPass"
    fi

    if [[ $checkchime = "1" ]]; then
      _playchime
    fi
}

#============================== Choice ==============================#
if [ $kexte = "Update" ]; then
    _main "kextUpdate"
    exit 0
fi

if [ $kexte = "Single" ]; then
    if [ ! -f "$ScriptTmpPath"/array ]; then
        if [[ $checkchime = "1" ]]; then
        _playchimedeath
        fi
        echo "$nokextselected"
        exit 0
    fi
    source "$ScriptTmpPath"/array
    recho="Kexte"
    _main "kextLoader"
    exit 0
fi

if [ $kexte = "Webdriver" ]; then
    if [[ $webdr2 = "" ]]; then
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo "$nowebselected"
    else
        _nvwebdriver
    fi
    exit 0
fi

if [ $kexte = "Bootloader" ]; then
    kextchoice=$( _helpDefaultRead "Bootloaderkind" )

    if [[ $kextchoice = "" ]]; then
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo "$error"
        exit 0
    else
        if [[ $kextchoice = "Clover" ]]; then
          kextchoice="clover"
        fi
        if [[ $kextchoice = "CloverNightly" ]]; then
          kextchoice="clovernightly"
        fi
        if [[ $kextchoice = "OpenCore" ]]; then
          kextchoice="opencore"
        fi
        if [[ $kextchoice = "OpenCoreNightly" ]]; then
          kextchoice="opencorenightly"
        fi
        if [[ $kextchoice = "AppleSupport" ]]; then
          kextchoice="applesupport"
        fi
        if [[ $kextchoice = "OcSupportPkg" ]]; then
          kextchoice="ocsupportpkg"
        fi
        if [[ $kextchoice = "OcBinaryData" ]]; then
          kextchoice="ocbinarydata"
        fi
        if [[ $kextchoice = "AppleSupportNightly" ]]; then
          kextchoice="applesupportnightly"
        fi
        if [[ $kextchoice = "EFIDriver" ]]; then
          kextchoice="efidriver"
        fi
        if [[ $kextchoice = "EFIDriverNightly" ]]; then
          kextchoice="efidrivernightly"
        fi
     
    kextLoadArray=("$kextchoice")
    recho="Kexte"
    _main "kextLoader"
    exit 0
    fi

fi

if [ $kexte = "Report" ]; then
    _main "htmlreport"
    exit 0
fi

if [ $kexte = "Webdriver" ]; then
    if [[ $webdr2 = "" ]]; then
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo "$nowebselected"
    else
        _nvwebdriver
    fi
    exit 0
fi

#=========================== START ===========================#
_main "kextUpdate"
exit 0
#=============================================================#
}

###################################################################
######################## Rebuild Kext-Cache #######################
###################################################################

function rebuildcache()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    rwcheck=$( _helpDefaultRead "RW" )
    
    NodeId3=$( mount | grep ".mu_temp/mount" )
    if [[ "$NodeId3" != "" ]]; then
        OS="11"
    else
        OS="10"
    fi

    echo toll

    _languageselect

    if [[ "$OS" = "10" ]]; then
        if [[ $rwcheck = "No" ]]; then
            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    fi

    echo -e "$rebuildcache\n"

    if [[ $keychain = "1" ]]; then
        _getsecret
        if [[ "$OS" = "10" ]]; then
            osascript -e 'do shell script "chmod -R 755 /System/Library/Extensions/*; sudo chown -R root:wheel /System/Library/Extensions/*; sudo touch /System/Library/Extensions; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo kextcache -u / -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "chmod -R 755 '"$ScriptTmpPath2"'/mount/System/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/System/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/System/Library/Extensions; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i /; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' #>/dev/null 2>&1
        fi
    else
        if [[ "$OS" = "10" ]]; then
            osascript -e 'do shell script "chmod -R 755 /System/Library/Extensions/*; sudo chown -R root:wheel /System/Library/Extensions/*; sudo touch /System/Library/Extensions; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo kextcache -u / -v 6" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "chmod -R 755 '"$ScriptTmpPath2"'/mount/System/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/System/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/System/Library/Extensions; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i /; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" with administrator privileges' #>/dev/null 2>&1
        fi
    fi

    if [ $? = 0 ]; then
            if [[ $checkchime = "1" ]]; then
                _playchime
            fi
        echo "$alldone"
        else
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo -e "$error"
    fi
}

###################################################################
############################# Exit App ############################
###################################################################

function exitapp()
{
    ScriptDownloadPath=$( _helpDefaultRead "Downloadpath" )
    if [[ -d $ScriptDownloadPath ]]; then
    find "$ScriptDownloadPath" -name ".version.htm" -exec rm {} \;
    fi

    if [ -d $ScriptTmpPath ]; then
    rm -r "$ScriptTmpPath"
    fi
}

###################################################################
####################### Kext Mass Download ########################
###################################################################

function massdownload()
{
content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )

_languageselect



if [ -f "$ScriptTmpPath"/array ]; then
rm "$ScriptTmpPath"/array
fi

/usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist"| grep "dl-" |grep -v "false" | sort | xargs | sed -e "s/dl-/\"/g" -e "s/\ =\ true/\"/g" > "$ScriptTmpPath"/array

kexts=$( cat "$ScriptTmpPath"/array )

echo "kextLoadArray=($kexts)" | sed "s/\ )/)/g" > "$ScriptTmpPath"/array

checkarray=$( cat "$ScriptTmpPath"/array )

if [[ $checkarray = "kextLoadArray=()" ]]; then
_helpDefaultWrite "Ready" "Error"

check_bootloader=$( _helpDefaultRead "EFI Creator" )

if [[ "$check_bootloader" = "None" ]]; then
    echo "$nokextselected"
fi

if [[ $checkchime = "1" ]]; then

if [[ "$check_bootloader" = "None" ]]; then
    _playchimedeath
fi

fi
fi
exit 0
}

###################################################################
##################### Kext Updater Daemon #########################
###################################################################
function kudaemon()
{
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    url=$( echo -e "$content" | grep "Updater URL" | sed "s/.*\=\ //g" | xargs )

    _languageselect

    _excludedkexts

    echo "$kextstats" | tr '[:upper:]' '[:lower:]' > "$ScriptTmpPath"/daemon_kextstat

    curl -k -sS -A "KU MenuBar" -o "$ScriptTmpPath"/daemon_overview https://$url/overview.html

    while IFS='' read -r line || [[ -n "$line" ]]; do
        kext=$( echo "$line" |sed "s/-.*//g" )
        kstat=$( grep -w "$kext" "$ScriptTmpPath"/daemon_kextstat | sed -e "s/.*(//g" -e "s/).*//g" -e "s/\.//g" )
        kover=$( grep -w "$kext" "$ScriptTmpPath"/daemon_overview | sed -e "s/.*-//g" -e "s/+.*//g" )

        if [[ $kstat != "" ]]; then
            if [[ "$kover" -gt "$kstat" ]]; then
                touch "$ScriptTmpPath"/daemon_notify
            fi
        fi
    done < "$ScriptTmpPath"/daemon_overview

    if [ -f "$ScriptTmpPath"/daemon_notify ]; then
        kuroot=$( _helpDefaultRead "KU Root" )
        ../bin/KUNotifier.app/Contents/MacOS/KUNotifier -message "$daemonnotify" -title "KU MenuBar"
        rm "$ScriptTmpPath"/daemon_*
    fi
    exit 0
}

###################################################################
################## Kext Updater Menu Bar App ######################
###################################################################
function kumenubar_on()
{

    ku_root=$( _helpDefaultRead "KU Root" )
    ku_root=$( echo "$ku_root" |sed 's/\//\\\//g')
    
    if [ ! -d "$HOME"/Library/LaunchAgents ]; then
        mkdir "$HOME"/Library/LaunchAgents
    fi
    
    cp ../bin/slsoft.de.KUMenuBar.plist "$HOME"/Library/LaunchAgents/.
    
    sed -ib "s/CHANGE_ME/$ku_root/g" "$HOME"/Library/LaunchAgents/slsoft.de.KUMenuBar.plist
    
    rm "$HOME"/Library/LaunchAgents/slsoft.de.KUMenuBar.plistb
    
    launchctl load -w "$HOME"/Library/LaunchAgents/slsoft.de.KUMenuBar.plist

}

function kumenubar_off()
{ launchctl unload -w "$HOME"/Library/LaunchAgents/slsoft.de.KUMenuBar.plist
    rm "$HOME"/Library/LaunchAgents/slsoft.de.KUMenuBar.plist
    pkill KUMenuBar
    pkill -f kumenubar
}

###################################################################
################ Copy Atheros40 Kext to /L/E ######################
###################################################################
function ar92xx()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    kuroot=$( _helpDefaultRead "KU Root" )
    rwcheck=$( _helpDefaultRead "RW" )

    _languageselect

    echo "$atherosinstall"

    if [[ "$OS" = "10" ]]; then
        if [[ $rwcheck = "No" ]]; then
            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    fi
        
    if [[ "$OS" = "10" ]]; then
        if [[ $keychain = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "cp -r '"'$kuroot'"'/Kext\\ Updater.app/Contents/Resources/kexts/IO80211Family.kext /Library/Extensions/.; rm -rf /Library/Extensions/AirPortAtheros40.kext; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "cp -r '"'$kuroot'"'/Kext\\ Updater.app/Contents/Resources/kexts/IO80211Family.kext /Library/Extensions/.; rm -rf /Library/Extensions/AirPortAtheros40.kext; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" with administrator privileges' >/dev/null 2>&1
        fi
            
    else  ### 11.x
        if [[ $keychain = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "cp -r '"'$kuroot'"'/Kext\\ Updater.app/Contents/Resources/kexts/IO80211Family.kext '"$ScriptTmpPath2"'/mount/Library/Extensions/.; rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/AirPortAtheros40.kext; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i /; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "cp -r '"'$kuroot'"'/Kext\\ Updater.app/Contents/Resources/kexts/IO80211Family.kext '"$ScriptTmpPath2"'/mount/Library/Extensions/.; rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/AirPortAtheros40.kext; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i '"$ScriptTmpPath2"'/mount; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" with administrator privileges' >/dev/null 2>&1
        fi
    fi

    if [ $? = 0 ]; then
            if [[ $checkchime = "1" ]]; then
                _playchime
            fi
        echo -e "\n$alldone"
        else
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo -e "\n$error"
    fi
}

###################################################################
################ Remove Atheros40 Kext from /L/E ##################
###################################################################
function ar92xx_remove()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    kuroot=$( _helpDefaultRead "KU Root" )
    rwcheck=$( _helpDefaultRead "RW" )

    _languageselect

    echo "$atherosuninstall"

    if [[ "$OS" = "10" ]]; then
        if [[ $rwcheck = "No" ]]; then
            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    fi



    if [[ "$OS" = "10" ]]; then
        if [[ $keychain = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "rm -rf /Library/Extensions/AirPortAtheros40.kext; rm -rf /Library/Extensions/IO80211Family.kext; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
            osascript -e 'do shell script "rm -rf /Library/Extensions/AirPortAtheros40.kext; rm -rf /Library/Extensions/IO80211Family.kext; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" with administrator privileges' >/dev/null 2>&1
            fi
            
    else  ### 11.x
        if [[ $keychain = "1" ]]; then
             _getsecret
            osascript -e 'do shell script "rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/AirPortAtheros40.kext; rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/IO80211Family.kext; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i '"$ScriptTmpPath2"'/mount; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
            osascript -e 'do shell script "rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/AirPortAtheros40.kext; rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/IO80211Family.kext; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i '"$ScriptTmpPath2"'/mount; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" with administrator privileges' >/dev/null 2>&1
            fi
    fi

    
    if [ $? = 0 ]; then
            if [[ $checkchime = "1" ]]; then
                _playchime
            fi
        echo -e "\n$alldone"
        else
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo -e "\n$error"
    fi
}

###################################################################
############## Check if Atheros40 already installed ###############
###################################################################

function checkatheros40()
{
    if [[ -d /Library/Extensions/AirPortAtheros40.kext ]] & [[ -d /Library/Extensions/IO80211Family.kext ]]; then
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Atheros40" -bool YES
    else
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Atheros40" -bool NO
    fi
}

###################################################################
############### Copy DisableGFXHDA Kext to /L/E ###################
###################################################################
function disablegfxhda()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    kuroot=$( _helpDefaultRead "KU Root" )
    rwcheck=$( _helpDefaultRead "RW" )

    _languageselect

    echo "$disablegfxhda_install"

    if [[ "$OS" = "10" ]]; then
        if [[ "$rwcheck" = "No" ]]; then
            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    fi

    /usr/bin/rsync -r /System/Library/Extensions/AppleGFXHDA.kext/ "$ScriptTmpPath"/DisableGFXHDA.kext/
    rm -rf "$ScriptTmpPath"/DisableGFXHDA.kext/Contents/PlugIns
    cp -f "$kuroot"/Kext\ Updater.app/Contents/Resources/bin/AppleGFXHDA "$ScriptTmpPath"/DisableGFXHDA.kext/Contents/MacOS/.

    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 999.99" "$ScriptTmpPath"/DisableGFXHDA.kext/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 999.99" "$ScriptTmpPath"/DisableGFXHDA.kext/Contents/Info.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 999.99" "$ScriptTmpPath"/DisableGFXHDA.kext/Contents/version.plist
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 999.99" "$ScriptTmpPath"/DisableGFXHDA.kext/Contents/version.plist

    if [[ "$OS" = "10" ]]; then
        if [[ $keychain = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "cp -r '"'$ScriptTmpPath'"'/DisableGFXHDA.kext /Library/Extensions/.; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "cp -r '"'$ScriptTmpPath'"'/DisableGFXHDA.kext /Library/Extensions/.; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" with administrator privileges' >/dev/null 2>&1
        fi
    else
        if [[ $keychain = "1" ]]; then
             _getsecret
            osascript -e 'do shell script "cp -r '"'$ScriptTmpPath'"'/DisableGFXHDA.kext '"$ScriptTmpPath2"'/mount/Library/Extensions/.; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i '"$ScriptTmpPath2"'/mount; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "cp -r '"'$ScriptTmpPath'"'/DisableGFXHDA.kext '"$ScriptTmpPath2"'/mount/Library/Extensions/.; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i '"$ScriptTmpPath2"'/mount; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" with administrator privileges' >/dev/null 2>&1
        fi
    fi
      
    if [ $? = 0 ]; then
            if [[ $checkchime = "1" ]]; then
                _playchime
            fi
        echo -e "\n$alldone"
        else
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo -e "\n$error"
    fi
}

###################################################################
############### Remove DisableGFXHDA Kext from /L/E ###############
###################################################################
function disablegfxhda_remove()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    kuroot=$( _helpDefaultRead "KU Root" )
    rwcheck=$( _helpDefaultRead "RW" )

    _languageselect

    echo "$disablegfxhda_uninstall"

    if [[ "$OS" = "10" ]]; then
        if [[ "$rwcheck" = "No" ]]; then
            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    fi


    if [[ "$OS" = "10" ]]; then
        if [[ $keychain = "1" ]]; then
        _getsecret
        osascript -e 'do shell script "rm -rf /Library/Extensions/DisableGFXHDA.kext; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
        osascript -e 'do shell script "rm -rf /Library/Extensions/DisableGFXHDA.kext; sudo chmod -R 755 /Library/Extensions/*; sudo chown -R root:wheel /Library/Extensions/*; sudo touch /Library/Extensions; sudo kextcache -i /; sudo touch /Library/Extensions; sudo kextcache -u / -v 6" with administrator privileges' >/dev/null 2>&1
        fi
    else
        if [[ $keychain = "1" ]]; then
        _getsecret
        osascript -e 'do shell script "rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/DisableGFXHDA.kext; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i '"$ScriptTmpPath2"'/mount; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
        osascript -e 'do shell script "rm -rf '"$ScriptTmpPath2"'/mount/Library/Extensions/DisableGFXHDA.kext; sudo chmod -R 755 '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo chown -R root:wheel '"$ScriptTmpPath2"'/mount/Library/Extensions/*; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -i '"$ScriptTmpPath2"'/mount; sudo touch '"$ScriptTmpPath2"'/mount/Library/Extensions; sudo kextcache -u '"$ScriptTmpPath2"'/mount -v 6" with administrator privileges' >/dev/null 2>&1
        fi
    fi

    if [ $? = 0 ]; then
        if [[ $checkchime = "1" ]]; then
            _playchime
        fi
        echo -e "\n$alldone"
    else
        if [[ $checkchime = "1" ]]; then
            _playchimedeath
        fi
        echo -e "\n$error"
    fi
}

###################################################################
############# Check if DisableGFXHDA already installed ############
###################################################################

function checkdisablegfxhda()
{
    if [[ -d /Library/Extensions/DisableGFXHDA.kext ]]; then
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "DisableGFXHDA" -bool YES
    else
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "DisableGFXHDA" -bool NO
    fi
}

###################################################################
########################## Fix Sleepimage  ########################
###################################################################

function fixsleepimage()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    #pwcheck=$( pmset -g |grep proximitywake )
    rwcheck=$( _helpDefaultRead "RW" )
    img_full_path=$( pmset -g | grep hibernatefile | sed 's/.*file//g' | xargs )
    img_path=$( echo "$img_full_path" | sed 's/\/sleepimage//g' )
    _languageselect

    echo "$keychain"

    echo "$fixsleepimage"

    if [[ "$OS" = "10" ]]; then
        if [[ "$rwcheck" = "No" ]]; then
            if [[ "$keychain" = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    fi
    
    
        if [[ "$OS" = "10" ]]; then
        if [[ "$keychain" = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "pmset -a hibernatemode 0; pmset -a proximitywake 0; pmset -a ttyskeepawake 0; pmset -a tcpkeepalive 0; cd '"$img_path"'; sudo rm sleepimage; sudo touch sleepimage; sudo chflags uchg sleepimage" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
              osascript -e 'do shell script "pmset -a hibernatemode 0; pmset -a proximitywake 0; pmset -a ttyskeepawake 0; pmset -a tcpkeepalive; cd '"$img_path"'; sudo rm sleepimage; sudo touch sleepimage; sudo chflags uchg sleepimage" with administrator privileges' >/dev/null 2>&1
        fi
    else
        if [[ $keychain = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "pmset -a hibernatemode 0; pmset -a proximitywake 0; pmset -a ttyskeepawake 0; pmset -a tcpkeepalive; cd '"$ScriptTmpPath2"'/mount'"$img_path"'; sudo rm sleepimage; sudo touch sleepimage; sudo chflags uchg sleepimage" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "pmset -a hibernatemode 0; pmset -a proximitywake 0; pmset -a ttyskeepawake 0; pmset -a tcpkeepalive; cd '"$ScriptTmpPath2"'/mount/var/vm; sudo rm sleepimage; sudo touch sleepimage; sudo chflags uchg sleepimage" with administrator privileges' >/dev/null 2>&1
        fi
    fi

    if [ $? = 0 ]; then
            if [[ $checkchime = "1" ]]; then
                _playchime
            fi
        echo -e "\n$alldone"
        else
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo -e "\n$error"
    fi
}

###################################################################
####################### Fix Sleepimage undo #######################
###################################################################

function fixsleepimage_undo()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    #pwcheck=$( pmset -g |grep proximitywake )
    rwcheck=$( _helpDefaultRead "RW" )

    _languageselect
    
    echo "$fixsleepimage"

    if [[ "$OS" = "10" ]]; then
        if [[ "$rwcheck" = "No" ]]; then
            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
    fi

    if [[ "$OS" = "10" ]]; then
        if [[ $keychain = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "pmset -a hibernatemode 3; pmset -a proximitywake 1; cd /private/var/vm/; sudo chflags nouchg sleepimage; sudo rm -f sleepimage" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "pmset -a hibernatemode 3; pmset -a proximitywake 1; cd /private/var/vm/; sudo chflags nouchg sleepimage; sudo rm -f sleepimage" with administrator privileges' >/dev/null 2>&1
        fi
    else
        if [[ $keychain = "1" ]]; then
            _getsecret
            osascript -e 'do shell script "pmset -a hibernatemode 3; pmset -a proximitywake 1; cd '"$ScriptTmpPath2"'/mount/var/vm/; sudo chflags nouchg sleepimage; sudo rm -f sleepimage" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
        else
            osascript -e 'do shell script "pmset -a hibernatemode 3; pmset -a proximitywake 1; cd '"$ScriptTmpPath2"'/mount/var/vm/; sudo chflags nouchg sleepimage; sudo rm -f sleepimage" with administrator privileges' >/dev/null 2>&1
        fi
    fi
    if [ $? = 0 ]; then
            if [[ $checkchime = "1" ]]; then
                _playchime
            fi
        echo -e "\n$alldone"
        else
            if [[ $checkchime = "1" ]]; then
                _playchimedeath
            fi
        echo -e "\n$error"
    fi
}

###################################################################
############### Check if Sleepfix already applied #################
###################################################################

function checksleepfix()
{
    img_full_path=$( pmset -g | grep hibernatefile | sed 's/.*file//g' | xargs )
    chmodcheck=$( stat -f %A "$img_full_path" )
    chowncheck=$( ls -l "$img_full_path" |cut -c 15-25 )
    size=$( stat -f%z "$img_full_path" )
    hmcheck=$( pmset -g |grep hibernatemode | sed "s/.*e//g" | xargs )
    pwcheck=$( pmset -g |grep proximitywake )

    if [[ $chmodcheck = "644" ]]; then
        chmodcheck="0"
        else
        chmodcheck="1"
    fi

    if [ $size = 0 ]; then
        size="0"
        else
        size="1"
    fi

    if [[ $chowncheck = "root  wheel" ]]; then
        chowncheck="0"
        else
        chowncheck="1"
    fi

    if [[ $pwcheck != "" ]]; then
    pwcheck=$( pmset -g |grep proximitywake | sed "s/.*e//g" | xargs )
        if [[ $pwcheck = "0" ]]; then
            pwcheck="0"
        else
            pwcheck="1"
        fi
    else
    pwcheck="0"
    fi

    result=$( echo $chmodcheck+$size+$hmcheck+$chowncheck+$pwcheck | bc ) #If value is 0 the fix was already applied

    if [ $result = 0 ]; then
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Sleepfix" -bool YES
    else
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Sleepfix" -bool NO
    fi
}

###################################################################
############### Sets systempartition to read/write ################
###################################################################

function _get_node()
{

    if [[ "$OS" = "10" ]]; then
        check_rw=$( mount | grep "on / (" )
        if [[ "$check_rw" = *"read-only"* ]]; then
            _helpDefaultWrite "RW" "No"
        else
            _helpDefaultWrite "RW" "Yes"
        fi
        
    else

        NodeId2=$( mount | grep ".mu_temp/mount" )
        if [[ "$NodeId2" != "" ]]; then
            _helpDefaultWrite "RW" "Yes"
            NodeId=$( mount | grep "on / (" )
            NodeId=$( echo "$NodeId" | sed 's/on \/.*//g' | rev | cut -c 4- | rev )
            _helpDefaultWrite "NodeId" "$NodeId"
            exit
        fi

        NodeId=$( mount | grep "on / (" )
        NodeId=$( echo "$NodeId" | sed 's/on \/.*//g' | rev | cut -c 4- | rev )

        _helpDefaultWrite "RW" "No"
        _helpDefaultWrite "NodeId" "$NodeId"
    fi
}

function set_read_write()
{
    keychain=$( _helpDefaultRead "Keychain" )
    user=$( _helpDefaultRead "Rootuser" )
    
    if [[ "$OS" = "10" ]]; then
        check_rw=$( mount | grep "on / (" )
        if [[ "$check_rw" = *"read-only"* ]]; then
            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -rw /" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -rw /" with administrator privileges' >/dev/null 2>&1
            fi
        fi
        check_rw=$( mount | grep "on / (" )
        if [[ "$check_rw" != *"read-only"* ]]; then
            _helpDefaultWrite "RW" "Yes"
        else
            _helpDefaultWrite "RW" "No"
        fi
    
    else
    
        _get_node
        check_rw=$( mount | grep ".mu_temp/mount" )
        NodeId=$( _helpDefaultRead "NodeId" )
        volume_name=$( diskutil info "$NodeId" | grep "Volume Name" | sed 's/.*://g' | xargs )
        if [[ "$check_rw" = "" ]]; then
            if [ ! -d "$ScriptTmpPath2" ]; then
                mkdir "$ScriptTmpPath2"
                mkdir "$ScriptTmpPath2"/mount
            fi

            if [[ $keychain = "1" ]]; then
                _getsecret
                osascript -e 'do shell script "sudo mount -o nobrowse -t apfs '"$NodeId"' '"$ScriptTmpPath2"'/mount" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
            else
                osascript -e 'do shell script "sudo mount -o nobrowse -t apfs '"$NodeId"' '"$ScriptTmpPath2"'/mount" with administrator privileges' >/dev/null 2>&1
            fi
            ln -s "$ScriptTmpPath2"/mount "$HOME"/Desktop/"$volume_name"-rw
            check_rw=$( mount | grep ".mu_temp/mount" )
            if [[ "$check_rw" != "" ]]; then
                _helpDefaultWrite "RW" "Yes"
            else
                _helpDefaultWrite "RW" "No"
            fi
        fi
    fi
}



###################################################################
############### Show all loaded 3rd Party Kexts ###################
###################################################################

function thirdparty()
{
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    ../bin/./BDMESG | grep -w kext | sed -e "s/.*EFI/EFI/g" -e "s/(.*//g" -e "s/\\\/\//g" > "$ScriptTmpPath/kextpaths"
    system_profiler -detailLevel mini SPExtensionsDataType -xml | grep -w kext | sed -e "s/.*<string>//g" -e "s/<.*//g" >> "$ScriptTmpPath/kextpaths"
    kextstat=$( kextstat |grep -v apple |sed "s/\ (.*//g" | rev | cut -d '.' -f1 | rev | tail -n +2 )

    _languageselect

    echo -e "$thirdparty\n"

    while IFS='' read -r line || [[ -n "$line" ]]; do
    check=$( grep "$line" "$ScriptTmpPath/kextpaths" )
        if [[ $check = "" ]];then
          echo "$line"
          else
          echo "$check"
        fi
    done <<< "$kextstat"

    if [[ $checkchime = "1" ]]; then
      _playchime
    fi

    echo -e "\n$alldone"
}

###################################################################
############### Show all loaded 3rd Party Kexts II ################
###################################################################

function all_thirdparty()
{
    kextstat |grep -v apple |sed -e 's/.*\ \ //g' -e s'/).*/)/g' |grep -v "Name (Version)"

    if [[ $checkchime = "1" ]]; then
      _playchime
    fi

    echo -e "\n$alldone"
}


###################################################################
#################### Create HTML Systemreport #####################
###################################################################

function htmlreport()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )
    content=$( /usr/libexec/PlistBuddy -c Print "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" )
    lan2=$( echo -e "$content" | grep "Language" | sed "s/.*\=\ //g" | xargs )
    kuroot2=$( _helpDefaultRead "KU Root" )
    bootloader2=$( _helpDefaultRead "Bootloaderversion" )
    cloverconfig=$( _helpDefaultRead "Cloverconfig" )
    osversionnumber=$( sw_vers | grep ProductVersion | cut -d':' -f2 | cut -c 1-6 | xargs )

    _languageselect

    if [[ $keychain = "1" ]]; then
    _getsecret
    fi

    echo -e "$collectingdata"

    ### EFI Check and mount ###
    checkefi=$( _helpDefaultRead "Mounted" )
    if [[ $checkefi = "No" ]]; then
      devnode=$( _helpDefaultRead "Device Node" )
      if [[ $keychain = "1" ]]; then
        osascript -e 'do shell script "diskutil mount '$devnode'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
      else
        osascript -e 'do shell script "diskutil mount '$devnode'" with administrator privileges' >/dev/null 2>&1
      fi
        if [[ $? = "0" ]]; then
          tempmnt="Yes"
        fi
    fi
    volumename=$( _helpDefaultRead "EFI Name" )
    usedbootloader=$( _helpDefaultRead "Bootloader" )

    if [[ $usedbootloader = Clover* ]]; then
      efikind="CLOVER"
    fi

    if [[ $usedbootloader = "Ozmosis" ]]; then
      efikind="Ozmosis"
    fi

    if [[ $usedbootloader = "OpenCore" ]]; then
      efikind="OpenCore"
    fi

    #### Check which Bootloader is used ####
    if [[ $efikind = "CLOVER" ]]; then
      mkdir "$ScriptTmpPath"/Report "$ScriptTmpPath"/Report/CLOVER >/dev/null 2>&1
      cp -r /Volumes/"$volumename"/EFI/CLOVER/ACPI /Volumes/"$volumename"/EFI/CLOVER/drivers* /Volumes/"$volumename"/EFI/CLOVER/kexts /Volumes/"$volumename"/EFI/CLOVER/"$cloverconfig" "$ScriptTmpPath"/Report/CLOVER/.

      /usr/libexec/PlistBuddy -c "set SMBIOS:SerialNumber 000000000000" "$ScriptTmpPath"/Report/CLOVER/"$cloverconfig"
      /usr/libexec/PlistBuddy -c "set SMBIOS:BoardSerialNumber 0000000000000" "$ScriptTmpPath"/Report/CLOVER/"$cloverconfig"
      /usr/libexec/PlistBuddy -c "set SMBIOS:SmUUID 00000000-0000-0000-0000" "$ScriptTmpPath"/Report/CLOVER/"$cloverconfig"
      /usr/libexec/PlistBuddy -c "set RtVariables:MLB 0000000000000" "$ScriptTmpPath"/Report/CLOVER/"$cloverconfig"
      /usr/libexec/PlistBuddy -c "set SystemParameters:CustomUUID 00000000-0000-0000-0000-000000000000" "$ScriptTmpPath"/Report/CLOVER/"$cloverconfig"
    fi

    if [[ $efikind = "Ozmosis" ]]; then
      mkdir "$ScriptTmpPath"/Report "$ScriptTmpPath"/Report/Ozmosis >/dev/null 2>&1
      efipathoz=$( find /Volumes/EFI -name "*efaults.plist" |sed -e "s/defaul.*//g" -e "s/Defaul.*//g" |grep -v "Trashes" |head -n 1 )
      cp -r "$efipathoz"Acpi "$efipathoz"Darwin "$efipathoz"Theme.bin* "$efipathoz"*efaults.plist "$ScriptTmpPath"/Report/Ozmosis/. >/dev/null 2>&1

      ozserial=$( grep -A1 'SystemSerial' "$efipathoz"*efaults.plist|grep -v "SystemSerial" | xargs | sed -e "s/<string>//g" -e "s/<\/string>//g" )

      ozbaseboardserial=$( grep -A1 'BaseBoardSerial' "$efipathoz"*efaults.plist |grep -v "BaseBoardSerial" | xargs | sed -e "s/<string>//g" -e "s/<\/string>//g" )

      sed -ib "s/$ozserial/000000000000/g" "$ScriptTmpPath"/Report/Ozmosis/Defaults.plist
      sed -ib "s/$ozbaseboardserial/00000000000000000/g" "$ScriptTmpPath"/Report/Ozmosis/Defaults.plist
      rm "$ScriptTmpPath"/Report/Ozmosis/Defaults.plistb
    fi

    if [[ $efikind = "OpenCore" ]]; then
      mkdir "$ScriptTmpPath"/Report "$ScriptTmpPath"/Report/OpenCore >/dev/null 2>&1
      cp -r /Volumes/"$volumename"/EFI/OC/ACPI /Volumes/"$volumename"/EFI/OC/Drivers /Volumes/"$volumename"/EFI/OC/Kexts /Volumes/"$volumename"/EFI/OC/config.plist /Volumes/"$volumename"/EFI/OC/OpenCore.efi "$ScriptTmpPath"/Report/OpenCore/.

      /usr/libexec/PlistBuddy -c "set PlatformInfo:SMBIOS:SystemSerialNumber 000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:SMBIOS:BoardSerialNumber 00000000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:SMBIOS:SystemUUID 00000000-0000-0000-0000-000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:Generic:MLB 0000000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:Generic:SystemSerialNumber 000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:Generic:SystemUUID 00000000-0000-0000-0000-000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:PlatformNVRAM:MLB 0000000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:PlatformNVRAM:ROM 000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:SMBIOS:ChassisSerialNumber 000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:DataHub:SystemSerialNumber 000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist
      /usr/libexec/PlistBuddy -c "set PlatformInfo:DataHub:SystemUUID 00000000-0000-0000-0000-000000000000" "$ScriptTmpPath"/Report/OpenCore/config.plist

    fi

    ### Fetching General Data ###
    date=$( date )
    swbuild=$( sw_vers |tail -n1 | sed "s/.*://g" | xargs )
    swversion=$( sw_vers |tail -n2 | head -n 1 | sed "s/.*://g" | xargs )
    hwspecs=$( system_profiler SPHardwareDataType SPDisplaysDataType )

    sipcheck1=$( csrutil status | grep "Kext Signing" | sed "s/.*\://g" | xargs )
    sipcheck2=$( csrutil status | grep "System Integrity Protection status" | sed -e "s/.*\://g" -e "s/\ (.*//g" -e "s/\.//g" | xargs )
    if [[ $sipcheck1 = "disabled" ]]; then
    sipcheck="disabled"
    elif [[ $sipcheck2 = "disabled" ]]; then
    sipcheck="disabled"
    fi

    kextstats=$( kextstat | grep -v com.apple | sort )
    ../bin/./BDMESG | grep -w kext | sed -e "s/.*EFI/EFI/g" -e "s/(.*//g" -e "s/\\\/\//g" | sort > "$ScriptTmpPath/kextpaths"
    system_profiler -detailLevel mini SPExtensionsDataType -xml | grep  kext | sed -e "s/.*<string>//g" -e "s/<.*//g" | grep -v Contents | sort >> "$ScriptTmpPath/kextpaths"
    kextstat |grep -v apple |sed "s/\ (.*//g" | rev | cut -d '.' -f1 | rev | tail -n +2 | sort > "$ScriptTmpPath"/kextstat

    ### Table "General" ###
    modelname=$( echo -e "$hwspecs" | grep "Model Name:" | sed "s/.*://g" | xargs )
    modelid=$( echo -e "$hwspecs" | grep "Model Identifier:" | sed "s/.*://g" | xargs )
    cpuname=$( sysctl -a | grep cpu.brand_ | sed "s/.*://g" | xargs )
    cores=$( echo -e "$hwspecs" | grep "Total Number of Cores:" | sed "s/.*://g" | xargs )
    memory=$( echo -e "$hwspecs" | grep "Memory:" | sed "s/.*://g" | xargs )
    gfx=$( echo -e "$hwspecs" | grep "Chipset Model:" | sed -e "s/.*:\ //g" -e "s/\//xtempx/g"  -e "1 s/.*/&<br>/g" |xargs )

    kextstat | grep AppleHDA\ \( > /dev/null
    if [ $? = 0 ]; then
        applehda="is loaded"
        else
        applehda="is not loaded"
    fi

    ### Table "Hackintosh Kexts" ###
    if [ -f "$ScriptTmpPath"/kextreport ]; then
        rm "$ScriptTmpPath"/kextreport
    fi
    for kextList in "${kextArray[@]}"
    do
    IFS=","
    data=($kextList)
    name=${data[0]}
    lecho=$( echo -e "$kextstats" |grep -w ${data[1]} | sed -e "s/.*(//g" -e "s/).*//g" )
    local=$( echo $lecho | sed -e "s/\.//g" )
        if ! [[ $local = "" ]]; then
          echo -e "<tr><th\>""${data[2]}""<\/th>""<th\>""$lecho""<\/th>""<\/tr>" >> "$ScriptTmpPath"/kextreport
        fi
    done

    ### Table "All loaded Non-Apple Kexts" ###
    if [ -f "$ScriptTmpPath"/kextreport2 ]; then
    rm "$ScriptTmpPath"/kextreport2
    fi
    while IFS='' read -r line; do
    check=$( grep "$line" "$ScriptTmpPath/kextpaths" )
        if [[ $check = "" ]];then
          kextpath=$( echo '<img src="https://update.kextupdater.de/kextupdater/images/unsure.png" height="17"></img>' )
          kextname=$( echo -e "$line"  | head -n 1 | sed -e "s@.*/@@" -e "s/.kext//g" )
          echo -e "<tr><th\>""$kextname""<\/th>""<th\>""$kextpath""<\/th>""<\/tr>" >> "$ScriptTmpPath"/kextreport2
        else
          kextpath=$( echo -e "$check" | head -n 1 | sed "s/\/[^\/]*$//" )
          kextname=$( echo -e "$check" | head -n 1 | sed -e "s@.*/@@" -e "s/.kext//g" )
          echo -e "<tr><th\>""$kextname""<\/th>""<th\>""$kextpath""<\/th>""<\/tr>" >> "$ScriptTmpPath"/kextreport2
        fi
    done < "$ScriptTmpPath"/kextstat

    ../bin/./dspci | sed -E 's/\[([A-Za-z ]+)\]/(\1)/g' | grep -v ignored |sed -e "s/\[GeForce/(GeForce/g" -e "s/\[AMD/(AMD/g" -e "s/\[Radeon/(Radeon/g" > "$ScriptTmpPath"/pci
    while IFS='' read -r line; do
    vendor=`echo -e "$line" | cut -d "[" -f3 | cut -d "]" -f1 | tr '[:lower:]' '[:upper:]' | sed 's/:.*//g'`
    device=`echo -e "$line" | cut -d "[" -f3 | cut -d "]" -f1 | tr '[:lower:]' '[:upper:]' | sed 's/.*://g'`
    subven=`echo -e "$line" | cut -d "(" -f3 | cut -d ")" -f1 | tr '[:lower:]' '[:upper:]' | sed -e 's/.*\ //g' -e 's/:.*//g'`
    subdev=`echo -e "$line" | cut -d "(" -f3 | cut -d ")" -f1 | tr '[:lower:]' '[:upper:]' | sed -e 's/.*\ //g' -e 's/.*://g'`
    deviceinfo=`echo -e "$line" | sed -e 's/.*]:\ //g' -e 's/\[.*//g'`
        if [[ $subven = "" ]]; then
          subven="0000"
        fi
        if [[ $subdev = "" ]]; then
          subdev="0000"
        fi
    echo -e "<tr><td>""$vendor""</td>""<td>""$device""</td>""<td>""$subven""</td>""<td>""$subdev""</td>""<td>""$deviceinfo""</td></tr>" | sed -e "s/:/\\\:/g" -e 's#/#\\/#g' | tr '\n' ' ' >> "$ScriptTmpPath"/pci2
    done < "$ScriptTmpPath"/pci

    powervars=`pmset -g | tail -n +3`
    while IFS='' read -r line; do
    powername=`echo -e "$line" | cut -c 1-22 | xargs`
    powervalue=`echo -e "$line" | cut -c 23-999 | xargs`
    echo -e "<tr><th>""$powername""</th>""<th>""$powervalue""</th>""</tr>" | sed -e 's#/#\\/#g'>> "$ScriptTmpPath"/powerm
    done <<< "$powervars"

    echo "$createreport"

    ### Merging HTML Report ###
    lspci=$( cat "$ScriptTmpPath/pci2" | tr '\n' ' ' | sed "s/]/)/g")

    power=$( cat "$ScriptTmpPath/powerm" | tr '\n' ' ' )
    hackkexts=$( cat "$ScriptTmpPath"/kextreport | tr '\n' ' ' )
    nonapplekexts=$( cat "$ScriptTmpPath"/kextreport2 | tr '\n' ' ' | tr '\/' '§' )
        if [ -f /System/Library/LaunchDaemons/Niresh* ]; then
          dis="dt"
          else
          dis=""
        fi

    sed -e "s/!DATE!/$date/g" -e "s/!SWVERSION!/$swversion/g" -e "s/!SWBUILD!/$swbuild/g"  -e "s/!MODELNAME!/$modelname/g" -e "s/!MODELID!/$modelid/g" -e "s/!CPUNAME!/$cpuname/g" -e "s/!CORES!/$cores/g" -e "s/!MEMORY!/$memory/g" -e "s/!GFX!/$gfx/g" -e "s/!APPLEHDA!/$applehda/g" -e "s/!BOOTLOADER!/$bootloader2/g" -e "s/!HACKKEXTS!/$hackkexts/g" -e "s/!NONAPPLEKEXTS!/$nonapplekexts/g" -e "s/!DIS!/$dis/g" -e "s/!LSPCI!/$lspci/g" -e "s/!POWER!/$power/g" ../html/report.html > "$ScriptTmpPath"/report2.html

    cat "$ScriptTmpPath"/report2.html |sed -e "s/xtempx/\//g" |tr '§' '\/' > "$ScriptTmpPath"/Report/Report.html

    ### If OpenCore is used it is not possible to locate path of the injected Kexts. Damn! )-:=
    if [[ $efikind = "OpenCore" ]]; then
      sed -ib '/Non-Apple/,13d' "$ScriptTmpPath"/Report/Report.html
      rm "$ScriptTmpPath"/Report/Report.htmlb
    fi
    ### End

    path=$( echo "$PWD" )

    cd "$ScriptTmpPath"/Report

    zip -rq ~/Desktop/Systemreport.zip *

    echo -e "$reportdone\n"

    cd "$path"

    open "$ScriptTmpPath"/Report/Report.html

    rm "$ScriptTmpPath"/pci2 "$ScriptTmpPath"/powerm "$ScriptTmpPath"/kextreport "$ScriptTmpPath"/kextreport2 "$ScriptTmpPath"/kextpaths "$ScriptTmpPath"/kextstat "$ScriptTmpPath"/pci "$ScriptTmpPath"/report2.html >/dev/null 2>&1

    if [[ $keychain = "1" ]]; then
      osascript -e 'do shell script "kextunload /tmp/DirektHW.kext; sudo rm -rf /tmp/DirektHW.kext" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
    else
       osascript -e 'do shell script "kextunload /tmp/DirektHW.kext; sudo rm -rf /tmp/DirektHW.kext" with administrator privileges' >/dev/null 2>&1
    fi

    if [[ $tempmnt = "Yes" ]];then

    if [[ $keychain = "1" ]]; then
      osascript -e 'do shell script "diskutil unmount '$devnode'" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
      tempmnt=""
    else
      osascript -e 'do shell script "diskutil unmount '$devnode'" with administrator privileges' >/dev/null 2>&1
      tempmnt=""
    fi
    fi
}

###################################################################
########################## EFI Backup #############################
###################################################################

function efi_backup()
{
 
    initial

    speakervolume=$( _helpDefaultRead "Speakervolume" | sed "s/\,.*//g" )
    speakervolume=$( echo 0."$speakervolume" )

    backup_path=$( _helpDefaultRead "Backuppath" )

    efi_backup_running="1"

    echo -e "$efi_backup_start\n"

    efi_root=$( _helpDefaultRead "EFI Root" )
    efi_mounted=$( diskutil info "$efi_root" | grep "Mounted:" | sed 's/.*://g' | xargs )
    ScriptDownloadPath=$( _helpDefaultRead "Downloadpath" )
    AppPath=$( _helpDefaultRead "KU Root" )
    MountPoint=$( _helpDefaultRead "Mount Point" )
    
    if [ ! -d "$backup_path" ]; then
        mkdir "$backup_path"
    fi
    
    if [[ "$efi_mounted" != "Yes" ]]; then
        mountefi
        efi_root=$( _helpDefaultRead "EFI Root" )
        efi_mounted=$( diskutil info "$efi_root" | grep "Mounted:" | sed 's/.*://g' | xargs )
    fi
    
    if [[ "$efi_mounted" = "Yes" ]]; then
        efi_path=$( _helpDefaultRead "EFI Path" )
        lower_case=$( _helpDefaultRead "EFIBackupNameLower" )
        backup_date=$( date +"%Y.%m.%d" )
        backup_time=$( date +"%H-%M-%S" )
        MountPoint=$( _helpDefaultRead "Mount Point" )
        bl_details=$( _helpDefaultRead "Bootloaderversion" |sed -e "s/).*/)/g" -e "s/\ //g" -e "s/)//g" -e "s/(/-/g" -e "s/\.//g" -e "s/UEFIr//g" -e "s/Legacyr//g" -e "s/Legacyr//g" -e "s/-//g" )
        #bl_details=$( echo "$bl_details" | sed 's/\ /_/g' )
        smbios=$( system_profiler SPHardwareDataType SPDisplaysDataType | grep "Model Identifier:" | sed "s/.*://g" | xargs )
        computername=$( scutil --get ComputerName )
        check_custom=$( _helpDefaultRead "EFIBackupCustom" )
        custom_name=$( _helpDefaultRead "EFIBackupNameCustom" )
        custom_name=$( echo "$custom_name" | sed -e "s/%Date%/$backup_date/g" -e "s/%Time%/$backup_time/g" -e "s/%Bootloader%/$bl_details/g" -e "s/%SMBios%/$smbios/g" -e "s/%Computername%/$computername/g" )
          
        
        if [[ "$lower_case" = "1" ]]; then
            custom_name=$( echo "$custom_name" | tr '[:upper:]' '[:lower:]' )
        fi
        
        cd "$MountPoint"
        
        if [[ $check_custom = "0" ]]; then
            zip -rq "$backup_path"/EFI_Backup_"$backup_date"_"$backup_time".zip "EFI"
            done=$(echo "$backup_path"/EFI_Backup_"$backup_date"_"$backup_time".zip )
        else
            zip -rq "$backup_path"/"$custom_name".zip "EFI"
            done=$(echo "$backup_path"/"$custom_name".zip )
        fi
        
        if [[ "$?" = "0" ]]; then
            cd "$AppPath"/Kext\ Updater.app/Contents/Resources/script
            echo -e "$efi_backup_done\n"
            echo -e "$efi_backup_result\n\n""$done"
            if [[ $checkchime = "1" ]]; then
                afplay -v "$speakervolume" "$AppPath"/Kext\ Updater.app/Contents/Resources/sounds/done.mp3 &
            fi
        else
            cd "$AppPath"/Kext\ Updater.app/Contents/Resources/script
            echo -e "$efi_backup_error\n"
            if [[ $checkchime = "1" ]]; then
                afplay -v "$speakervolume" "$AppPath"/Kext\ Updater.app/Contents/Resources/sounds/error.aif &
            fi
        fi
    fi
    
    exit 0
    
}

###################################################################
########################## Gatekeeper #############################
###################################################################

function check_gatekeeper()
{
    Gatekeeper=$( spctl --status )
    
    if [[ "$Gatekeeper" = *"enabled"* ]]; then
        _helpDefaultWrite "Gatekeeper" "Yes"
    else
        _helpDefaultWrite "Gatekeeper" "No"
    fi
}

function disable_gatekeeper()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )

    if [[ $keychain = "1" ]]; then
      _getsecret
      osascript -e 'do shell script "sudo spctl --master-disable" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
    else
      osascript -e 'do shell script "sudo spctl --master-disable" with administrator privileges' >/dev/null 2>&1
    fi
}

function enable_gatekeeper()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )

    if [[ $keychain = "1" ]]; then
      _getsecret
      osascript -e 'do shell script "sudo spctl --master-enable" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
    else
      osascript -e 'do shell script "sudo spctl --master-enable" with administrator privileges' >/dev/null 2>&1
    fi
}

###################################################################
##################### Check OpenCore Config #######################
###################################################################

function check_opencore_conf()
{
    _languageselect
    ocversion=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version |sed -e "s/.*REL/REL/g" -e "s/REL-//g" -e "s/.*DBG/DBG/g" -e "s/DBG-//g" -e "s/-.*//g" )
    ocbootpath=$( nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:boot-path | sed -e s/".*GPT,//g" -e "s/.*MBR,//g" -e "s/,.*//g" | xargs )
      if [[ $ocversion = "" ]] || [[ $ocbootpath = "" ]]; then
        _helpDefaultWrite "OcError" "Yes"
        check_silicon=$( _helpDefaultRead "AppleSilicon" )
        if [ "$check_silicon" = "0" ]; then
            echo -e "$ocerror"
        fi
        exit 0
      fi
}

###################################################################
#################### Create basic EFI folder ######################
###################################################################

function _efi_folder_creator()
{
    
    _languageselect

    efi_creator=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "EFI Creator" )
    
    efi_name="EFI"
    
    if [[ "$efi_creator" != "None" ]]; then
    
        if [[ "$efi_creator" = "Clover" ]]; then
            folder="clovercreator"
            kext_target="CLOVER/kexts/Other"
        elif [[ "$efi_creator" = "Clover Nightly" ]]; then
            folder="clovernightlycreator"
            kext_target="CLOVER/kexts/Other"
        elif [[ "$efi_creator" = "OpenCore" ]]; then
            folder="opencorecreator"
            kext_target="OC/Kexts"
        elif [[ "$efi_creator" = "OpenCore Nightly" ]]; then
            folder="opencorenightlycreator"
            kext_target="OC/Kexts"
        elif [[ "$efi_creator" = "OpenCore Nightly (N-D-K Fork)" ]]; then
            folder="opencorenightly-ndkcreator"
            kext_target="OC/Kexts"
        elif [[ "$efi_creator" = "OpenCore (N-D-K Fork)" ]]; then
            folder="opencore-ndkcreator"
            kext_target="OC/Kexts"
        fi

        echo "Bootloader: $efi_creator"
        echo " "
        echo "$creating_efi"
        echo " "
        
        if [[ ! -d "${ScriptDownloadPath}" ]]; then
            mkdir "${ScriptDownloadPath}"
        fi
        
        curl -k -sS -o ${ScriptTmpPath}/EFI.zip https://$url/${folder}/EFI.zip
        unzip -o -q ${ScriptTmpPath}/EFI.zip -d "${ScriptDownloadPath}"/EFI
        #../bin/./7za x ${ScriptTmpPath}/EFI.7z -o${ScriptDownloadPath}/EFI -aoa > /dev/null

        while read -r line; do
            if [[ "$line" = "ACPIBatteryManager" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Release/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "AppleBacklightFixup" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Release/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
                cp -r ${ScriptDownloadPath}/$line/*.aml ${ScriptDownloadPath}/${name}/CLOVER/ACPI/patched/.
            elif [[ "$line" = "ATH9KFixup" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Release/*.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "BrcmPatchRam" ]]; then
                _PRINT_MSG "$efi_manual_1 $line $efi_manual_2\n"
            elif [[ "$line" = "CodecCommander" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Release/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "FakePCIID" ]]; then
                _PRINT_MSG "$efi_manual_1 $line $efi_manual_2\n"
            elif [[ "$line" = "GenericUSBXHCI" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Universal/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "IntelBluetoothFirmware" ]]; then
                 _PRINT_MSG "$efi_manual_1 $line $efi_manual_2\n"
            elif [[ "$line" = "MacProMemoryNotificationDisabler" ]]; then
                 _PRINT_MSG "$efi_manual_1 $line $efi_manual_2\n"
            elif [[ "$line" = "NullEthernet" ]]; then
                _PRINT_MSG "$efi_manual_1 $line $efi_manual_2\n"
            elif [[ "$line" = "RealtekRTL8111" ]]; then
                cp -r ${ScriptDownloadPath}/$line/$line-*/Vers*/Release/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "Sinetekrtsx" ]]; then
                cp -r ${ScriptDownloadPath}/$line/*.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "SmallTreeIntel82576" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Extensions/*.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "SMCAMDProcessor" ]]; then
                _PRINT_MSG "$efi_manual_1 $line $efi_manual_2\n"
            elif [[ "$line" = "USBInjectAll" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Release/*.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "VirtualSMC" ]]; then
                _PRINT_MSG "$efi_manual_1 $line $efi_manual_2\n"
            elif [[ "$line" = "VoodooPS2" ]]; then
                cp -r ${ScriptDownloadPath}/$line/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "VoodooSMBus" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Voodoo*/kext/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            elif [[ "$line" = "VoodooTSCSync" ]]; then
                cp -r ${ScriptDownloadPath}/$line/Release/*.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            else
                cp -r ${ScriptDownloadPath}/$line/$line.kext ${ScriptDownloadPath}/${efi_name}/$kext_target/.
            fi
        done < "${ScriptTmpPath}"/eficreator

    defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "EFI Creator" "None"

    fi
}

function _online_check()
{

    onlinecheck=$( curl -k -s -S https://update.kextupdater.de/online )
    if [[ $onlinecheck != "1" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Networkerror" "Yes"
        exit
    else
        defaults write "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "Networkerror" "No"
    fi
}

function _offline_efi()
{
    offline_efi="yes"
    mainscript
}

function _custom_efi()
{
    custom_efi="yes"
    mainscript
}

function _check_oc_config()
{

    oc_file=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "OCConfigFile" )
    oc_nightly=$( defaults read "${ScriptHome}/Library/Preferences/kextupdater.slsoft.de.plist" "OCNightlyConfig" )
    
    if [[ "$oc_nightly" != "1" ]]; then
        #curl -k -sS -o ${ScriptTmpPath}/ConfigValidity.7z https://update.kextupdater.de/opencore/ConfigValidity.7z
        curl -k -sS -o ${ScriptTmpPath}/ConfigValidity.zip https://update.kextupdater.de/opencore/ConfigValidity.zip
    else
        #curl -k -sS -o ${ScriptTmpPath}/ConfigValidity.7z https://update.kextupdater.de/opencorenightly/ConfigValidity.7z
        curl -k -sS -o ${ScriptTmpPath}/ConfigValidity.zip https://update.kextupdater.de/opencorenightly/ConfigValidity.zip
    fi
    
    #../bin/./7za x ${ScriptTmpPath}/ConfigValidity.7z -o${ScriptTmpPath} > /dev/null
    unzip -qo ${ScriptTmpPath}/ConfigValidity.zip -d ${ScriptTmpPath}
    
    
    ${ScriptTmpPath}/./ConfigValidity "$oc_file"
    if [[ $checkchime = "1" ]]; then
        _playchime
    fi
}

function bug_report()
{

    ../bin/./BDMESG > "$ScriptTmpPath"/bdmesg.txt

}

function stop_execution()
{

    pkill -f script.command

}

####################################################
################# 11.x + Area ######################
####################################################

function _apply_reboot()
{
    user=$( _helpDefaultRead "Rootuser" )
    keychain=$( _helpDefaultRead "Keychain" )

    NodeId=$( _helpDefaultRead "NodeId" )
    volume_name=$( diskutil info "$NodeId" | grep "Volume Name" | sed 's/.*://g' | xargs )
    rm "$HOME"/Desktop/"$volume_name"-rw

    if [[ $keychain = "1" ]]; then
      _getsecret
      osascript -e 'do shell script "sudo bless --folder '"$ScriptTmpPath2"'/mount/System/Library/CoreServices --bootefi --create-snapshot; shutdown -r now" user name "'"$user"'" password "'"$passw"'" with administrator privileges' >/dev/null 2>&1
    else
      osascript -e 'do shell script "sudo bless --folder '"$ScriptTmpPath2"'/mount/System/Library/CoreServices --bootefi --create-snapshot; shutdown -r now" with administrator privileges' >/dev/null 2>&1
    fi

}

function _check_authroot()
{
    AuthRoot=$( csrutil authenticated-root status )
    
    if [[ "$AuthRoot" = *"enabled"* ]]; then
        _helpDefaultWrite "AuthRoot" "Yes"
    else
        _helpDefaultWrite "AuthRoot" "No"
    fi
}

function _oc_config_compare()
{
    
    curl -k https://codeload.github.com/corpnewt/OCConfigCompare/zip/refs/heads/master -o "$ScriptTmpPath"/master.zip
    cd "$ScriptTmpPath"
    unzip -q master.zip
    mv *master OCConfigCompare
   
   
    echo "#!/bin/bash" > $ScriptTmpPath/occonfigcompare.sh
    echo "osascript -e 'tell app \"Terminal\"" >> $ScriptTmpPath/occonfigcompare.sh
    if [ -f /usr/bin/python ]; then
        echo "do script \"cd \\\"'$ScriptTmpPath'/OCConfigCompare\\\"; python OCConfigCompare.py\"" |sed -e 's/\/\//\//g' -e "s/'//g" >> $ScriptTmpPath/occonfigcompare.sh
    else
        echo "do script \"cd \\\"'$ScriptTmpPath'/OCConfigCompare\\\"; python3 OCConfigCompare.py\"" |sed -e 's/\/\//\//g' -e "s/'//g" >> $ScriptTmpPath/occonfigcompare.sh
    fi
    echo "end tell'" >> $ScriptTmpPath/occonfigcompare.sh
    echo "osascript -e  'activate application \"Terminal\"'" >> $ScriptTmpPath/occonfigcompare.sh
    bash $ScriptTmpPath/occonfigcompare.sh
}


$1
exit 0


