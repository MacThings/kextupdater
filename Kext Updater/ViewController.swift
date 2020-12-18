//
//  ViewController.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    let kexts = [["name":"AppleALC"],
                ["name":"Lilu"],
                ["name":"VirtualSMC"]]

    func numberOfRows(in tableView: NSTableView) -> Int {
        return kexts.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let userCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "userCell"), owner: self) as? CustomTableCell else { return nil }

        userCell.KextNameLabel.stringValue = kexts[row]["name"] ?? "unknown user"
        
        return userCell
    }
    
    
}

