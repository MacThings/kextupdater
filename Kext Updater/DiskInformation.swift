//
//  DiskInformation.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class DiskInformation: NSViewController {
    
    @IBOutlet weak var diskwindowmountpoint: NSTextField!
    @IBOutlet weak var diskwindowuuid: NSTextField!
    @IBOutlet weak var diskwindowdevicelocation: NSTextField!
    @IBOutlet weak var diskwindowremovablemedia: NSTextField!
    @IBOutlet weak var diskwindowprotocol: NSTextField!
    @IBOutlet weak var diskwindowsolidstate: NSTextField!
    @IBOutlet weak var diskwindowdrivemodel: NSTextField!
    @IBOutlet weak var imagessd: NSImageView!
    @IBOutlet weak var imagehd: NSImageView!
    @IBOutlet weak var imageusbstick: NSImageView!
    @IBOutlet weak var imageusbhd: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let uuid = UserDefaults.standard.string(forKey: "EFI Root")
        let devicenode = UserDefaults.standard.string(forKey: "Device Node")?.prefix(10).replacingOccurrences(of: "/dev/", with: "").replacingOccurrences(of: "d", with: "D")
        let location = UserDefaults.standard.string(forKey: "Device Location")
        let removable = UserDefaults.standard.string(forKey: "Removable Media")
        let deviceprotocol = UserDefaults.standard.string(forKey: "Device Protocol")
        let solid = UserDefaults.standard.string(forKey: "Solid State")
        let model = UserDefaults.standard.string(forKey: "Drive Model")
        diskwindowuuid.stringValue = (uuid ?? "")
        diskwindowmountpoint.stringValue = String((devicenode ?? ""))
        diskwindowdevicelocation.stringValue = (location ?? "")
        diskwindowremovablemedia.stringValue = (removable ?? "")
        diskwindowprotocol.stringValue = (deviceprotocol ?? "")
        diskwindowsolidstate.stringValue = (solid ?? "")
        diskwindowdrivemodel.stringValue = (model ?? "")
        if deviceprotocol == "SATA"{
            if solid == "Yes"{
                imagessd.isHidden = false
            } else {
                imagehd.isHidden = false
            }
        }
        if deviceprotocol == "USB"{
            if removable == "Software-Activated"{
                imageusbstick.isHidden = false
            } else {
                imageusbhd.isHidden = false
            }
        }
        //diskwindow.setIsVisible(true)
    }
        
    }
    

