//
//  ViewController.swift
//  Kext Updater
//
//  Created by Prof. Dr. Luigi on 24.06.18.
//  Copyright © 2018 com.slsoft. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var popupButton: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupButton.menu?.removeAllItems()
        
        // You should get this from your file
        let fileContent = """
        /dev/disk1s1
        /dev/disk3s2
        /dev/disk4s3
        """
        
        for (index, drive) in fileContent.components(separatedBy: "\n").enumerated() {
            popupButton.menu?.addItem(withTitle: drive, action: #selector(ViewController.menuItemClicked(_:)), keyEquivalent: "\(index + 1)")
        }
    }
    
    @objc func menuItemClicked(_ sender: NSMenuItem) {
        print("\(sender.title) clicked")
    }
}

