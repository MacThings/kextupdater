//
//  Hint.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class ScanPolicyCalculator: NSViewController {
    
    @IBOutlet weak var close_window: NSButton!
    @IBOutlet weak var result: NSTextField!
    
    @IBOutlet weak var to_clipboard_button: NSButton!
    
    @IBOutlet weak var OC_SCAN_FILE_SYSTEM_LOCK: NSButton!
    @IBOutlet weak var OC_SCAN_DEVICE_LOCK: NSButton!
    
    @IBOutlet weak var OC_SCAN_ALLOW_FS_APFS: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_FS_HFS: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_FS_ESP: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_FS_NTFS: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_FS_LINUX_ROOT: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_FS_LINUX_DATA: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_FS_XBOOTLDR: NSButton!
    
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_SATA: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_SASEX: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_SCSI: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_NVME: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_ATAPI: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_USB: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_FIREWIRE: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_SDCARD: NSButton!
    @IBOutlet weak var OC_SCAN_ALLOW_DEVICE_PCI: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    }

    @IBAction func calculate(_ sender: Any) {
        var result = 0
        if OC_SCAN_FILE_SYSTEM_LOCK.state == .on {
            result += 1
        }
        if OC_SCAN_DEVICE_LOCK.state == .on {
            result += 2
        }
        
        if OC_SCAN_ALLOW_FS_APFS.state == .on {
            result += 256
        }
        if OC_SCAN_ALLOW_FS_HFS.state == .on {
            result += 512
        }
        if OC_SCAN_ALLOW_FS_ESP.state == .on {
            result += 1024
        }
        if OC_SCAN_ALLOW_FS_NTFS.state == .on {
            result += 2048
        }
        if OC_SCAN_ALLOW_FS_LINUX_ROOT.state == .on {
            result += 4096
        }
        if OC_SCAN_ALLOW_FS_LINUX_DATA.state == .on {
            result += 8192
        }
        if OC_SCAN_ALLOW_FS_XBOOTLDR.state == .on {
            result += 16384
        }
        if OC_SCAN_ALLOW_DEVICE_SATA.state == .on {
            result += 65536
        }
        if OC_SCAN_ALLOW_DEVICE_SASEX.state == .on {
            result += 131072
        }
        if OC_SCAN_ALLOW_DEVICE_SCSI.state == .on {
            result += 262144
        }
        if OC_SCAN_ALLOW_DEVICE_NVME.state == .on {
            result += 524288
        }
        if OC_SCAN_ALLOW_DEVICE_ATAPI.state == .on {
            result += 1048576
        }
        if OC_SCAN_ALLOW_DEVICE_USB.state == .on {
            result += 2097152
        }
        if OC_SCAN_ALLOW_DEVICE_FIREWIRE.state == .on {
            result += 4194304
        }
        if OC_SCAN_ALLOW_DEVICE_SDCARD.state == .on {
            result += 8388608
        }
        if OC_SCAN_ALLOW_DEVICE_PCI.state == .on {
            result += 16777216
        }
        
        self.result.stringValue = String(result).replacingOccurrences(of: ".", with: "")
        self.to_clipboard_button.isEnabled = true
        
    }
    
    @IBAction func to_clipboard(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(self.result.stringValue.replacingOccurrences(of: ".", with: ""), forType: .string)
    }
    
    @IBAction func clear_all(_ sender: Any) {
        self.to_clipboard_button.isEnabled = false
        self.result.stringValue = ""
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("OC_"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    @IBAction func close_window(_ sender: Any) {
        self.view.window?.close()
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}



