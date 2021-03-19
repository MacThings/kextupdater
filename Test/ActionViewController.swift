//
//  ActionViewController.swift
//  Test
//
//  Created by Prof. Dr. Luigi on 19.03.21.
//  Copyright © 2021 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class ActionViewController: NSViewController {

    @IBOutlet var myTextView: NSTextView!
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ActionViewController")
    }

    override func loadView() {
        super.loadView()
    
        // Insert code here to customize the view
        NSLog("Input Items = %@", self.extensionContext!.inputItems as NSArray)
    
        let sharedItem = self.extensionContext!.inputItems[0] as! NSExtensionItem
        let text = sharedItem.attributedContentText?.string
        
        if text != nil && !text!.isEmpty {
            self.myTextView.string = text!
        }
    }

    @IBAction func send(_ sender: AnyObject?) {
        // Note: The extension information in theInfo.plist is set to accept any type of content, but this example code only handles text. You should declare the specific types to be supported by your extension in the extension's Info.plist and then make sure to handle all your supported types.
        let outputItem = NSExtensionItem()
        outputItem.attributedContentText = self.myTextView.attributedString()
    
        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
    }

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}
