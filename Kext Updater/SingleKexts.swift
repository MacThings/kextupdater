//
//  SingleKexts.swift
//  Kext Updater
//
//  Created by Prof. Dr. Luigi on 19.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class SingleKexts: NSViewController {

    @IBOutlet weak var start_button: NSButton!
    @IBOutlet weak var select_all_button: NSButton!
    @IBOutlet weak var deselect_all_button: NSButton!
    @IBOutlet weak var close_button: NSButton!
    @IBOutlet weak var group_select_pulldown: NSPopUpButton!
    @IBOutlet weak var group_select_pulldown_empty: NSMenuItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("dl-"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    @IBAction func group_select(_ sender: Any) {
        self.group_select_pulldown_empty.isHidden=true
        let group_choice = (sender as AnyObject).selectedCell()!.tag
        if group_choice == 1 {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.hasPrefix("dl-"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            UserDefaults.standard.set(true, forKey: "dl-fakesmc")
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

    @IBAction func start(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "DoDownload")
        self.view.window?.close()
        UserDefaults.standard.set("Single", forKey: "Choice")
    }
    
    @IBAction func send_start (sender: NSButton) {
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
        UserDefaults.standard.set(true, forKey: "dl-intelmausi")
        UserDefaults.standard.set(true, forKey: "dl-intelmausiethernet")
        UserDefaults.standard.set(true, forKey: "dl-lilu")
        UserDefaults.standard.set(true, forKey: "dl-lilufriend")
        UserDefaults.standard.set(true, forKey: "dl-nightshiftunlocker")
        UserDefaults.standard.set(true, forKey: "dl-notouchid")
        UserDefaults.standard.set(true, forKey: "dl-novpajpeg")
        UserDefaults.standard.set(true, forKey: "dl-nullcpupowermanagement")
        UserDefaults.standard.set(true, forKey: "dl-nullethernet")
        UserDefaults.standard.set(true, forKey: "dl-realtekrtl8111")
        UserDefaults.standard.set(true, forKey: "dl-rtcmemoryfixup")
        UserDefaults.standard.set(true, forKey: "dl-sinetekrtsx")
        UserDefaults.standard.set(true, forKey: "dl-systemprofilermemoryfixup")
        UserDefaults.standard.set(true, forKey: "dl-tscadjustreset")
        UserDefaults.standard.set(true, forKey: "dl-usbinjectall")
        UserDefaults.standard.set(true, forKey: "dl-virtualsmc")
        UserDefaults.standard.set(true, forKey: "dl-voodoohda")
        UserDefaults.standard.set(true, forKey: "dl-voodooi2c")
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
    
}
