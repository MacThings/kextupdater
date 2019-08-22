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

    @IBAction func getpassword(_ sender: Any) {
                password()
    }
    
    
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
        UserDefaults.standard.set(true, forKey: "Keychain")
            if let path = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent().absoluteString {
                NSLog("restart \(path)")
                _ = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [path])
                NSApp.terminate(self)
                exit(0)
            }
        }
        
    }

    @IBAction func cancel(_ sender: Any) {
        self.view.window?.close()
        //randomButton.performClick(nil)
    }
    
    @IBOutlet var randomButton: NSButton!
    
    @IBAction func test(_ sender: Any) {
            print("toll")
    }
    
    func password() -> Void {
        let keychain = KeychainSwift()
        let secret = pwdpassword.stringValue
        //pwdwindow.setIsVisible(false)
        keychain.set(secret, forKey: "Kext Updater")
        syncShellExec(path: scriptPath, args: ["_checkpass"])
        let passcheck = UserDefaults.standard.string(forKey: "Passwordok")
        if passcheck == "Yes" {
            //wrongpassword.setIsVisible(true)
            //passaccepted.isHidden = false
            //passrefused.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                //self.wrongpassword.setIsVisible(false)
                //self.passaccepted.isHidden = true
                //self.passrefused.isHidden = true
            })
        } else {
            //wrongpassword.setIsVisible(true)
            //self.passaccepted.isHidden = true
            //self.passrefused.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                //self.pwdwindow.setIsVisible(true)
                //self.pwdpassword.stringValue = ""
                //self.wrongpassword.setIsVisible(false)
                //self.passaccepted.isHidden = true
                //self.passrefused.isHidden = true
            })
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
        
        filelHandler.readabilityHandler = { pipe in
            let data = pipe.availableData
            if let line = String(data: data, encoding: .utf8) {
                DispatchQueue.main.sync {
                    //self.output_window.scrollToEndOfDocument(nil)
                    //self.output_window.string += line
                }
            } else {
                print("Error decoding data: \(data.base64EncodedString())")
            }
        }
        process.waitUntilExit()
        filelHandler.readabilityHandler = nil
    }
    

    
}
