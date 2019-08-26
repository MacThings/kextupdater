//
//  KUMenuBar.swift
//  KUMenuBar
//
//  Created by Prof. Dr. Luigi on 26.08.19.
//  Copyright © 2019 Kelvin Ng. All rights reserved.
//

import Cocoa

class KUMenuBar: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
  
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    @IBAction func ok_button(_ sender: Any) {
        self.view.window?.close()
    }
    
    @IBAction func set_intervall(_ sender: Any) {
        let intervall = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(intervall, forKey: "UpdateIntervall")
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["runcheck"])
            self.syncShellExec(path: self.scriptPath, args: ["kumenubar"])
            DispatchQueue.main.async {
                
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
