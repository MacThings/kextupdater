//
//  KUMenuBar.swift
//  KUMenuBar
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class KUMenuBar: NSViewController {

    @IBOutlet weak var interval_pulldown: NSPopUpButton!
    @IBOutlet weak var label_1: NSTextField!
    @IBOutlet weak var label_2: NSTextField!
    

    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSApp.activate(ignoringOtherApps: true)
        let afterreboot = UserDefaults.standard.bool(forKey: "AfterRebootOnly")
        if afterreboot == true{
            interval_pulldown.isEnabled=false
        }
    }
  
    @IBAction func ok_button(_ sender: Any) {
        if let path = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent().absoluteString {
            NSLog("restart \(path)")
            _ = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [path])
            NSApp.terminate(self)
            exit(0)
        }
    }
    
    @IBAction func set_interval(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["runcheck"])
            self.syncShellExec(path: self.scriptPath, args: ["updatecheck"])
            DispatchQueue.main.async {
            }
        }
    }

    @IBAction func only_after_reboot(_ sender: Any) {
        let afterreboot = UserDefaults.standard.bool(forKey: "AfterRebootOnly")
        if afterreboot == true{
            self.interval_pulldown.isEnabled=false
        } else {
            self.interval_pulldown.isEnabled=true
        }
        
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
