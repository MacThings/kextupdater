//
//  BigSurPlus.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class OCConfigCompare: NSViewController {
    
    @IBOutlet weak var close_window: NSButton!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = NSLocalizedString("Information", comment: "")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    }

    @IBAction func go_github(_ sender: Any) {
        if let url = URL(string: "https://github.com/corpnewt/OCConfigCompare"),
            NSWorkspace.shared.open(url) {
        }
    }
    
    @objc func cancel(_ sender: Any?) {
        self.view.window?.close()
    }

}



