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
    @IBOutlet weak var button_atheros_uninstall: NSButton!
    
    @IBOutlet weak var disablegfxhdaapplied: NSImageView!
    @IBOutlet weak var button_disablegfxhda: NSButton!
    @IBOutlet weak var button_disablegfxhda_uninstall: NSButton!
    
    @IBOutlet weak var fixnotapplied: NSImageView!
    @IBOutlet weak var fixapplied: NSImageView!
    @IBOutlet weak var button_fix_sleep: NSButton!
    @IBOutlet weak var button_fix_sleep_undo: NSButton!
    
    @IBOutlet weak var button_read_write: NSButton!
    @IBOutlet weak var button_read_write_bs: NSButton!
    @IBOutlet weak var label_read_write: NSTextField!
    
    @IBOutlet weak var custom_efi_folder: NSTextField!
    @IBOutlet weak var custom_efi_folder_path: NSTextField!
    @IBOutlet weak var button_custom_efi_folder: NSButton!
    @IBOutlet weak var button_efi_folder_choose: NSButton!
    
    @IBOutlet weak var oc_config_file: NSTextField!
    @IBOutlet weak var oc_config_file_path: NSTextField!
    @IBOutlet weak var button_oc_config_file: NSButton!
    @IBOutlet weak var button_oc_config_choose: NSButton!
    
    
    @IBOutlet weak var pulldown_menu: NSPopUpButton!
    @IBOutlet weak var button_mount: NSButton!
    @IBOutlet weak var button_unmount: NSButton!
    @IBOutlet weak var button_unmount_all: NSButton!
    
    @IBOutlet weak var button_offline_efi: NSButton!
    
    @IBOutlet weak var button_close: NSButton!
        
    @IBOutlet weak var progress_gear_cache: NSProgressIndicator!
    @IBOutlet weak var progress_gear_atheros: NSProgressIndicator!
    @IBOutlet weak var progress_gear_disablegfxhda: NSProgressIndicator!
    @IBOutlet weak var progress_gear_mount: NSProgressIndicator!
    @IBOutlet weak var progress_gear: NSProgressIndicator!
    
    let userDesktopDirectory:String = NSHomeDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        UserDefaults.standard.set(false, forKey: "OfflineEFI")
        UserDefaults.standard.set(false, forKey: "CustomEFI")
        self.progress_gear.isHidden=false
        self.progress_gear?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.contains("-Name"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
                if key.contains("EFIx"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            self.syncShellExec(path: self.scriptPath, args: ["scanallefis"])
            self.syncShellExec(path: self.scriptPath, args: ["checksleepfix"])
            DispatchQueue.main.async {
                self.progress_gear.isHidden=true
                self.progress_gear?.stopAnimation(self);
            let filePath = self.userDesktopDirectory + "/.ku_temp/drives_pulldown"
            if (FileManager.default.fileExists(atPath: filePath)) {
                print("")
            } else{
                return
            }

            let location = NSString(string:self.userDesktopDirectory + "/.ku_temp/drives_pulldown").expandingTildeInPath
            //self.pulldown_menu.item(withTitle: "  ")?.isHidden=true
            let fileContent = try? NSString(contentsOfFile: location, encoding: String.Encoding.utf8.rawValue)
            for (_, drive) in (fileContent?.components(separatedBy: "\n").enumerated())! {
                self.pulldown_menu.menu?.addItem(withTitle: drive, action: #selector(Tools.menuItemClicked(_:)), keyEquivalent: "")
            }

            }
        
        DispatchQueue.main.async {
        let sleepcheck = UserDefaults.standard.string(forKey: "Sleepfix")
        if sleepcheck == "1" {
            self.button_fix_sleep.isHidden = true
            self.button_fix_sleep_undo.isHidden = false
            self.fixapplied.isHidden = false
            self.fixnotapplied.isHidden = true
        } else {
            self.button_fix_sleep.isHidden = false
            self.button_fix_sleep_undo.isHidden = true
            self.fixapplied.isHidden = true
            self.fixnotapplied.isHidden = false
        }
        
            self.syncShellExec(path: self.scriptPath, args: ["checkatheros40"])
            let atheros40check = UserDefaults.standard.string(forKey: "Atheros40")
            if atheros40check == "1" {
            self.button_atheros.isHidden = true
            self.button_atheros_uninstall.isHidden = false
            self.atheros40applied.isHidden = false
            self.atheros40notapplied.isHidden = true
        } else {
            self.button_atheros.isHidden = false
            self.button_atheros_uninstall.isHidden = true
            self.atheros40applied.isHidden = true
            self.atheros40notapplied.isHidden = true
        }

            self.syncShellExec(path: self.scriptPath, args: ["checkdisablegfxhda"])
            let disablegfxhdacheck = UserDefaults.standard.string(forKey: "DisableGFXHDA")
            if disablegfxhdacheck == "1" {
                self.button_disablegfxhda.isHidden = true
                self.button_disablegfxhda_uninstall.isHidden = false
                self.disablegfxhdaapplied.isHidden = false
            } else {
                self.button_disablegfxhda.isHidden = false
                self.button_disablegfxhda_uninstall.isHidden = true
                self.disablegfxhdaapplied.isHidden = true
            }
            
        let readonly = UserDefaults.standard.string(forKey: "Read-Only")
        if readonly == "No" {
            self.button_read_write.isEnabled = false
            self.label_read_write.stringValue = NSLocalizedString("Read / Write", comment: "")
        } else {
            self.button_read_write.isEnabled = true
            self.label_read_write.stringValue = NSLocalizedString("Read only", comment: "")
        }
            
            // Checks if 10.x or 11.x is used
            let os_version = String(UserDefaults.standard.string(forKey: "OSVersion")!.prefix(2))
            if os_version == "10"{
                self.button_read_write.isHidden = false
                self.button_read_write_bs.isHidden = true
            } else {
                //11.x + detected
                self.syncShellExec(path: self.scriptPath, args: ["_get_node"])
                let rw_check = UserDefaults.standard.string(forKey: "RW")
                self.button_read_write.isHidden = true
                self.button_read_write_bs.isHidden = false
                
                if rw_check == "No" {
                    self.label_read_write.stringValue = NSLocalizedString("Read only", comment: "")
                    self.button_kextcache.isEnabled = false
                    self.button_atheros.isEnabled = false
                    self.button_atheros_uninstall.isEnabled = false
                    self.button_disablegfxhda.isEnabled = false
                    self.button_disablegfxhda_uninstall.isEnabled = false
                    self.button_fix_sleep.isEnabled = false
                    self.button_fix_sleep_undo.isEnabled = false
                
                    self.syncShellExec(path: self.scriptPath, args: ["_check_authroot"])
                    let authroot_status = UserDefaults.standard.string(forKey: "AuthRoot")
                    
                    if authroot_status == "Yes"{
                        let alert = NSAlert()
                        alert.messageText = NSLocalizedString("Authenticated Root is active!", comment: "")
                        alert.informativeText = NSLocalizedString("With 'authenticated-root' enabled it's not possible to set the Systemvolume to r/w. Please make sure to disable it. There are 2 ways......", comment: "")
                        alert.alertStyle = .warning
                        alert.icon = NSImage(named: "NSError")
                        let Button = NSLocalizedString("I will check it", comment: "")
                        alert.addButton(withTitle: Button)
                        alert.runModal()
                    }
                    
                } else {
                    self.label_read_write.stringValue = NSLocalizedString("Read / Write", comment: "")
                }
                
            }
        }
      
        }
    }
 
    @IBAction func cacherebuild(_ sender: Any) {
        let os_version = String(UserDefaults.standard.string(forKey: "OSVersion")!.prefix(2))
        if os_version == "10" {
            catalina_read_write()
            disable_all()
            self.progress_gear_cache?.startAnimation(self);
            self.progress_gear_cache.isHidden=false
            DispatchQueue.global(qos: .background).async {
                let rwcheck = UserDefaults.standard.string(forKey: "Read-Only")
                if rwcheck == "No"{
                    self.syncShellExec(path: self.scriptPath, args: ["rebuildcache"])
                }
                DispatchQueue.main.async {
                    self.enable_all()
                    self.progress_gear_cache?.stopAnimation(self);
                    self.progress_gear_cache.isHidden=true
                }
            }
        } else {
            self.progress_gear_cache?.startAnimation(self);
            self.progress_gear_cache.isHidden=false
            DispatchQueue.global(qos: .background).async {
                self.syncShellExec(path: self.scriptPath, args: ["rebuildcache"])
                DispatchQueue.main.async {
                    self.enable_all()
                    self.progress_gear_cache?.stopAnimation(self);
                    self.progress_gear_cache.isHidden=true
                }
            }
        }
    }

    @IBAction func atheros_yes(_ sender: Any) {
        catalina_read_write()
        disable_all()
        self.progress_gear_atheros?.startAnimation(self);
        self.progress_gear_atheros.isHidden=false
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["ar92xx"])
            DispatchQueue.main.async {
                self.enable_all()
                self.progress_gear_atheros?.stopAnimation(self);
                self.progress_gear_atheros.isHidden=true
                self.view.window?.close()
            }
        }
    }
    
    @IBAction func atheros_uninstall(_ sender: Any) {
        disable_all()
        self.progress_gear_atheros?.startAnimation(self);
        self.progress_gear_atheros.isHidden=false
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["ar92xx_remove"])
            DispatchQueue.main.async {
                self.enable_all()
                self.progress_gear_atheros?.stopAnimation(self);
                self.progress_gear_atheros.isHidden=true
                self.view.window?.close()
            }
        }

    }
    
    @IBAction func disablegfxhda_yes(_ sender: Any) {
        catalina_read_write()
        disable_all()
        self.progress_gear_disablegfxhda?.startAnimation(self);
        self.progress_gear_disablegfxhda.isHidden=false
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["disablegfxhda"])
            DispatchQueue.main.async {
                self.enable_all()
                self.progress_gear_disablegfxhda?.stopAnimation(self);
                self.progress_gear_disablegfxhda.isHidden=true
                self.view.window?.close()
            }
        }
    }
    
    @IBAction func disablegfxhda_uninstall(_ sender: Any) {
        disable_all()
        self.progress_gear_disablegfxhda?.startAnimation(self);
        self.progress_gear_disablegfxhda.isHidden=false
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["disablegfxhda_remove"])
            DispatchQueue.main.async {
                self.enable_all()
                self.progress_gear_disablegfxhda?.stopAnimation(self);
                self.progress_gear_disablegfxhda.isHidden=true
                self.view.window?.close()
            }
        }

    }
    
    
    @IBAction func sleepfix_yes(_ sender: Any) {
        catalina_read_write()
        disable_all()
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["fixsleepimage"])
            DispatchQueue.main.async {
                self.enable_all()
                self.view.window?.close()
            }
        }
    }
 
    @IBAction func sleepfix_undo(_ sender: Any) {
        catalina_read_write()
        disable_all()
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["fixsleepimage_undo"])
            DispatchQueue.main.async {
                self.enable_all()
                self.view.window?.close()
            }
        }
    }
    
    
    func disable_all() {
        self.button_oc_config_choose.isEnabled=false
        self.button_efi_folder_choose.isEnabled=false
        self.button_kextcache.isEnabled=false
        self.button_atheros.isEnabled=false
        self.button_disablegfxhda.isEnabled=false
        self.button_fix_sleep.isEnabled=false
        self.button_mount.isEnabled=false
        self.button_offline_efi.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.button_atheros_uninstall.isEnabled=false
        self.button_disablegfxhda_uninstall.isEnabled=false
        self.button_fix_sleep_undo.isEnabled=false
        self.button_read_write.isEnabled=false
        self.custom_efi_folder_path.isEnabled=false
        self.button_custom_efi_folder.isEnabled=false
        self.button_oc_config_file.isEnabled=false
    }

    func enable_all() {
        self.button_oc_config_choose.isEnabled=true
        self.button_efi_folder_choose.isEnabled=true
        self.button_kextcache.isEnabled=true
        self.button_atheros.isEnabled=true
        self.button_disablegfxhda.isEnabled=true
        self.button_fix_sleep.isEnabled=true
        self.button_mount.isEnabled=true
        self.button_offline_efi.isEnabled=true
        self.button_unmount.isEnabled=true
        self.button_unmount_all.isEnabled=true
        self.button_close.isEnabled=true
        self.pulldown_menu.isEnabled=true
        self.button_atheros_uninstall.isEnabled=true
        self.button_disablegfxhda_uninstall.isEnabled=true
        self.button_fix_sleep_undo.isEnabled=true
        self.button_read_write.isEnabled=true
        self.custom_efi_folder_path.isEnabled=true
        self.button_custom_efi_folder.isEnabled=true
        self.button_oc_config_file.isEnabled=true
    }
    
    @IBAction func set_read_write(_ sender: Any) {
        catalina_read_write()
    }
    
    @IBAction func browseEFIfolder(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = NSLocalizedString("Choose an EFI folder", comment: "");
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                self.button_custom_efi_folder.isEnabled=true
                self.button_custom_efi_folder.keyEquivalent = "\r"
                self.button_oc_config_file.keyEquivalent = ""
                let path = result!.path
                custom_efi_folder_path.stringValue = path
                let cefipath = (path as String)
                UserDefaults.standard.set(cefipath, forKey: "CustomEfiPath")
            }
        } else {
            self.button_custom_efi_folder.isEnabled=false
            return
        }
    }
    
    @IBAction func browseOCconfig(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        dialog.title                   = NSLocalizedString("Choose an OpenCore config file", comment: "");
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["plist"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                self.button_oc_config_file.isEnabled=true
                self.button_oc_config_file.keyEquivalent = "\r"
                self.button_custom_efi_folder.keyEquivalent = ""
                let path = result!.path
                oc_config_file_path.stringValue = path
                let ocpath = (path as String)
                UserDefaults.standard.set(ocpath, forKey: "OCConfigFile")
            }
        } else {
            self.button_oc_config_file.isEnabled=false
            return
        }
    }
    
    @IBAction func custom_efi_check(_ sender: Any) {
            UserDefaults.standard.set(true, forKey: "CustomEFI")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Startbutton"), object: nil, userInfo: ["name" : self.button_offline_efi.stringValue as Any])
        self.view.window?.close()
    }
 
    @IBAction func oc_config_check(_ sender: Any) {
            UserDefaults.standard.set(true, forKey: "OCConfigCheck")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Startbutton"), object: nil, userInfo: ["name" : self.button_oc_config_file.stringValue as Any])
        self.view.window?.close()
    }
    
    @IBAction func offline_efi_check(_ sender: Any) {
            UserDefaults.standard.set(true, forKey: "OfflineEFI")
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
        if let range = efichoice.range(of: " - ") {
            let efichoice2 = efichoice[efichoice.startIndex..<range.lowerBound]
            UserDefaults.standard.set(efichoice2 + "s1", forKey: "EFIx")
        }
        
                
    }
    
    func catalina_read_write() {
    self.syncShellExec(path: self.scriptPath, args: ["set_read_write"])
    let readonly = UserDefaults.standard.string(forKey: "Read-Only")
    if readonly == "No" {
        self.button_read_write.isEnabled = false
        self.label_read_write.stringValue = NSLocalizedString("Read / Write", comment: "")
    } else {
        self.button_read_write.isEnabled = true
        self.label_read_write.stringValue = NSLocalizedString("Read only", comment: "")
    }
}
   
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}
