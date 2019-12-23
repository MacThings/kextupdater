//
//  nVidiaWebdriver.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class nVidiaWebdriver: NSViewController {

    
    @IBOutlet weak var elcapitan_builds: NSPopUpButton!
    @IBOutlet weak var yosemite_builds: NSPopUpButton!
    @IBOutlet weak var sierra_builds: NSPopUpButton!
    @IBOutlet weak var highsierra_builds: NSPopUpButton!
    @IBOutlet weak var please_choose_label: NSTextField!
    @IBOutlet weak var start_button: NSButton!
    
    @IBOutlet weak var os_version_empty: NSMenuItem!
    
    @IBOutlet weak var elcapitan_empty_entry: NSMenuItem!
    @IBOutlet weak var yosemite_empty_entry: NSMenuItem!
    @IBOutlet weak var sierra_empty_entry: NSMenuItem!
    @IBOutlet weak var highsierra_empty_entry: NSMenuItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    }
    
    
    @IBAction func os_choice(_ sender: Any) {
        let oschoice = (sender as AnyObject).selectedCell()!.title
        if oschoice == "Yosemite" {
            self.yosemite_builds.isHidden=false
            self.elcapitan_builds.isHidden=true
            self.sierra_builds.isHidden=true
            self.highsierra_builds.isHidden=true
            self.please_choose_label.isHidden=true
            self.yosemite_empty_entry.isHidden=true
            self.os_version_empty.isHidden=true
        } else if oschoice == "El Capitan" {
            self.yosemite_empty_entry.isHidden=true
            self.elcapitan_builds.isHidden=false
            self.yosemite_builds.isHidden=true
            self.sierra_builds.isHidden=true
            self.highsierra_builds.isHidden=true
            self.please_choose_label.isHidden=true
            self.elcapitan_empty_entry.isHidden=true
            self.os_version_empty.isHidden=true
        } else if oschoice == "Sierra" {
            self.yosemite_builds.isHidden=true
            self.elcapitan_builds.isHidden=true
            self.sierra_builds.isHidden=false
            self.highsierra_builds.isHidden=true
            self.please_choose_label.isHidden=true
            self.sierra_empty_entry.isHidden=true
            self.os_version_empty.isHidden=true
        } else if oschoice == "High Sierra" {
            self.yosemite_builds.isHidden=true
            self.elcapitan_builds.isHidden=true
            self.sierra_builds.isHidden=true
            self.highsierra_builds.isHidden=false
            self.please_choose_label.isHidden=true
            self.highsierra_empty_entry.isHidden=true
            self.os_version_empty.isHidden=true
        } else if oschoice != "" {
            self.yosemite_builds.isHidden=true
            self.elcapitan_builds.isHidden=true
            self.sierra_builds.isHidden=true
            self.highsierra_builds.isHidden=true
            self.please_choose_label.isHidden=false
        }
    }

    @IBAction func yosemite_choice(_ sender: Any) {
        self.start_button.isEnabled=true
        let webdriverbuild = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(webdriverbuild, forKey: "Webdriver Build")
    }
    
    @IBAction func elcapitan_choice(_ sender: Any) {
        self.start_button.isEnabled=true
        let webdriverbuild = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(webdriverbuild, forKey: "Webdriver Build")
    }

    @IBAction func sierra_choice(_ sender: Any) {
        self.start_button.isEnabled=true
        let webdriverbuild = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(webdriverbuild, forKey: "Webdriver Build")
    }
    
    @IBAction func highsierra_choice(_ sender: Any) {
        self.start_button.isEnabled=true
        let webdriverbuild = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(webdriverbuild, forKey: "Webdriver Build")
    }
    
    @IBAction func send_start(_ sender: Any) {
        UserDefaults.standard.set("Webdriver", forKey: "Choice")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Startbutton"), object: nil, userInfo: ["name" : self.start_button.stringValue as Any])
        self.view.window?.close()
    }
    
    
    @IBAction func close_button(_ sender: Any) {
        self.view.window?.close()
        UserDefaults.standard.set("1", forKey: "Choice")
        let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "Webdriver Build")
        defaults.synchronize()
    }
    
}
