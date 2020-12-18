//
//  CustomTableCell.swift
//  View Based Table Example
//
//  Created by Scott Lougheed on 2020/02/26.
//  Copyright © 2020 Scott Lougheed. All rights reserved.
//

import Cocoa

class CustomTableCell: NSTableCellView {
    
    @IBOutlet weak var KextNameLabel: NSTextField!
    
    @IBOutlet weak var download_box: NSButtonCell!
    @IBOutlet weak var exclude_box: NSButton!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.

    }
    
    
    @IBAction func emailButton(_ sender: Any) {
        let link = KextNameLabel.stringValue
        print(link)
    }
    
    @IBAction func download(_ sender: Any) {
        let kext = KextNameLabel.stringValue

        if download_box.state == NSControl.StateValue.on {
                print(kext + " download")
        } else {
                print(kext + " nodownload")
            
        }
    }
    
    @IBAction func exclude(_ sender: Any) {
        let kext = KextNameLabel.stringValue

        if exclude_box.state == NSControl.StateValue.on {
                print(kext + " exclude")
        } else {
                print(kext + " no exclude")
            
        }
    }
    
    
    
}
