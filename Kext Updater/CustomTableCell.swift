//
//  CustomTableCell.swift
//  View Based Table Example
//
//  Created by Scott Lougheed on 2020/02/26.
//  Copyright © 2020 Scott Lougheed. All rights reserved.
//

import Cocoa

class CustomTableCell: NSTableCellView {
    
    @IBOutlet weak var KextNameLabel: NSTextField!
    
    @IBOutlet weak var download_box: NSButtonCell!
    @IBOutlet weak var exclude_box: NSButton!
    @IBOutlet weak var webview_button: NSButton!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.

    }
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.openWebView),
            name: NSNotification.Name(rawValue: "OpenWebView"),
            object: nil)
    }
    
    @objc private func openWebView(notification: NSNotification){
        webview_button.performClick(nil)
    }
    
    @IBAction func emailButton(_ sender: Any) {
        let link = KextNameLabel.stringValue
        print(link)
    }
    
    @IBAction func download(_ sender: Any) {
        let kext = KextNameLabel.stringValue

        if download_box.state == NSControl.StateValue.on {
            UserDefaults.standard.set(true, forKey: "dl-" + kext.lowercased())
        } else {
            UserDefaults.standard.removeObject(forKey: "dl-" + kext.lowercased())
            
        }
    }
    
    @IBAction func exclude(_ sender: Any) {
        let kext = KextNameLabel.stringValue

        if exclude_box.state == NSControl.StateValue.on {
            UserDefaults.standard.set(true, forKey: "ex-" + kext)
        } else {
            UserDefaults.standard.removeObject(forKey: "ex-" + kext)
            
        }
    }

    @IBAction func webview(_ sender: Any) {
        let kext = KextNameLabel.stringValue.lowercased()
  
        if kext == "acpibatterymanager" {
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-ACPI-Battery-Driver", forKey: "SourceURL")
        } else if kext == "airportbrcmfixup" {
            UserDefaults.standard.set("https://github.com/acidanthera/AirportBrcmFixup", forKey: "SourceURL")
        } else if kext == "applealc" {
            UserDefaults.standard.set("https://github.com/acidanthera/AppleALC", forKey: "SourceURL")
        } else if kext == "applebacklightsmoother" {
            UserDefaults.standard.set("https://github.com/hieplpvip/AppleBacklightSmoother", forKey: "SourceURL")
        } else if kext == "asussmc" {
            UserDefaults.standard.set("https://github.com/hieplpvip/AsusSMC", forKey: "SourceURL")
        } else if kext == "ath9kfixup" {
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/ath9kfixup", forKey: "SourceURL")
        } else if kext == "atherose2200ethernet" {
            UserDefaults.standard.set("https://github.com/Mieze/AtherosE2200Ethernet", forKey: "SourceURL")
        } else if kext == "atheroswifiinjector" {
            UserDefaults.standard.set("https://www.hackintosh-forum.de/forum/thread/22322-atheros-wifi-injector-kext", forKey: "SourceURL")
        } else if kext == "brcmpatchram" {
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-BrcmPatchRAM", forKey: "SourceURL")
        } else if kext == "brightnesskeys" {
            UserDefaults.standard.set("https://github.com/acidanthera/BrightnessKeys", forKey: "SourceURL")
        } else if kext == "codeccommander" {
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-eapd-codec-commander/overview", forKey: "SourceURL")
        } else if kext == "cpufriend" {
            UserDefaults.standard.set("https://github.com/acidanthera/CPUFriend", forKey: "SourceURL")
        } else if kext == "cputscsync" {
            UserDefaults.standard.set("https://github.com/lvs1974/CpuTscSync", forKey: "SourceURL")
        } else if kext == "fakepciid" {
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-fake-pci-id/overview", forKey: "SourceURL")
        } else if kext == "fakesmc" {
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-fakesmc-kozlek/overview", forKey: "SourceURL")
        } else if kext == "genericusbxhci" {
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Generic-USB3", forKey: "SourceURL")
        } else if kext == "hibernationfixup" {
            UserDefaults.standard.set("https://github.com/acidanthera/HibernationFixup", forKey: "SourceURL")
        } else if kext == "intelbluetoothfirmware" {
            UserDefaults.standard.set("https://github.com/zxystd/IntelBluetoothFirmware", forKey: "SourceURL")
        } else if kext == "intelmausi" {
            UserDefaults.standard.set("https://github.com/acidanthera/IntelMausi", forKey: "SourceURL")
        } else if kext == "intelmausiwol" {
            UserDefaults.standard.set("https://github.com/fischerscode/IntelMausi-WOL", forKey: "SourceURL")
        } else if kext == "intelmausiethernet" {
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-intel-network/overview", forKey: "SourceURL")
        } else if kext == "itlwm" {
            UserDefaults.standard.set("https://github.com/zxystd/itlwm", forKey: "SourceURL")
        } else if kext == "lilu" {
            UserDefaults.standard.set("https://github.com/acidanthera/Lilu", forKey: "SourceURL")
        } else if kext == "lucyrtl8125ethernet" {
            UserDefaults.standard.set("https://github.com/Mieze/LucyRTL8125Ethernet", forKey: "SourceURL")
        } else if kext == "lilufriend" {
            UserDefaults.standard.set("https://github.com/PMheart/LiluFriend", forKey: "SourceURL")
        } else if kext == "macpromnd" {
            UserDefaults.standard.set("https://github.com/IOIIIO/MacProMemoryNotificationDisabler", forKey: "SourceURL")
        } else if kext == "notouchid" {
            UserDefaults.standard.set("https://github.com/al3xtjames/NoTouchID", forKey: "SourceURL")
        } else if kext == "nullcpupowermanagement" {
            UserDefaults.standard.set("https://github.com/corpnewt/NullCPUPowerManagement", forKey: "SourceURL")
        } else if kext == "nullethernet" {
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Null-Ethernet", forKey: "SourceURL")
        } else if kext == "nvmefix" {
            UserDefaults.standard.set("https://github.com/acidanthera/NVMeFix", forKey: "SourceURL")
        } else if kext == "radeonboost" {
            UserDefaults.standard.set("https://www.hackintosh-forum.de/forum/thread/47791-radeonboost-kext-benchmark-scores-wie-am-echten-mac-unter-windows/", forKey: "SourceURL")
        } else if kext == "realtekrtl8111" {
            UserDefaults.standard.set("https://github.com/Mieze/RTL8111_driver_for_OS_X", forKey: "SourceURL")
        } else if kext == "restrictevents" {
            UserDefaults.standard.set("https://github.com/acidanthera/RestrictEvents", forKey: "SourceURL")
        } else if kext == "rtcmemoryfixup" {
            UserDefaults.standard.set("https://github.com/acidanthera/RTCMemoryFixup", forKey: "SourceURL")
        } else if kext == "sinetekrtsx" {
            UserDefaults.standard.set("https://github.com/sinetek/Sinetek-rtsx", forKey: "SourceURL")
        } else if kext == "smcamdprocessor" {
            UserDefaults.standard.set("https://github.com/trulyspinach/SMCAMDProcessor", forKey: "SourceURL")
        } else if kext == "systemprofilermemoryfixup" {
            UserDefaults.standard.set("https://github.com/Goldfish64/SystemProfilerMemoryFixup", forKey: "SourceURL")
        } else if kext == "thunderboltreset" {
            UserDefaults.standard.set("https://github.com/osy86/ThunderboltReset", forKey: "SourceURL")
        } else if kext == "tscadjustreset" {
            UserDefaults.standard.set("https://github.com/interferenc/TSCAdjustReset", forKey: "SourceURL")
        } else if kext == "usbinjectall" {
            UserDefaults.standard.set("https://github.com/Sniki/OS-X-USB-Inject-All", forKey: "SourceURL")
        } else if kext == "virtualsmc" {
            UserDefaults.standard.set("https://github.com/acidanthera/VirtualSMC", forKey: "SourceURL")
        } else if kext == "voodoohda" {
            UserDefaults.standard.set("https://sourceforge.net/projects/voodoohda", forKey: "SourceURL")
        } else if kext == "voodooinput" {
            UserDefaults.standard.set("https://github.com/acidanthera/VoodooInput", forKey: "SourceURL")
        } else if kext == "voodooi2c" {
            UserDefaults.standard.set("https://github.com/alexandred/VoodooI2C", forKey: "SourceURL")
        } else if kext == "voodoops2" {
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller", forKey: "SourceURL")
        } else if kext == "voodoosdhc" {
            UserDefaults.standard.set("https://github.com/OSXLatitude/EDP/tree/master/kextpacks/USB/VoodooSDHC", forKey: "SourceURL")
        } else if kext == "voodoosmbus" {
            UserDefaults.standard.set("https://github.com/leo-labs/voodoosmbus", forKey: "SourceURL")
        } else if kext == "voodootscsync" {
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/voodootscsync/overview", forKey: "SourceURL")
        } else if kext == "whatevergreen" {
            UserDefaults.standard.set("https://github.com/acidanthera/WhateverGreen", forKey: "SourceURL")
        } else if kext == "opencore" {
            UserDefaults.standard.set("https://github.com/acidanthera/OpenCorePkg", forKey: "SourceURL")
        } else if kext == "clover" {
            UserDefaults.standard.set("https://sourceforge.net/projects/cloverefiboot/files/", forKey: "SourceURL")
        } else if kext == "yogasmc" {
            UserDefaults.standard.set("https://github.com/zhen-zen/yogasmc", forKey: "SourceURL")
        }

        webview_button.performClick(nil)

        
    }
    

    
    
    
    //@objc func cancel(_ sender: Any?) {
    //    self.view.window?.close()
    //}
    
}
