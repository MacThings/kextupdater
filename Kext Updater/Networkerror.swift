//
//  MalwareInfo.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class Networkerror: NSViewController {
    
    @IBOutlet weak var close_window: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func close_window(_ sender: Any) {
        self.view.window?.close()
    }
    

}



