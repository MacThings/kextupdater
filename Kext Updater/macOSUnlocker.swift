//
//  ViewController.swift
//  macOS Unlocker
//
//  Created by Prof. Dr. Luigi on 11.11.20.
//

import Cocoa


class macOSUnlocker: NSViewController {
    
    @IBOutlet weak var rw_status: NSImageView!
    @IBOutlet weak var set_rw: NSButton!
    @IBOutlet weak var apply_reboot: NSButton!
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);

        self.rw_status((Any).self)
        
        self.syncShellExec(path: self.scriptPath, args: ["_check_authroot"])
        
        let authroot_status = UserDefaults.standard.string(forKey: "AuthRoot")
        
        if authroot_status == "Yes"{
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Authenticated Root is active!", comment: "")
            alert.informativeText = NSLocalizedString("With 'authenticated-root' enabled it's not possible to set the Systemvolume to r/w. Please make sure to disable it. There are 2 ways.", comment: "")
            alert.alertStyle = .warning
            alert.icon = NSImage(named: "NSError")
            let Button = NSLocalizedString("I will check it", comment: "")
            alert.addButton(withTitle: Button)
            alert.runModal()
            self.set_rw.isEnabled = false
            self.apply_reboot.isEnabled = false
        }
    }
        
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "macOS Unlocker"
  
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @IBAction func set_rw(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_set_rw"])
            DispatchQueue.main.async {
                self.rw_status((Any).self)
              }
        }
    }
    
    @IBAction func apply_reboot(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_apply_reboot"])
            DispatchQueue.main.async {
              }
        }
    }
    
    
    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }
    
    func rw_status(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["_get_node"])
        let rw_status = UserDefaults.standard.string(forKey: "RW")
        if rw_status == "No"{
            self.rw_status.image = NSImage(named: "NSLockLockedTemplate")
        } else {
            self.rw_status.image = NSImage(named: "NSLockUnlockedTemplate")
        }
    }
}

