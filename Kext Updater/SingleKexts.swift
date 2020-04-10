//
//  SingleKexts.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class SingleKexts: NSViewController {

    @IBOutlet weak var start_button: NSButton!
    @IBOutlet weak var select_all_button: NSButton!
    @IBOutlet weak var deselect_all_button: NSButton!
    @IBOutlet weak var deselect_excluded_button: NSButton!
    @IBOutlet weak var close_button: NSButton!
    @IBOutlet weak var group_select_pulldown: NSPopUpButton!
    @IBOutlet weak var webview_button: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("dl-"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    @IBAction func group_select(_ sender: Any) {
        self.group_select_pulldown.item(withTitle: "  ")?.isHidden=true
        let group_choice = (sender as AnyObject).selectedCell()!.tag
        if group_choice == 1 {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.hasPrefix("dl-"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            //UserDefaults.standard.set(true, forKey: "dl-fakesmc")
            UserDefaults.standard.set(true, forKey: "dl-voodoops2")
            UserDefaults.standard.set(true, forKey: "dl-virtualsmc")
        } else if group_choice == 2 {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.hasPrefix("dl-"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            UserDefaults.standard.set(true, forKey: "dl-applealc")
            UserDefaults.standard.set(true, forKey: "dl-lilu")
            UserDefaults.standard.set(true, forKey: "dl-codeccommander")
        } else if group_choice == 3 {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.hasPrefix("dl-"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            UserDefaults.standard.set(true, forKey: "dl-lilu")
            UserDefaults.standard.set(true, forKey: "dl-whatevergreen")
        } else if group_choice == 4 {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.hasPrefix("dl-"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            UserDefaults.standard.set(true, forKey: "dl-intelmausi")
            UserDefaults.standard.set(true, forKey: "dl-realtekrtl8111")
            UserDefaults.standard.set(true, forKey: "dl-atherose2200ethernet")
            UserDefaults.standard.set(true, forKey: "dl-airportbrcmfixup")
            UserDefaults.standard.set(true, forKey: "dl-atheroswifiinjector")
        }
    
    }

    @IBAction func efi_creator_pulldown(_ sender: Any) {
        let bootloader_kind = (sender as AnyObject).selectedCell()!.tag
        
        if bootloader_kind == 1 {
        UserDefaults.standard.set("OpenCore", forKey: "EFI Creator")
        } else if bootloader_kind == 2 {
        UserDefaults.standard.set("OpenCore Nightly", forKey: "EFI Creator")
        } else if bootloader_kind == 3 {
        UserDefaults.standard.set("Clover", forKey: "EFI Creator")
        } else if bootloader_kind == 4 {
        UserDefaults.standard.set("Clover Nightly", forKey: "EFI Creator")
        }else if bootloader_kind == 0 {
        UserDefaults.standard.set("None", forKey: "EFI Creator")
        }else if bootloader_kind == 5 {
        UserDefaults.standard.set("OpenCore Nightly (NDK Fork)", forKey: "EFI Creator")
        }else if bootloader_kind == 6 {
        UserDefaults.standard.set("OpenCore (NDK Fork)", forKey: "EFI Creator")
        }
    }
    
    
    @IBAction func send_start (sender: NSButton) {
        //UserDefaults.standard.set("None", forKey: "EFI Creator")
        UserDefaults.standard.set("Single", forKey: "Choice")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Startbutton"), object: nil, userInfo: ["name" : self.start_button?.stringValue as Any])
        self.view.window?.close()
    }
    
    @IBAction func close(_ sender: Any) {
        self.view.window?.close()
        UserDefaults.standard.set(false, forKey: "DoDownload")
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("dl-"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    @IBAction func select_all(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "dl-acpibatterymanager")
        UserDefaults.standard.set(true, forKey: "dl-airportbrcmfixup")
        UserDefaults.standard.set(true, forKey: "dl-applealc")
        UserDefaults.standard.set(true, forKey: "dl-applebacklightfixup")
        UserDefaults.standard.set(true, forKey: "dl-asussmc")
        UserDefaults.standard.set(true, forKey: "dl-ath9kfixup")
        UserDefaults.standard.set(true, forKey: "dl-atherose2200ethernet")
        UserDefaults.standard.set(true, forKey: "dl-atheroswifiinjector")
        UserDefaults.standard.set(true, forKey: "dl-brcmpatchram")
        UserDefaults.standard.set(true, forKey: "dl-bt4lecontinuityfixup")
        UserDefaults.standard.set(true, forKey: "dl-codeccommander")
        UserDefaults.standard.set(true, forKey: "dl-cpufriend")
        UserDefaults.standard.set(true, forKey: "dl-enablelidwake")
        UserDefaults.standard.set(true, forKey: "dl-fakepciid")
        UserDefaults.standard.set(true, forKey: "dl-fakesmc")
        UserDefaults.standard.set(true, forKey: "dl-genericusbxhci")
        UserDefaults.standard.set(true, forKey: "dl-hibernationfixup")
        UserDefaults.standard.set(true, forKey: "dl-intelbluetoothfirmware")
        UserDefaults.standard.set(true, forKey: "dl-intelmausi")
        UserDefaults.standard.set(true, forKey: "dl-intelmausiethernet")
        UserDefaults.standard.set(true, forKey: "dl-lilu")
        UserDefaults.standard.set(true, forKey: "dl-lilufriend")
        UserDefaults.standard.set(true, forKey: "dl-macpromnd")
        UserDefaults.standard.set(true, forKey: "dl-nightshiftunlocker")
        UserDefaults.standard.set(true, forKey: "dl-notouchid")
        UserDefaults.standard.set(true, forKey: "dl-novpajpeg")
        UserDefaults.standard.set(true, forKey: "dl-nullcpupowermanagement")
        UserDefaults.standard.set(true, forKey: "dl-nullethernet")
        UserDefaults.standard.set(true, forKey: "dl-nvmefix")
        UserDefaults.standard.set(true, forKey: "dl-realtekrtl8111")
        UserDefaults.standard.set(true, forKey: "dl-rtcmemoryfixup")
        UserDefaults.standard.set(true, forKey: "dl-sinetekrtsx")
        UserDefaults.standard.set(true, forKey: "dl-smalltreeintel82576")
        UserDefaults.standard.set(true, forKey: "dl-smcamdprocessor")
        UserDefaults.standard.set(true, forKey: "dl-systemprofilermemoryfixup")
        UserDefaults.standard.set(true, forKey: "dl-thunderboltreset")
        UserDefaults.standard.set(true, forKey: "dl-tscadjustreset")
        UserDefaults.standard.set(true, forKey: "dl-usbinjectall")
        UserDefaults.standard.set(true, forKey: "dl-virtualsmc")
        UserDefaults.standard.set(true, forKey: "dl-voodoohda")
        UserDefaults.standard.set(true, forKey: "dl-voodooi2c")
        UserDefaults.standard.set(true, forKey: "dl-voodooinput")
        UserDefaults.standard.set(true, forKey: "dl-voodoops2")
        UserDefaults.standard.set(true, forKey: "dl-voodoosmbus")
        UserDefaults.standard.set(true, forKey: "dl-voodoosdhc")
        UserDefaults.standard.set(true, forKey: "dl-voodootscsync")
        UserDefaults.standard.set(true, forKey: "dl-whatevergreen")
    }
    
    @IBAction func deselect_all(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "DoDownload")
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("dl-"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        group_select_pulldown.selectItem(at: 0)
    }

    @IBAction func deselect_excluded(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "DoDownload")
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("ex-"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        group_select_pulldown.selectItem(at: 0)
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
    @IBAction func bt4lecontinuityfixup(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/BT4LEContiunityFixup", forKey: "SourceURL")
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
    @IBAction func intelmausiethernet(_ sender: Any) {
        UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-intel-network/overview", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func lilu(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/acidanthera/Lilu", forKey: "SourceURL")
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
    @IBAction func nightshiftunlocker(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/0xFireWolf/NightShiftUnlocker", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func notouchid(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/al3xtjames/NoTouchID", forKey: "SourceURL")
        webview_button.performClick(nil)
    }
    @IBAction func novpajpeg(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/vulgo/NoVPAJpeg", forKey: "SourceURL")
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
    @IBAction func realtekrtl8111(_ sender: Any) {
        UserDefaults.standard.set("https://github.com/Mieze/RTL8111_driver_for_OS_X", forKey: "SourceURL")
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
    
}
