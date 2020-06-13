//
//  EFIMount.swift
//  EFIMount
//
//  Created by Sascha Lamprecht on 30.05.2020.
//  Copyright © 2020 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class EFIMount: NSViewController {

    @IBOutlet weak var progress_gear_mount: NSProgressIndicator!
    @IBOutlet weak var progress_gear: NSProgressIndicator!
    
    @IBOutlet weak var pulldown_menu: NSPopUpButton!
    @IBOutlet weak var button_mount: NSButton!
    @IBOutlet weak var button_unmount: NSButton!
    @IBOutlet weak var button_unmount_all: NSButton!
    @IBOutlet weak var button_close: NSButton!
    
    let userDesktopDirectory:String = NSHomeDirectory()
    
    let scriptPath = Bundle.main.path(forResource: "/script/efimount", ofType: "command")!
    let scriptPathMount = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        NSApp.activate(ignoringOtherApps: true)
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
                self.pulldown_menu.menu?.addItem(withTitle: drive, action: #selector(EFIMount.menuItemClicked(_:)), keyEquivalent: "")
            }

            }
        }
    }
    
    @objc func menuItemClicked(_ sender: NSMenuItem) {
        self.pulldown_menu.item(withTitle: "")?.isHidden=true
        self.button_mount.isEnabled=true
        self.button_unmount.isEnabled=true
        self.button_unmount_all.isEnabled=true
        let efichoice = sender.title
        if let range = efichoice.range(of: " - ") {
            let efichoice2 = efichoice[efichoice.startIndex..<range.lowerBound]
            UserDefaults.standard.set(efichoice2 + "s1", forKey: "EFIx")
            self.syncShellExec(path: self.scriptPathMount, args: ["mounthelper"])
        }
        
                
    }
    
    @IBAction func efi_tools_mount(_ sender: Any) {
        self.button_mount.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_mount.isHidden=false
        self.progress_gear_mount?.startAnimation(self);
        //DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["mountefiall"])
            //DispatchQueue.main.async {
                self.progress_gear_mount.isHidden=false
                self.progress_gear_mount?.startAnimation(self);
                self.button_mount.isEnabled=true
                self.button_unmount.isEnabled=true
                self.button_unmount_all.isEnabled=true
                self.button_close.isEnabled=true
                self.pulldown_menu.isEnabled=true
                self.progress_gear_mount.isHidden=true
                self.progress_gear_mount?.stopAnimation(self);
            //}
        //}
    }
    
    @IBAction func efi_tools_unmount(_ sender: Any) {
        self.button_mount.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_mount.isHidden=false
        self.progress_gear_mount?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["unmountefi"])
            DispatchQueue.main.async {
                self.progress_gear_mount.isHidden=false
                self.progress_gear_mount?.startAnimation(self);
                self.button_mount.isEnabled=true
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
        self.button_mount.isEnabled=false
        self.button_unmount.isEnabled=false
        self.button_unmount_all.isEnabled=false
        self.button_close.isEnabled=false
        self.pulldown_menu.isEnabled=false
        self.progress_gear_mount.isHidden=false
        self.progress_gear_mount?.startAnimation(self);
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["unmountefiall"])
            DispatchQueue.main.async {
                self.progress_gear_mount.isHidden=false
                self.progress_gear_mount?.startAnimation(self);
                self.button_mount.isEnabled=true
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
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
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
    
}
