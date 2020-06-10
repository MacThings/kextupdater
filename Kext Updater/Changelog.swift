//
//  Website.swift
//  
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import WebKit

class Changelog: NSViewController {


    @IBOutlet weak var webView: WebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        let url = NSURL (string: "https://www.sl-soft.de/extern/software/kextupdater/kextupdaterng.html")
        let requestObj = NSURLRequest(url: url! as URL)
        webView.mainFrame.load(requestObj as URLRequest)
        
    }
    
    @IBAction func close_button(_ sender: Any) {
        self.view.window?.close()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
