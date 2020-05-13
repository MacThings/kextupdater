//
//  Bootloader.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class Bootloader: NSViewController {

    @IBOutlet weak var close_button: NSButton!
    
    @IBOutlet weak var clover: NSPopUpButton!
    @IBOutlet weak var opencore: NSPopUpButton!
    @IBOutlet weak var please_choose_label: NSTextField!
    @IBOutlet weak var start_button: NSButton!
    @IBOutlet weak var bootloader_kind: NSPopUpButton!
    
    @IBOutlet weak var bootloader_empty: NSMenuItem!
    
    @IBOutlet weak var clover_empty_entry: NSMenuItem!
    @IBOutlet weak var opencore_empty_entry: NSMenuItem!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        let bootloaderchoice = UserDefaults.standard.bool(forKey: "Bootloader_remember_choice")
        if bootloaderchoice == true {
            let bootloaderchoice = UserDefaults.standard.string(forKey: "Bootloader_remember_bootloaderchoice")
            let bootloadertitle = UserDefaults.standard.string(forKey: "Bootloader_remember_title")
            UserDefaults.standard.set(bootloadertitle, forKey: "Bootloaderkind")
            if bootloaderchoice == "Clover" {
                self.bootloader_kind.selectItem(withTitle: bootloaderchoice!)
                
                if bootloadertitle != nil {
                    self.clover.selectItem(withTitle: bootloadertitle!)
                }

                let gettitle = UserDefaults.standard.string(forKey: "Bootloader_remember_title")
                UserDefaults.standard.set(gettitle, forKey: "Bootloader_remember_title")
                if gettitle == "Clover" {
                    UserDefaults.standard.set("Clover", forKey: "Bootloaderkind")
                } else if gettitle == "Clover Nightly" {
                    UserDefaults.standard.set("CloverNightly", forKey: "Bootloaderkind")
                } else if gettitle == "EFI Driver" {
                    UserDefaults.standard.set("EFIDriver", forKey: "Bootloaderkind")
                } else if gettitle == "EFI Driver Nightly" {
                    UserDefaults.standard.set("EFIDriverNightly", forKey: "Bootloaderkind")
                } else if gettitle == "OcQuirks Nightly" {
                    UserDefaults.standard.set("OcQuirksNightly", forKey: "Bootloaderkind")
                }
                
                self.clover_empty_entry.isHidden=true
                self.start_button.isEnabled=true
                self.clover.isHidden=false
                self.opencore.isHidden=true
                self.please_choose_label.isHidden=true
                self.bootloader_empty.isHidden=true
            } else if bootloaderchoice == "OpenCore" {
                self.bootloader_kind.selectItem(withTitle: bootloaderchoice!)
                
                if bootloadertitle != nil {
                    self.opencore.selectItem(withTitle: bootloadertitle!)
                }
                
                let gettitle = UserDefaults.standard.string(forKey: "Bootloader_remember_title")
                if gettitle == "OpenCore"{
                   UserDefaults.standard.set("OpenCore", forKey: "Bootloaderkind")
                } else if gettitle == "OpenCore (N-D-K Fork)" {
                    UserDefaults.standard.set("OpenCore-NDK", forKey: "Bootloaderkind")
                } else if gettitle == "AppleSupport" {
                    UserDefaults.standard.set("AppleSupport", forKey: "Bootloaderkind")
                } else if gettitle == "OcBinaryData" {
                    UserDefaults.standard.set("OcBinaryData", forKey: "Bootloaderkind")
                } else if gettitle == "AppleSupport Nightly" {
                    UserDefaults.standard.set("AppleSupportNightly", forKey: "Bootloaderkind")
                } else if gettitle == "OpenCore Nightly" {
                    UserDefaults.standard.set("OpenCoreNightly", forKey: "Bootloaderkind")
                } else if gettitle == "OpenCore Nightly (N-D-K Fork)" {
                    UserDefaults.standard.set("OpenCoreNightly-NDK", forKey: "Bootloaderkind")
                }
                
                self.opencore_empty_entry.isHidden=true
                self.start_button.isEnabled=true
                self.clover.isHidden=true
                self.opencore.isHidden=false
                self.please_choose_label.isHidden=true
                self.bootloader_empty.isHidden=true
            }
           
        }
    }
    
    @IBAction func close_button(_ sender: Any) {
        self.view.window?.close()
        UserDefaults.standard.set("1", forKey: "Choice")
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Bootloaderkind")
        defaults.synchronize()
    }
    
    @IBAction func bootloader_choice(_ sender: Any) {
        let bootloaderchoice = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(bootloaderchoice, forKey: "Bootloader_remember_bootloaderchoice")
        if bootloaderchoice == "Clover" {
            self.clover.isHidden=false
            self.opencore.isHidden=true
            self.please_choose_label.isHidden=true
            self.bootloader_empty.isHidden=true
            } else if bootloaderchoice == "OpenCore" {
            self.clover.isHidden=true
            self.opencore.isHidden=false
            self.please_choose_label.isHidden=true
            self.bootloader_empty.isHidden=true
            } else if bootloaderchoice != "" {
            self.clover.isHidden=true
            self.opencore.isHidden=true
            self.please_choose_label.isHidden=false
        }
    }
    
    @IBAction func opencore_choice(_ sender: Any) {
        self.opencore_empty_entry.isHidden=true
        self.start_button.isEnabled=true
        let gettitle = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(gettitle, forKey: "Bootloader_remember_title")
        if gettitle == "OpenCore"{
           UserDefaults.standard.set("OpenCore", forKey: "Bootloaderkind")
        } else if gettitle == "OpenCore (N-D-K Fork)" {
            UserDefaults.standard.set("OpenCore-NDK", forKey: "Bootloaderkind")
        } else if gettitle == "AppleSupport" {
            UserDefaults.standard.set("AppleSupport", forKey: "Bootloaderkind")
        } else if gettitle == "OcBinaryData" {
            UserDefaults.standard.set("OcBinaryData", forKey: "Bootloaderkind")
        } else if gettitle == "AppleSupport Nightly" {
            UserDefaults.standard.set("AppleSupportNightly", forKey: "Bootloaderkind")
        } else if gettitle == "OpenCore Nightly" {
            UserDefaults.standard.set("OpenCoreNightly", forKey: "Bootloaderkind")
        } else if gettitle == "OpenCore Nightly (N-D-K Fork)" {
            UserDefaults.standard.set("OpenCoreNightly-NDK", forKey: "Bootloaderkind")
        }
    }
    
    @IBAction func clover_choice(_ sender: Any) {
        self.clover_empty_entry.isHidden=true
        self.start_button.isEnabled=true
        let gettitle = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(gettitle, forKey: "Bootloader_remember_title")
        if gettitle == "Clover" {
            UserDefaults.standard.set("Clover", forKey: "Bootloaderkind")
        } else if gettitle == "Clover Nightly" {
            UserDefaults.standard.set("CloverNightly", forKey: "Bootloaderkind")
        } else if gettitle == "EFI Driver" {
            UserDefaults.standard.set("EFIDriver", forKey: "Bootloaderkind")
        } else if gettitle == "EFI Driver Nightly" {
            UserDefaults.standard.set("EFIDriverNightly", forKey: "Bootloaderkind")
        } else if gettitle == "OcQuirks Nightly" {
            UserDefaults.standard.set("OcQuirksNightly", forKey: "Bootloaderkind")
        } 
    }

    @IBAction func send_start(_ sender: Any) {
        UserDefaults.standard.set("Bootloader", forKey: "Choice")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Startbutton"), object: nil, userInfo: ["name" : self.start_button.stringValue as Any])
        self.view.window?.close()
    }

    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}
