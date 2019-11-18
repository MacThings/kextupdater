//
//  Tools.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class Tools: NSViewController {

    var process:Process!
    var out:FileHandle?
    var outputTimer: Timer?
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!

    @IBOutlet weak var button_kextcache: NSButton!
    
    @IBOutlet weak var atheros40notapplied: NSImageView!
    @IBOutlet weak var atheros40applied: NSImageView!
    @IBOutlet weak var button_atheros: NSButton!
    
    @IBOutlet weak var fixnotapplied: NSImageView!
    @IBOutlet weak var fixapplied: NSImageView!
    @IBOutlet weak var button_fix_sleep: NSButton!
    
    @IBOutlet weak var read_only: NSTextField!
    @IBOutlet weak var read_write: NSTextField!
    @IBOutlet weak var button_read_write: NSButton!
    
    @IBOutlet weak var pulldown_menu: NSPopUpButton!
    @IBOutlet weak var button_mount: NSButton!
    @IBOutlet weak var button_unmount: NSButton!
    @IBOutlet weak var button_unmount_all: NSButton!
    
    @IBOutlet weak var button_offline_efi: NSButton!
    
    @IBOutlet weak var button_close: NSButton!
        
    @IBOutlet weak var progress_gear_cache: NSProgressIndicator!
    @IBOutlet weak var progress_gear_atheros: NSProgressIndicator!
    @IBOutlet weak var progress_gear_mount: NSProgressIndicator!
    @IBOutlet weak var progress_gear: NSProgressIndicator!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.progress_gear.isHidden=false
        self.progress_gear?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["scanallefis"])
            self.syncShellExec(path: self.scriptPath, args: ["checksleepfix"])
            DispatchQueue.main.async {
                self.progress_gear.isHidden=true
                self.progress_gear?.stopAnimation(self);
            let filePath = "/private/tmp/kextupdater/drives_pulldown"
            if (FileManager.default.fileExists(atPath: filePath)) {
                print("")
            } else{
                return
            }

            let location = NSString(string:"/private/tmp/kextupdater/drives_pulldown").expandingTildeInPath
            //self.pulldown_menu.item(withTitle: "  ")?.isHidden=true
            let fileContent = try? NSString(contentsOfFile: location, encoding: String.Encoding.utf8.rawValue)
            for (_, drive) in (fileContent?.components(separatedBy: "\n").enumerated())! {
                self.pulldown_menu.menu?.addItem(withTitle: drive, action: #selector(Tools.menuItemClicked(_:)), keyEquivalent: "")
            }

            }
        
        DispatchQueue.main.async {
        let sleepcheck = UserDefaults.standard.string(forKey: "Sleepfix")
        if sleepcheck == "1" {
            self.button_fix_sleep.isEnabled = false
            self.fixapplied.isHidden = false
            self.fixnotapplied.isHidden = true
        } else {
            self.button_fix_sleep.isEnabled = true
            self.fixapplied.isHidden = true
            self.fixnotapplied.isHidden = false
        }
        
            self.syncShellExec(path: self.scriptPath, args: ["checkatheros40"])
        let atheros40check = UserDefaults.standard.string(forKey: "Atheros40")
        if atheros40check == "1" {
            //button_atheros.isEnabled = false
            self.atheros40applied.isHidden = false
            self.atheros40notapplied.isHidden = true
        } else {
            //button_atheros.isEnabled = true
            self.atheros40applied.isHidden = true
            self.atheros40notapplied.isHidden = true
        }
                        
        let readonly = UserDefaults.standard.string(forKey: "Read-Only")
        if readonly == "No" {
            self.button_read_write.isEnabled = false
            self.read_only.isHidden = true
            self.read_write.isHidden = false
        } else {
            self.button_read_write.isEnabled = true
            self.read_only.isHidden = false
            self.read_write.isHidden = true
        }
            
            }
      
    }
    }
 
    @IBAction func cacherebuild(_ sender: Any) {
        self.button_kextcache.isEnabled=false
        self.button_atheros.isEnabled=false
        self.button_fix_sleep.isEnabled=false
        self.button_mount.isEnabled=false
        self.button_offline_efi.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_cache?.startAnimation(self);
        self.progress_gear_cache.isHidden=false
        DispatchQueue.global(qos: .background).async {
            let rwcheck = UserDefaults.standard.string(forKey: "Read-Only")
            if rwcheck == "No"{
                self.syncShellExec(path: self.scriptPath, args: ["rebuildcache"])
            }
            DispatchQueue.main.async {
                self.button_kextcache.isEnabled=true
                self.button_atheros.isEnabled=true
                self.button_fix_sleep.isEnabled=true
                self.button_mount.isEnabled=true
                self.button_offline_efi.isEnabled=true
                self.button_unmount.isEnabled=true
                self.button_unmount_all.isEnabled=true
                self.button_close.isEnabled=true
                self.pulldown_menu.isEnabled=true
                self.progress_gear_cache?.stopAnimation(self);
                self.progress_gear_cache.isHidden=true
            }
        }

        }

    @IBAction func atheros_yes(_ sender: Any) {
        self.button_kextcache.isEnabled=false
        self.button_atheros.isEnabled=false
        self.button_fix_sleep.isEnabled=false
        self.button_mount.isEnabled=false
        self.button_offline_efi.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_atheros?.startAnimation(self);
        self.progress_gear_atheros.isHidden=false
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["ar92xx"])
            DispatchQueue.main.async {
                self.button_kextcache.isEnabled=true
                self.button_atheros.isEnabled=true
                self.button_fix_sleep.isEnabled=true
                self.button_mount.isEnabled=true
                self.button_offline_efi.isEnabled=true
                self.button_unmount.isEnabled=true
                self.button_unmount_all.isEnabled=true
                self.button_close.isEnabled=true
                self.pulldown_menu.isEnabled=true
                self.progress_gear_atheros?.stopAnimation(self);
                self.progress_gear_atheros.isHidden=true
            }
        }
    }
    
    @IBAction func sleepfix_yes(_ sender: Any) {
        self.button_kextcache.isEnabled=false
        self.button_atheros.isEnabled=false
        self.button_fix_sleep.isEnabled=false
        self.button_mount.isEnabled=false
        self.button_offline_efi.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["fixsleepimage"])
            DispatchQueue.main.async {
                self.button_kextcache.isEnabled=true
                self.button_atheros.isEnabled=true
                self.button_fix_sleep.isEnabled=true
                self.button_mount.isEnabled=true
                self.button_offline_efi.isEnabled=true
                self.button_unmount.isEnabled=true
                self.button_unmount_all.isEnabled=true
                self.button_close.isEnabled=true
                self.pulldown_menu.isEnabled=true
            }
        }
    }
    
    @IBAction func set_read_write(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["set_read_write"])
        let readonly = UserDefaults.standard.string(forKey: "Read-Only")
        if readonly == "No" {
            self.button_read_write.isEnabled = false
            self.read_only.isHidden = true
            self.read_write.isHidden = false
        } else {
            self.button_read_write.isEnabled = true
            self.read_only.isHidden = false
            self.read_write.isHidden = true
        }
    }
    
    @IBAction func offline_efi_check(_ sender: Any) {
            self.button_kextcache.isEnabled=false
            self.button_atheros.isEnabled=false
            self.button_fix_sleep.isEnabled=false
            self.button_mount.isEnabled=false
            self.button_offline_efi.isEnabled=false
            self.button_unmount.isEnabled=false
            self.button_unmount_all.isEnabled=false
            self.button_close.isEnabled=false
            self.pulldown_menu.isEnabled=false
            self.progress_gear_mount.isHidden=false
            self.progress_gear_mount?.startAnimation(self);
            DispatchQueue.global(qos: .background).sync {
                self.syncShellExec(path: self.scriptPath, args: ["mountefiall"])
                DispatchQueue.main.async {
                    self.button_kextcache.isEnabled=true
                    self.button_atheros.isEnabled=true
                    self.button_fix_sleep.isEnabled=true
                    self.progress_gear_mount.isHidden=false
                    self.progress_gear_mount?.startAnimation(self);
                    self.button_mount.isEnabled=true
                    self.button_offline_efi.isEnabled=true
                    self.button_unmount.isEnabled=true
                    self.button_unmount_all.isEnabled=true
                    self.button_close.isEnabled=true
                    self.pulldown_menu.isEnabled=true
                    self.progress_gear_mount.isHidden=true
                    self.progress_gear_mount?.stopAnimation(self);
                }
            }
        
            UserDefaults.standard.set(true, forKey: "OfflineEFI")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Startbutton"), object: nil, userInfo: ["name" : self.button_offline_efi.stringValue as Any])
        self.view.window?.close()
    }
    
    
    @IBAction func efi_tools_mount(_ sender: Any) {
        self.button_kextcache.isEnabled=false
        self.button_atheros.isEnabled=false
        self.button_fix_sleep.isEnabled=false
        self.button_mount.isEnabled=false
        self.button_offline_efi.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_mount.isHidden=false
        self.progress_gear_mount?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["mountefiall"])
            DispatchQueue.main.async {
                self.button_kextcache.isEnabled=true
                self.button_atheros.isEnabled=true
                self.button_fix_sleep.isEnabled=true
                self.progress_gear_mount.isHidden=false
                self.progress_gear_mount?.startAnimation(self);
                self.button_mount.isEnabled=true
                self.button_offline_efi.isEnabled=true
                self.button_unmount.isEnabled=true
                self.button_unmount_all.isEnabled=true
                self.button_close.isEnabled=true
                self.pulldown_menu.isEnabled=true
                self.progress_gear_mount.isHidden=true
                self.progress_gear_mount?.stopAnimation(self);
            }
        }
    }
    
    @IBAction func efi_tools_unmount(_ sender: Any) {
        self.button_kextcache.isEnabled=false
        self.button_atheros.isEnabled=false
        self.button_fix_sleep.isEnabled=false
        self.button_mount.isEnabled=false
        self.button_offline_efi.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_mount.isHidden=false
        self.progress_gear_mount?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["unmountefi"])
            DispatchQueue.main.async {
                self.button_kextcache.isEnabled=true
                self.button_atheros.isEnabled=true
                self.button_fix_sleep.isEnabled=true
                self.progress_gear_mount.isHidden=false
                self.progress_gear_mount?.startAnimation(self);
                self.button_mount.isEnabled=true
                self.button_offline_efi.isEnabled=true
                self.button_unmount.isEnabled=true
                self.button_unmount_all.isEnabled=true
                self.button_close.isEnabled=true
                self.pulldown_menu.isEnabled=true
                self.progress_gear_mount.isHidden=true
                self.progress_gear_mount?.stopAnimation(self);
            }
        }
    }
    
    @IBAction func efi_tools_unmount_all(_ sender: Any) {
        self.button_kextcache.isEnabled=false
        self.button_atheros.isEnabled=false
        self.button_fix_sleep.isEnabled=false
        self.button_mount.isEnabled=false
        self.button_offline_efi.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_mount.isHidden=false
        self.progress_gear_mount?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["unmountefiall"])
            DispatchQueue.main.async {
                self.button_kextcache.isEnabled=true
                self.button_atheros.isEnabled=true
                self.button_fix_sleep.isEnabled=true
                self.progress_gear_mount.isHidden=false
                self.progress_gear_mount?.startAnimation(self);
                self.button_mount.isEnabled=true
                self.button_offline_efi.isEnabled=true
                self.button_unmount.isEnabled=true
                self.button_unmount_all.isEnabled=true
                self.button_close.isEnabled=true
                self.pulldown_menu.isEnabled=true
                self.progress_gear_mount.isHidden=true
                self.progress_gear_mount?.stopAnimation(self);
            }
        }
    }
    
    
    @IBAction func close_button(_ sender: Any) {
        self.view.window?.close()
    }
    
    
    /**
     * Performs an "asynchronous" shell exec with non blocking UI thread
     */
    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        let filelHandler       = outputPipe.fileHandleForReading
        process.standardOutput = outputPipe
        process.launch()
        process.waitUntilExit()
        filelHandler.readabilityHandler = nil
    }
       
    @objc func menuItemClicked(_ sender: NSMenuItem) {
        self.pulldown_menu.item(withTitle: "")?.isHidden=true
        //self.pulldown_menu.menu?.removeItem(at: 0)
        self.button_mount.isEnabled=true
        self.button_offline_efi.isEnabled=true
        self.button_unmount.isEnabled=true
        self.button_unmount_all.isEnabled=true
        let efichoice = sender.title
        let efichoice2 = efichoice.prefix(7)
        UserDefaults.standard.set(efichoice2, forKey: "EFIx")
    }
    
}
