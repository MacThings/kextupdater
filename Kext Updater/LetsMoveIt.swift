//
//  LetsMoveIt.swift
//
//  Created by Sascha Lamprecht 04.06.2021
//

import Cocoa

class LetsMoveIt: NSViewController {
    
    func ToApps() {

        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        var LaunchPath = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        LaunchPath.removeLast()
        let BundleAppName = Bundle.main.infoDictionary!["CFBundleName"] as! String
        let RealAppName = String(LaunchPath.suffix(from: (LaunchPath.range(of: BundleAppName)?.lowerBound)!))
        
        if LaunchPath.contains("/Applications/") {
            return
        }
        if UserDefaults.standard.bool(forKey: "Supress") {
            return
        }
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Move to Applications folder?", comment: "")
        alert.informativeText = NSLocalizedString("I can move myself to the Applications folder if you'd like. This will keep your Downloads folder uncluttered.", comment: "")
        alert.alertStyle = .informational
        alert.showsSuppressionButton = true
        let Button = NSLocalizedString("Do Not Move", comment: "")
        alert.addButton(withTitle: Button)
        let CancelButtonText = NSLocalizedString("Move to Applications Folder", comment: "")
        alert.addButton(withTitle: CancelButtonText)

        if alert.runModal() == .alertFirstButtonReturn {
            if let supress = alert.suppressionButton {
                let state = supress.state
                switch state {
                case NSControl.StateValue.on:
                UserDefaults.standard.set(true, forKey: "Supress")
                default: break
                }
            }
            return
        }

        let admin_check = "user=$( id -un ); admin_check=$( groups \"$user\" | grep -w -q admin ); echo \"$admin_check\""
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = ["-c", admin_check]
        process.launch()
        process.waitUntilExit()
        
        let fileManager = FileManager.default
        let path = "/Applications/" + RealAppName
            if admin_check.contains(" admin ") {
                do {
                    if fileManager.fileExists(atPath: path) {
                        try fileManager.removeItem(atPath: path)
                    }
                    try fileManager.copyItem(atPath: LaunchPath, toPath: path)
                    try fileManager.removeItem(atPath: LaunchPath)
                } catch {
                    return
                }
            } else {
                let move_to_apps = "osascript -e 'do shell script \"rm -rf /Applications/" + RealAppName + "; cp -r \\\"" + LaunchPath + "\\\" /Applications/; chown -R " + NSUserName() + ":staff \\\"/Applications/" + RealAppName + "\\\"; rm -r \\\"" + LaunchPath + "\\\"\" with administrator privileges'"
                let process            = Process()
                process.launchPath     = "/bin/bash"
                process.arguments      = ["-c", move_to_apps]
                process.launch()
                process.waitUntilExit()
            }
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
}
