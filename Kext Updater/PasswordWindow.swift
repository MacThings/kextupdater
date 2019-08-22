//
//  PasswordWindow.swift
//  Kext Updater
//
//  Created by Prof. Dr. Luigi on 19.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import KeychainSwift

class PasswordWindow: NSViewController {

    var process:Process!
    var out:FileHandle?
    var outputTimer: Timer?
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    @IBOutlet weak var pwdusername: NSTextField!
    @IBOutlet weak var pwdpassword: NSSecureTextField!
    @IBOutlet weak var ok_button: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
            let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
            pwdusername.stringValue = (rootuserfull ?? "")
    }
    
    @IBAction func ok_button(_ sender: Any) {
        password()
        let password_ok = UserDefaults.standard.string(forKey: "Passwordok")
        if password_ok == "Yes" {
            self.view.window?.close()
            UserDefaults.standard.set(true, forKey: "Keychain")
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DoRefreshKeychain"), object: nil, userInfo: ["name" : self.ok_button?.stringValue as Any])
            }
    }

    @IBAction func cancel(_ sender: Any) {
        self.view.window?.close()
    }

    func password() -> Void {
        let secret = pwdpassword.stringValue
        KeychainSwift().set(secret, forKey: "Kext Updater")
        syncShellExec(path: scriptPath, args: ["_checkpass"])
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
