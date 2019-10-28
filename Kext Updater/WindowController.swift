//
//  MyWindowController.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 28.10.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApp.stop(nil)
        return false
    }
}
