//
//  AppDelegate.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa
//import KeychainSwift
//import LetsMove

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldTerminateAfterLastWindowClosed (_
        theApplication: NSApplication) -> Bool {
        return true
    }

    var process:Process!
    var out:FileHandle?
    var outputTimer: Timer?
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
 
         for key in UserDefaults.standard.dictionaryRepresentation().keys {
             if key.hasPrefix("dl-"){
                 UserDefaults.standard.removeObject(forKey: key)
             }
         }
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["exitapp"])
        }
        UserDefaults.standard.set(false, forKey: "DoDownload")
    }
    @IBAction func resetrootuser(_ sender: Any) {
        syncShellExec(path: scriptPath, args: ["_resetrootuser"])
        if let path = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent().absoluteString {
            NSLog("restart \(path)")
            _ = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [path])
            NSApp.terminate(self)
            exit(0)
        }
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

