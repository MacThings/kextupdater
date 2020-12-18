//
//  ViewController.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    let kexts = [["name":"ACPIBatteryManager"],
                 ["name":"AirportBrcmFixup"],
                 ["name":"AppleALC"],
                 ["name":"AppleBacklightFixup"],
                 ["name":"AsusSMC"],
                 ["name":"ATH9KFixup"],
                 ["name":"AtherosE2200Ethernet"],
                 ["name":"AtherosWiFiInjector"],
                 ["name":"AzulPatcher4600"],
                 ["name":"BrcmPatchRam"],
                 ["name":"BrightnessKeys"],
                 ["name":"BT4LEContinuityFixup"],
                 ["name":"Clover"],
                 ["name":"CodecCommander"],
                 ["name":"CoreDisplayFixup"],
                 ["name":"CPUFriend"],
                 ["name":"CpuTscSync"],
                 ["name":"EFI-Driver"],
                 ["name":"EnableLidWake"],
                 ["name":"FakePCIID"],
                 ["name":"FakeSMC"],
                 ["name":"GenericUSBXHCI"],
                 ["name":"HibernationFixup"],
                 ["name":"IntelBluetootFirmware"],
                 ["name":"IntelGraphicsFixup"],
                 ["name":"IntelGraphicsDVMTFixup"],
                 ["name":"IntelMausi"],
                 ["name":"IntelMausi-WOL"],
                 ["name":"IntelMausiEthernet"],
                 ["name":"itlwm"],
                 ["name":"itlwmx"],
                 ["name":"Lilu"],
                 ["name":"LiluFriend"],
                 ["name":"LucyRTL8125Ethernet"],
                 ["name":"NightShiftUnlocker"],
                 ["name":"NoTouchID"],
                 ["name":"NoVPAJpeg"],
                 ["name":"NullCpuPowerManagement"],
                 ["name":"NullEthernet"],
                 ["name":"NvidiaGraphicsFixup"],
                 ["name":"NVMeFix"],
                 ["name":"OpenCore"],
                 ["name":"RealtekRTL8111"],
                 ["name":"RestrictEvents"],
                 ["name":"RTCMemoryFixup"],
                 ["name":"SMCAMDProcessor"],
                 ["name":"Shiki"],
                 ["name":"SinetekRTSX"],
                 ["name":"SystemProfilerMemoryFixup"],
                 ["name":"ThunderboltReset"],
                 ["name":"TSCAdjustReset"],
                 ["name":"USBInjectAll"],
                 ["name":"VirtualSMC"],
                 ["name":"VoodooHDA"],
                 ["name":"VoodooI2C"],
                 ["name":"VoodooInput"],
                 ["name":"VoodooPS2"],
                 ["name":"VoodooSDHC"],
                 ["name":"VoodooSMBus"],
                 ["name":"VoodooTSCSync"],
                 ["name":"WhateverGreen"],
                 ["name":"YogaSMC"]]

    func numberOfRows(in tableView: NSTableView) -> Int {
        return kexts.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let userCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "userCell"), owner: self) as? CustomTableCell else { return nil }

        userCell.KextNameLabel.stringValue = kexts[row]["name"] ?? "unknown user"
        
        return userCell
    }
    
    
}

