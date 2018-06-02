//
//  AppDelegate.swift
//  Kext Updater
//
//  Created by Sascha_77 on 18.05.18.
//  Copyright © 2018 Sascha_77. All rights reserved.
//

import Cocoa
import Foundation
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var player: AVAudioPlayer?
    
    @IBOutlet var logger:       NSTextView!
    @IBOutlet weak var loggerScroll: NSScrollView!
    @IBOutlet weak var osversion:    NSTextField!
    @IBOutlet weak var kuversion: NSTextField!
    @IBOutlet weak var spinner:      NSProgressIndicator!
    @IBOutlet weak var webDrivers:   NSPopUpButton!
    @IBOutlet weak var help:         NSWindow!
    @IBOutlet weak var aboutwindow: NSWindow!
    @IBOutlet weak var nightly: NSButton!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        logger.font = NSFont(name: "Monaco", size: 15)
        
        self.asyncShellExec(path: Bundle.main.path(forResource: "osversion", ofType: "command"))
        self.asyncShellExec(path: Bundle.main.path(forResource: "kuversion", ofType: "command"))
        self.asyncShellExec(path: Bundle.main.path(forResource: "choice", ofType: "command"))
        
        let filePath = "/tmp/osversion.tmp"
        do {
            // Read file content
            let contentFromFile   = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue)
            osversion.stringValue = (contentFromFile as String)
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        let filePath2 = "/tmp/kuversion.tmp"
        do {
            // Read file content
            let contentFromFile   = try NSString(contentsOfFile: filePath2, encoding: String.Encoding.utf8.rawValue)
            kuversion.stringValue = (contentFromFile as String)
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) {
        self.asyncShellExec(path: Bundle.main.path(forResource: "cleanup", ofType: "command"))
        exit(0)
    }
    
    //@IBAction func webpulldown(_ sender: AnyObject) {
    //    print("dropdown",sender.selectedCell()!.title);
    //}
    
    @IBAction func update(_ sender: NSButton) { // Checks by Tag which Radio-Button is pressed
        switch sender.tag {
        case 10:
            webDrivers.setValue(true, forKey: "enabled")
            //print(sender.selectedCell()!.title);
            break
        default:
            //print(sender.selectedCell()!.title);
            webDrivers.setValue(false, forKey: "enabled")
        }
        switch sender.tag {
        case 8:
            nightly.setValue(true, forKey: "enabled")
            //print(sender.selectedCell()!.title);
            break
        default:
            //print(sender.selectedCell()!.title);
            nightly.setValue(false, forKey: "enabled")
        }
        
        let filePath           = "/tmp/choice.tmp"
        let fileContentToWrite = sender.selectedCell()!.title
        do {
            // Write contents to file
            try fileContentToWrite.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        self.asyncShellExec(path: Bundle.main.path(forResource: "nightly", ofType: "command"))
    }
    
    @IBAction func webdriver(_ sender: AnyObject) {
        let filePath = "/tmp/webdriver.tmp"
        let fileContentToWrite = (sender as AnyObject).selectedCell()!.title
        do {
            // Write contents to file
            try fileContentToWrite.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    
    @IBAction func nightchecked(_ sender: AnyObject) {
        print(sender.selectedCell()!.title);
        let filePath = "/tmp/nightly.tmp"
        let fileContentToWrite = (sender as AnyObject).selectedCell()!.title
        do {
            // Write contents to file
            try fileContentToWrite.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    @IBAction func quit(_ sender: NSButton) {
        self.asyncShellExec(path: Bundle.main.path(forResource: "cleanup", ofType: "command"))
        exit(0)
    }
    
    @IBAction func mountefi(_ sender: NSButton) {
        logger.textStorage?.mutableString.setString("")
        sender.isEnabled    = false
        self.asyncShellExec(path: Bundle.main.path(forResource: "mountefi", ofType: "command"))
        sender.isEnabled    = true
    }
    
    @IBAction func check(_ sender: NSButton) {
        logger.textStorage?.mutableString.setString("")
        self.asyncShellExec(path: Bundle.main.path(forResource: "script", ofType: "command"))
        sender.isEnabled = true
        self.chime()
    }
    
    @IBAction func basichelp(_ sender: NSButton) {
        help.setIsVisible(true)
    }
    
    @IBAction func aboutwin(_ sender: Any) {
        aboutwindow.setIsVisible(true)
    }
    /**
     * Performs a "asynchronous" shell exec with non blocking UI thread
     */
    func asyncShellExec(path: String?) {
        let script             = [path!]
        let process            = Process()
        let outputPipe         = Pipe()
        let filelHandler       = outputPipe.fileHandleForReading
        var output             = ""
        
        process.launchPath     = "/bin/bash"
        process.arguments      = script
        process.standardOutput = outputPipe
        
        DispatchQueue.global(qos: .userInitiated).async {
            filelHandler.readabilityHandler = { pipe in
                if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                    // Update your view with the new text here
                    output = line
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        self.logger.string = self.logger.string + output
                    }
                } else {
                    print("Error decoding data: \(pipe.availableData)")
                }
            }
        }
        
        self.spinner.startAnimation(self)
        self.spinner.isHidden = false
        process.launch()
        process.waitUntilExit()
        filelHandler.readabilityHandler = nil
        self.loggerScroll.flashScrollers()
        self.spinner.stopAnimation(self)
        self.spinner.isHidden = true
    }
    
    /**
     * plays a chime sound
     */
    func chime() -> Void {
        let url = Bundle.main.url(forResource: "done", withExtension: "mp3")!
        do {
            player           = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}



