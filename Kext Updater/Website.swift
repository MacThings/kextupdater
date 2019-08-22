//
//  Website.swift
//  Kext Updater
//
//  Created by Prof. Dr. Luigi on 22.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import WebKit

class Website: NSViewController {
    
    @IBOutlet weak var webView: WebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        let urlstring = UserDefaults.standard.string(forKey: "SourceURL")
        let url = NSURL (string: urlstring!)
        let requestObj = NSURLRequest(url: url! as URL)
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E188a Safari/601.1"
        webView.mainFrame.load(requestObj as URLRequest)
    }
}


