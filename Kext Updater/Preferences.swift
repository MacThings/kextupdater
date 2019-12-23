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
    @IBOutlet weak var speakericon: NSImageView!
    @IBOutlet weak var speakericon_off: NSImageView!
    @IBOutlet weak var speakerslider: NSSlider!
    @IBOutlet weak var download_path_textfield: NSTextFieldCell!
    @IBOutlet weak var close_button: NSButton!
    

    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
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
    
    @IBAction func defaultpath(_ sender: Any) {
        let defaultdir = self.userDesktopDirectory + "/Desktop/Kext-Updates"
        UserDefaults.standard.set(defaultdir, forKey: "Downloadpath")
        selected_download_path.stringValue = (defaultdir)
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
        self.view.window?.close()
        DispatchQueue.global(qos: .background).async {
            let loginitem = UserDefaults.standard.bool(forKey: "LoginItem")
            if loginitem == true {
                self.syncShellExec(path: self.scriptPath, args: ["loginitem_on"])
            } else if loginitem == false {
                self.syncShellExec(path: self.scriptPath, args: ["loginitem_off"])
            }
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
    
    @IBAction func browseFile(sender: AnyObject) {
        
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
    
 
}
