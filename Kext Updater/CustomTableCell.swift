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
        } else {
            UserDefaults.standard.removeObject(forKey: "ex-" + kext)
            
        }
    }
    
    //URL Section
    
    @IBAction func acpibatterymanager(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/RehabMan/OS-X-ACPI-Battery-Driver", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func airportbrcmfixup(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/AirportBrcmFixup", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func applealc(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/AppleALC", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func applebacklightsmoother(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/hieplpvip/AppleBacklightSmoother", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func asussmc(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/hieplpvip/AsusSMC", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func ath9kfixup(_ sender: Any) {
        UserDefaults.standard.set("https://bitbucket.org/RehabMan/ath9kfixup", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func atherose2200ethernet(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/Mieze/AtherosE2200Ethernet", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func atheroswifiinjector(_ sender: Any) {
        UserDefaults.standard.set("https://www.hackintosh-forum.de/forum/thread/22322-atheros-wifi-injector-kext", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func brcmpatchram(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/RehabMan/OS-X-BrcmPatchRAM", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func brightnesskeys(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/BrightnessKeys", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func codeccommander(_ sender: Any) {
        UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-eapd-codec-commander/overview", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func cpufriend(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/CPUFriend", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func cputscsync(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/lvs1974/CpuTscSync", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func fakepciid(_ sender: Any) {
        UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-fake-pci-id/overview", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func fakesmc(_ sender: Any) {
        UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-fakesmc-kozlek/overview", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func genericusbxhci(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Generic-USB3", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func hibernationfixup(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/HibernationFixup", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func intelbluetoothfirmware(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/zxystd/IntelBluetoothFirmware", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func intelmausi(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/IntelMausi", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func intelmausiwol(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/fischerscode/IntelMausi-WOL", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func intelmausiethernet(_ sender: Any) {
        UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-intel-network/overview", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func itlwm(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/zxystd/itlwm", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func lilu(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/Lilu", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func lucyrtl8125ethernet(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/Mieze/LucyRTL8125Ethernet", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func lilufriend(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/PMheart/LiluFriend", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func macpromnd(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/IOIIIO/MacProMemoryNotificationDisabler", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func notouchid(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/al3xtjames/NoTouchID", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func nullcpupowermanagement(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/corpnewt/NullCPUPowerManagement", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func nullethernet(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Null-Ethernet", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func nvmefix(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/NVMeFix", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func radeonboost(_ sender: Any) {
        UserDefaults.standard.set("https://www.hackintosh-forum.de/forum/thread/47791-radeonboost-kext-benchmark-scores-wie-am-echten-mac-unter-windows/", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func realtekrtl8111(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/Mieze/RTL8111_driver_for_OS_X", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func restrictevents(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/RestrictEvents", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func rtcmemoryfixup(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/RTCMemoryFixup", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func sinetekrtsx(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/sinetek/Sinetek-rtsx", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func smcamdprocessor(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/trulyspinach/SMCAMDProcessor", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func systemprofilermemoryfixup(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/Goldfish64/SystemProfilerMemoryFixup", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func thunderboltreset(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/osy86/ThunderboltReset", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func tscadjustreset(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/interferenc/TSCAdjustReset", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func usbinjectall(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/Sniki/OS-X-USB-Inject-All", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func virtualsmc(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/VirtualSMC", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func voodoohda(_ sender: Any) {
        UserDefaults.standard.set("https://sourceforge.net/projects/voodoohda", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func voodooinput(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/VoodooInput", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func voodooi2c(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/alexandred/VoodooI2C", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func voodoops2(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func voodoosdhc(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/OSXLatitude/EDP/tree/master/kextpacks/USB/VoodooSDHC", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func voodoosmbus(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/leo-labs/voodoosmbus", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func voodootscsync(_ sender: Any) {
        UserDefaults.standard.set("https://bitbucket.org/RehabMan/voodootscsync/overview", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func whatevergreen(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/WhateverGreen", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func opencore(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/OpenCorePkg", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func clover(_ sender: Any) {
        UserDefaults.standard.set("https://sourceforge.net/projects/cloverefiboot/files/", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
 
    @IBAction func yogasmc(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/zhen-zen/yogasmc", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    
    //@objc func cancel(_ sender: Any?) {
    //    self.view.window?.close()
    //}
    
}
