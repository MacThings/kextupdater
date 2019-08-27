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
    
    @IBOutlet weak var bootloader_empty: NSMenuItem!
    
    @IBOutlet weak var clover_empty_entry: NSMenuItem!
    @IBOutlet weak var opencore_empty_entry: NSMenuItem!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
        if gettitle.contains("Bootloader") {
           UserDefaults.standard.set("OpenCore", forKey: "Bootloaderkind")
        } else if gettitle.contains("AppleSupport") {
            UserDefaults.standard.set("AppleSupport", forKey: "Bootloaderkind")
        }
    }
    
    @IBAction func clover_choice(_ sender: Any) {
        self.clover_empty_entry.isHidden=true
        self.start_button.isEnabled=true
        let gettitle = (sender as AnyObject).selectedCell()!.title
        if gettitle == "Bootloader" {
            UserDefaults.standard.set("Clover", forKey: "Bootloaderkind")
        } else if gettitle.contains("Nightly") {
            UserDefaults.standard.set("Clover Nightly Build", forKey: "Bootloaderkind")
        } else if gettitle.contains("EFI") {
            UserDefaults.standard.set("EFI Driver", forKey: "Bootloaderkind")
        }
    }

    @IBAction func send_start(_ sender: Any) {
        UserDefaults.standard.set("Bootloader", forKey: "Choice")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Startbutton"), object: nil, userInfo: ["name" : self.start_button.stringValue as Any])
        self.view.window?.close()
    }

    
}
