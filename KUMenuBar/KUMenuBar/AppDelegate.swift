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
    
    @objc func displayMenu() {
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
    
    @IBAction func quit_menubar(_ sender: Any) {
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


