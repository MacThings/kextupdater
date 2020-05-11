//
//  MalwareInfo.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class Hint: NSViewController {
    
    @IBOutlet weak var close_window: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    }

    @IBAction func close_window(_ sender: Any) {
        self.view.window?.close()
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }
    
}



