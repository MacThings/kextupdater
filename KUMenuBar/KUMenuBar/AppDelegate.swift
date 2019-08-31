//
//  AppDelegate.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!

    //strong reference to retain the status bar item object
	var statusItem: NSStatusItem?
    
    @IBOutlet weak var appMenu: NSMenu!
    @IBOutlet weak var process_id: NSMenuItem!
    @IBOutlet weak var mount_efi: NSMenuItem!
    @IBOutlet weak var unmount_efi: NSMenuItem!
    @IBOutlet weak var efi_folder: NSMenuItem!
    
    @objc func displayMenu() {
        
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["open_menu"])
            DispatchQueue.main.async {
                let checkefimount = UserDefaults.standard.string(forKey: "Mounted")
                if checkefimount == "Yes"{
                    self.unmount_efi.isHidden=false
                    self.mount_efi.isHidden=true
                    self.efi_folder.isHidden=false
                } else {
                    self.unmount_efi.isHidden=true
                    self.mount_efi.isHidden=false
                    self.efi_folder.isHidden=true
                }
            }
        }
        guard let button = statusItem?.button else { return }
        let x = button.frame.origin.x
        let y = button.frame.origin.y - 5
        let location = button.superview!.convert(NSMakePoint(x, y), to: nil)
        let w = button.window!
        let event = NSEvent.mouseEvent(with: .leftMouseUp,
                                       location: location,
                                       modifierFlags: NSEvent.ModifierFlags(rawValue: 0),
                                       timestamp: 0,
                                       windowNumber: w.windowNumber,
                                       context: w.graphicsContext,
                                       eventNumber: 0,
                                       clickCount: 1,
                                       pressure: 0)!
        NSMenu.popUpContextMenu(appMenu, with: event, for: button)
    }
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        UserDefaults.standard.set(appVersion, forKey: "AppVersion")
        
        let pid: Int32 = ProcessInfo.processInfo.processIdentifier
        let pid2 = String(pid)
        self.process_id.title=("PID: " + pid2 + " / Version " + appVersion!)
        UserDefaults.standard.set(pid2, forKey: "PID")
        
        let afterrebootinit = UserDefaults.standard.bool(forKey: "AfterRebootOnly")
        if afterrebootinit == false{
            UserDefaults.standard.set(false, forKey: "AfterRebootOnly")
        }

        let intervalinit = UserDefaults.standard.string(forKey: "UpdateInterval")
        if intervalinit == nil{
            UserDefaults.standard.set("21600", forKey: "UpdateInterval")
        }
        
        let intervalstring = UserDefaults.standard.string(forKey: "UpdateInterval")
        let myintervalstring = (intervalstring! as NSString).doubleValue
        let afterrebootinit2 = UserDefaults.standard.bool(forKey: "AfterRebootOnly")
        if afterrebootinit2 == false {
            Timer.scheduledTimer(timeInterval: myintervalstring, target: self, selector: #selector(self.updatecheck), userInfo: nil, repeats: true)
        } else {
            Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.updatecheck), userInfo: nil, repeats: false)
        }
 
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
       
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["runcheck"])
            DispatchQueue.main.async {
                let checkefimount = UserDefaults.standard.string(forKey: "Mounted")
                if checkefimount == "Yes"{
                    self.unmount_efi.isHidden=false
                    self.mount_efi.isHidden=true
                    self.efi_folder.isHidden=false
                } else {
                    self.unmount_efi.isHidden=true
                    self.mount_efi.isHidden=false
                    self.efi_folder.isHidden=true
                }
            }
        }
        
        guard let button = statusItem?.button else {
            print("status bar item failed. Try removing some menu bar item.")
            NSApp.terminate(nil)
            return
        }
        
        button.image = NSImage(named: "MenuBarButton")
        button.target = self
        button.action = #selector(displayMenu)
    }

    @objc func updatecheck() {
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["updatecheck"])
            DispatchQueue.main.async {
            }
        }
    }

    @IBAction func open_kextupdater(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["open_kextupdater"])
            DispatchQueue.main.async {
            }
        }
    }
    
    @IBAction func mount_efi(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["mount_bootefi"])
            self.syncShellExec(path: self.scriptPath, args: ["refreshtime"])
            DispatchQueue.main.async {
                self.unmount_efi.isHidden=false
                self.mount_efi.isHidden=true
                self.efi_folder.isHidden=false
            }
        }
    }
    
    @IBAction func unmount_efi(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["mount_bootefi"])
            self.syncShellExec(path: self.scriptPath, args: ["refreshtime"])
            DispatchQueue.main.async {
                self.mount_efi.isHidden=false
                self.unmount_efi.isHidden=true
                self.efi_folder.isHidden=true
            }
        }
    }
    
    @IBAction func open_efi(_ sender: Any) {
        let efipath = UserDefaults.standard.string(forKey: "EFI Path")
        let url = URL(fileURLWithPath: efipath ?? "")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch _ {
            print("")
        }
        
        let efipath2 = UserDefaults.standard.string(forKey: "EFI Path")
        NSWorkspace.shared.openFile(efipath2 ?? "")
    }

    @IBAction func quit_menubar(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "PID")
        DispatchQueue.global(qos: .background).async {
           self.syncShellExec(path: self.scriptPath, args: ["quitmenu"])
            DispatchQueue.main.async {
                NSApplication.shared.terminate(self)
            }
        }
        
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
}


