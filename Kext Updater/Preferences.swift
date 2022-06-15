//
//  Preferences.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class Preferences: NSViewController {
    
    @IBOutlet weak var selected_download_path: NSTextField!
    @IBOutlet weak var selected_backup_path: NSTextField!
    
    @IBOutlet weak var EFI_Backup_Name_Default: NSButton!
    @IBOutlet weak var EFI_Backup_Name_Lable: NSTextField!
    @IBOutlet weak var EFI_Backup_Name_Custom: NSButton!
    @IBOutlet weak var EFI_Backup_Name_Lower_Case: NSButton!
    @IBOutlet weak var EFI_Backup_Name: NSTextField!
    
    
    @IBOutlet weak var speakericon: NSImageView!
    @IBOutlet weak var speakericon_off: NSImageView!
    @IBOutlet weak var speakerslider: NSSlider!
    @IBOutlet weak var download_path_textfield: NSTextFieldCell!
    @IBOutlet weak var backup_path_textfield: NSTextField!
    @IBOutlet weak var close_button: NSButton!
    

    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    override func viewDidAppear() {
        self.view.window?.styleMask.remove(NSWindow.StyleMask.resizable)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let speakervolume = UserDefaults.standard.string(forKey: "Speakervolume")
        if speakervolume == "0" {
            speakericon_off.isHidden = false
            speakericon.isHidden = true
        } else {
            speakericon_off.isHidden = true
            speakericon.isHidden = false
        }
        
        let downloadpath = UserDefaults.standard.string(forKey: "Downloadpath")
        download_path_textfield.stringValue = (downloadpath ?? "")
        
        let backuppath = UserDefaults.standard.string(forKey: "Backuppath")
        backup_path_textfield.stringValue = (backuppath ?? "")
        
        let efibackupcustom = UserDefaults.standard.bool(forKey: "EFIBackupCustom")
        if efibackupcustom == true {
            self.EFI_Backup_Name.isEnabled = true
            self.EFI_Backup_Name_Lower_Case.isEnabled = true
        } else {
            self.EFI_Backup_Name.isEnabled = false
            self.EFI_Backup_Name_Lower_Case.isEnabled = false
        }
    }

    @IBAction func default_name_select(_ sender: Any) {
        self.EFI_Backup_Name_Custom.state = NSControl.StateValue.off
        UserDefaults.standard.set(false, forKey: "EFIBackupCustom")
        self.EFI_Backup_Name.isEnabled = false
        self.EFI_Backup_Name_Lower_Case.isEnabled = false
    }
    
    @IBAction func custom_name_select(_ sender: Any) {
        self.EFI_Backup_Name.isEnabled = true
        self.EFI_Backup_Name_Lower_Case.isEnabled = true
        self.EFI_Backup_Name_Default.state = NSControl.StateValue.off
        UserDefaults.standard.set(false, forKey: "EFIBackupDefault")
    }
    
    @IBAction func resetprefs(_ sender: Any) {
        syncShellExec(path: scriptPath, args: ["loginitem_off"])
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        if let path = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent().absoluteString {
            NSLog("restart \(path)")
            _ = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [path])
            NSApp.terminate(self)
            exit(0)
        }
    }
    
    @IBAction func defaultpath_download(_ sender: Any) {
        let defaultdir = self.userDesktopDirectory + "/Desktop/Kext-Updates"
        UserDefaults.standard.set(defaultdir, forKey: "Downloadpath")
        selected_download_path.stringValue = (defaultdir)
    }
    
    @IBAction func defaultpath_backup(_ sender: Any) {
        let defaultdir = self.userDesktopDirectory + "/Documents/EFI-Backup"
        UserDefaults.standard.set(defaultdir, forKey: "Backuppath")
        selected_backup_path.stringValue = (defaultdir)
    }
    
    @IBAction func volslider(_ sender: Any) {
        let speakervolume = UserDefaults.standard.string(forKey: "Speakervolume")
        if speakervolume == "0" {
            speakericon_off.isHidden = false
            speakericon.isHidden = true
        } else {
            speakericon_off.isHidden = true
            speakericon.isHidden = false
        }
    }

    @IBAction func preferencesclose(_ sender: Any) {
        let eficustomname: String = EFI_Backup_Name.stringValue
        UserDefaults.standard.set(eficustomname, forKey: "EFIBackupNameCustom")
        self.view.window?.close()
        DispatchQueue.global(qos: .background).async {
            let menubaritem = UserDefaults.standard.bool(forKey: "MenuBarItem")
            if menubaritem == true {
                self.syncShellExec(path: self.scriptPath, args: ["kumenubar_on"])
            } else if menubaritem == false {
                self.syncShellExec(path: self.scriptPath, args: ["kumenubar_off"])
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePrefs"), object: nil, userInfo: ["name" : self.close_button?.stringValue as Any])
                }
        }
    }
    
    @IBAction func menubaritem_toggle(_ sender: Any) {
        let menubaritem = UserDefaults.standard.bool(forKey: "MenuBarItem")
        if menubaritem == true {
            self.syncShellExec(path: self.scriptPath, args: ["kumenubar_on"])
        } else if menubaritem == false {
            self.syncShellExec(path: self.scriptPath, args: ["kumenubar_off"])
        }
    }
    
     

    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        process.standardOutput = outputPipe
        process.launch()
        process.waitUntilExit()
    }

    /**
     * Get Users System Home
     */
    func userDesktop() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
        let userDesktopDirectory = paths[0]
        return userDesktopDirectory
    }
    let userDesktopDirectory:String = NSHomeDirectory()
    
    @IBAction func browseFile_download(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                selected_download_path.stringValue = path
                let dlpath = (path as String)
                UserDefaults.standard.set(dlpath, forKey: "Downloadpath")
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func browseFile_backup(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                selected_backup_path.stringValue = path
                let dlpath = (path as String)
                UserDefaults.standard.set(dlpath, forKey: "Backuppath")
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
 
}
