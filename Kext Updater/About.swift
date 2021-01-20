//
//  About.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class About: NSViewController {
    
    @IBOutlet weak var copyright: NSTextField!
    @IBOutlet weak var version: NSTextField!
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    
    
    override func viewDidAppear() {
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        super.viewDidAppear()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let dateStr = formatter.string(from: NSDate() as Date)
        self.copyright.stringValue = "© " + dateStr + " Sascha Lamprecht"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.version.stringValue = "Version " + appVersion!
        // Do view setup here.
    }

    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }

}



