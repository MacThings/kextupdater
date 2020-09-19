//
//  BigSurPlus.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class LESLEWarning: NSViewController {
    
    @IBOutlet weak var close_window: NSButton!
    @IBOutlet var output_window: NSTextView!

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = NSLocalizedString("Warning", comment: "")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        let location = NSString(string:self.userDesktopDirectory + "/.ku_temp/le_sle_result").expandingTildeInPath
        let fileContent = try? NSString(contentsOfFile: location, encoding: String.Encoding.utf8.rawValue)
        for (_, kexts) in (fileContent?.components(separatedBy: "\n").enumerated())! {
            self.output_window.string += kexts + "\n"
            self.output_window.scrollToBeginningOfDocument(nil)
        }
    }

    @IBAction func close_window(_ sender: Any) {
        self.view.window?.close()
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }

    func userDesktop() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
        let userDesktopDirectory = paths[0]
        return userDesktopDirectory
    }
    let userDesktopDirectory:String = NSHomeDirectory()
    
}



