//
//  Website.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
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
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1"
        webView.mainFrame.load(requestObj as URLRequest)
    }
    
    
    

    
    

}


