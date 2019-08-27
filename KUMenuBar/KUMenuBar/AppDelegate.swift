//
//  AppDelegate.swift
//  Kext Updater
//
//  Created by Prof. Dr. Luigi on 16.08.19.
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
        statusItem = NSStatusBar.system.statusItem(withLength: -1)
        
        let intervalinit = UserDefaults.standard.string(forKey: "UpdateInterval")
        if intervalinit == nil{
            UserDefaults.standard.set("6", forKey: "UpdateInterval")
        }
        
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["runcheck"])
            self.syncShellExec(path: self.scriptPath, args: ["kumenubar"])
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


