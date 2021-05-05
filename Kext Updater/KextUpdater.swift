//
//  KextUpdater.swift
//  Kext Updater
//
//  Created by Sascha Lamprecht on 16.08.19.
//  Copyright © 2019 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import AVFoundation
import KeychainSwift
import LetsMove

class KextUpdater: NSViewController {
    
    var player: AVAudioPlayer?
        
    @IBOutlet var output_window: NSTextView!
    @IBOutlet weak var app_logo: NSImageView!
    @IBOutlet weak var app_logo_animation: NSProgressIndicator!
    
    @IBOutlet weak var crtview: NSImageView!
    
    @IBOutlet weak var egg1: NSButton!
    @IBOutlet weak var egg2: NSButton!
    @IBOutlet weak var egg3: NSButton!
    @IBOutlet weak var egg4: NSButton!
    @IBOutlet weak var surprise_xmas: NSImageView!
    @IBOutlet weak var surprise_snow: NSImageView!
    @IBOutlet weak var surprise_newyear: NSImageView!
        
    @IBOutlet weak var keychain_pfeil: NSImageView!
    @IBOutlet weak var keychain_text: NSTextField!
    
    // Infobox
    @IBOutlet weak var infobox_system_version: NSTextField!
    @IBOutlet weak var infobox_admin_status_image_red: NSImageView!
    @IBOutlet weak var infobox_admin_status_image_green: NSImageView!
    @IBOutlet weak var infobox_admin_status_content_yes: NSTextField!
    @IBOutlet weak var infobox_admin_status_content_no: NSTextField!
    // Infobox - End
    
    // MB Section
    @IBOutlet weak var mb_detected: NSTextField!
    
    // Folder Section
    @IBOutlet weak var folder_efi_icon: NSButton!
    @IBOutlet weak var folder_efi_path: NSTextField!
    @IBOutlet weak var folder_download_icon: NSButton!
    @IBOutlet weak var folder_download_path: NSTextField!
    // Folder Section - End
    
    // Footer Section
    @IBOutlet weak var footer_efi_image_red: NSImageView!
    @IBOutlet weak var footer_efi_image_green: NSImageView!
    @IBOutlet weak var footer_efi_diskinfo_click: NSButton!
    @IBOutlet weak var footer_efi_image_eject: NSImageView!
    
    
    // Footer Section - End

    @IBOutlet weak var keychainyes: NSImageView!
    @IBOutlet weak var keychainno: NSImageView!
    @IBOutlet weak var key_yes_button: NSButton!
    @IBOutlet weak var key_no_button: NSButton!
    
    @IBOutlet var start_button: NSButton!
    @IBOutlet var stop_button: NSButton!
    @IBOutlet weak var kexts_button: NSButton!
    @IBOutlet weak var webdriver_button: NSButton!
    @IBOutlet weak var bootloader_button: NSButton!
    @IBOutlet weak var report_button: NSButton!
    @IBOutlet weak var efi_button: NSButton!
    @IBOutlet weak var tools_button: NSButton!
    @IBOutlet weak var efi_backup_button: NSButton!
    
    @IBOutlet weak var show_hint: NSButton!
    @IBOutlet weak var show_auth_root: NSButton!
    @IBOutlet weak var show_lesle_warning: NSButton!
    
    
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
        
    @IBAction func quit_app(_ sender: Any) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("dl-"){
                UserDefaults.standard.removeObject(forKey: key)
                DispatchQueue.global(qos: .background).async {
                    self.syncShellExec(path: self.scriptPath, args: ["exitapp"])
                    DispatchQueue.main.async {
                    }
                }
            }
        }
        NSApplication.shared.terminate(self)
        //UserDefaults.standard.set(false, forKey: "DoDownload")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        UserDefaults.standard.removeObject(forKey: "NodeId")
        UserDefaults.standard.removeObject(forKey: "RW")
        UserDefaults.standard.removeObject(forKey: "AuthRoot")
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["_cleanup"])
            DispatchQueue.main.async {
            }
        }
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Kext Updater"

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        let result = formatter.string(from: date)
        
        if result == "31.12" {
            self.surprise_newyear.isHidden = false
        } else if result == "01.01" {
            self.surprise_newyear.isHidden = false
        } else if result == "27.12" {
            print("0")
        } else if result == "28.12" {
            print("0")
        } else if result == "29.12" {
            print("0")
        } else if result == "30.12" {
            print("0")
        } else if result.contains(".12") {
            self.surprise_xmas.isHidden = false
            self.surprise_snow.isHidden = false
        }
        
                
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(self.AppShutdown),
            name: NSWorkspace.willPowerOffNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.pressStartbutton),
            name: NSNotification.Name(rawValue: "Startbutton"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.doRefreshKeychain),
            name: NSNotification.Name(rawValue: "DoRefreshKeychain"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.closePrefs),
            name: NSNotification.Name(rawValue: "ClosePrefs"),
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.pressAuthRoot(notification:)),
            name: NSNotification.Name(rawValue: "AuthRoot"),
            object: nil)
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updatecheck), userInfo: nil, repeats: true)
        
        PFMoveToApplicationsFolderIfNecessary()

        let occheck = UserDefaults.standard.string(forKey: "OCChecked")
        if occheck == nil{
            UserDefaults.standard.removeObject(forKey: "OCChecked")
        }
        
        //let leslewarning = UserDefaults.standard.string(forKey: "LESLE Warning")
        //if leslewarning != nil{
        //    UserDefaults.standard.removeObject(forKey: "LESLE Warning")
        //}
        
        syncShellExec(path: scriptPath, args: ["initial"])
        syncShellExec(path: scriptPath, args: ["_checkpass_initial"])
        
        let ocerror = UserDefaults.standard.string(forKey: "OcError")
        if ocerror == "Yes"{
            UserDefaults.standard.removeObject(forKey: "OcError")
            self.egg1.isEnabled=false
            self.egg2.isEnabled=false
            self.egg3.isEnabled=false
            self.egg4.isEnabled=false
            self.app_logo.isHidden=true
            self.surprise_xmas.isHidden=true
            self.surprise_newyear.isHidden=true
        }
        
        let keychaincheck = UserDefaults.standard.bool(forKey: "Keychain")
        if keychaincheck == true{
            keychainyes.isHidden = false
            keychainno.isHidden = true
            key_no_button.isHidden=false
            key_yes_button.isHidden=true
            
            let admincheck = UserDefaults.standard.string(forKey: "Admin")
            
            if admincheck == "Yes"{
                let keychain = KeychainSwift()
                let chaincheck = keychain.get("Kext Updater")
                if chaincheck == nil{
                    //let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                }
                
                let passcheck = UserDefaults.standard.string(forKey: "Passwordok")
                if passcheck == "No"{
                    //let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                }
            } else {
                keychainyes.isHidden = true
                keychainno.isHidden = false
            }
        }
        
        checkefi()

        UserDefaults.standard.set("None", forKey: "EFI Creator")
        
        let tmpnotify = UserDefaults.standard.string(forKey: "Notifications")
        if tmpnotify == nil{
            UserDefaults.standard.set("NO", forKey: "Notifications")
        }
        
        let tmpnotifyseconds = UserDefaults.standard.string(forKey: "NotificationSeconds")
        if tmpnotifyseconds == nil{
            UserDefaults.standard.set("3", forKey: "NotificationSeconds")
        }
        
        let chimeinit = UserDefaults.standard.string(forKey: "Chime")
        if chimeinit == "0"{
            UserDefaults.standard.set("00,0000000000000000", forKey: "Speakervolume")
            UserDefaults.standard.set(true, forKey: "Chime")
        } else if chimeinit == nil{
            UserDefaults.standard.set("30,0000000000000000", forKey: "Speakervolume")
            UserDefaults.standard.set(true, forKey: "Chime")
        }
        
        let speakervolume = UserDefaults.standard.string(forKey: "Speakervolume")
        if speakervolume == nil{
            UserDefaults.standard.set("00,0000000000000000", forKey: "Speakervolume")
        }
        
        let osBuild = ProcessInfo.processInfo.operatingSystemVersionString
        if let range = osBuild.range(of: "Build ") {
            let osBuild2 = osBuild[range.upperBound...].replacingOccurrences(of: "\\)", with: "", options: .regularExpression) as String
            UserDefaults.standard.set(osBuild2, forKey: "OSBuild")
        }
        
        let kextupdaterversion : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        
        let dlpathinit = UserDefaults.standard.string(forKey: "Downloadpath")
        if dlpathinit == nil{
            let defaultdir = self.userDesktopDirectory + "/Desktop/Kext-Updates"
            UserDefaults.standard.set(defaultdir, forKey: "Downloadpath")
        }
        
        let backuppathinit = UserDefaults.standard.string(forKey: "Backuppath")
        if backuppathinit == nil{
            let defaultdir = self.userDesktopDirectory + "/Documents/EFI-Backup"
            UserDefaults.standard.set(defaultdir, forKey: "Backuppath")
        }
        
        let reportpathinit = UserDefaults.standard.string(forKey: "Reportpath")
        if reportpathinit == nil{
            let defaultdir = self.userDesktopDirectory + "/Desktop"
            UserDefaults.standard.set(defaultdir, forKey: "Reportpath")
            
        }
        
        let fontsizeinit = UserDefaults.standard.string(forKey: "Font Size")
        if fontsizeinit == nil{
            UserDefaults.standard.set("14", forKey: "Font Size")
        }
        
        let fontinit = UserDefaults.standard.string(forKey: "Font Family")
        if fontinit == nil{
            UserDefaults.standard.set("Menlo", forKey: "Font Family")
        }
        
        let fontcolorinit = UserDefaults.standard.string(forKey: "Font Color")
        if fontcolorinit == nil{
            UserDefaults.standard.set("0", forKey: "Font Color")
        }
        
        let urlcheck = UserDefaults.standard.string(forKey: "Updater URL")
        if urlcheck == nil{
            UserDefaults.standard.set("update.kextupdater.de", forKey: "Updater URL")
        }
        
        let lastcheck = UserDefaults.standard.string(forKey: "Last Check")
        if lastcheck == nil{
            UserDefaults.standard.set("Never", forKey: "Last Check")
        }
        
        let notifysecs = UserDefaults.standard.string(forKey: "NotificationSeconds")
        if notifysecs == nil{
            UserDefaults.standard.set("3", forKey: "NotificationSeconds")
        }
        
        let crtcheck = UserDefaults.standard.string(forKey: "CRT")
        if crtcheck == nil{
            UserDefaults.standard.set(false, forKey: "CRT")
        }
        
        let crtcheck2 = UserDefaults.standard.bool(forKey: "CRT")
        if crtcheck2 == true {
            self.crtview.isHidden = false
        } else {
            self.crtview.isHidden = true
        }
        
        let pcidb = UserDefaults.standard.string(forKey: "PCIDB")
        if pcidb == nil{
            UserDefaults.standard.set("0", forKey: "PCIDB")
        }
        
        let navlast = UserDefaults.standard.string(forKey: "NSNavLastRootDirectory")
        if navlast == nil{
            UserDefaults.standard.set("~/Downloads", forKey: "NSNavLastRootDirectory")
        }
        
        let bootloader_remember = UserDefaults.standard.string(forKey: "Bootloader_remember_choice")
        if bootloader_remember == nil{
            UserDefaults.standard.set(false, forKey: "Bootloader_remember_choice")
        }
 
        let lesle_init = UserDefaults.standard.string(forKey: "LESLE Warning Hide")
        if lesle_init == nil{
            UserDefaults.standard.set(false, forKey: "LESLE Warning Hide")
        }
        
        let authroot_init = UserDefaults.standard.string(forKey: "AuthRoot Warning Hide")
        if authroot_init == nil{
            UserDefaults.standard.set(false, forKey: "AuthRoot Warning Hide")
        }
 
        let multibeast_alert = UserDefaults.standard.string(forKey: "MuteMultibeastAlert")
        if multibeast_alert == nil{
            UserDefaults.standard.set(false, forKey: "MuteMultibeastAlert")
        }
        
        let pythonPath = "/usr/bin/python"
        if (FileManager.default.fileExists(atPath: pythonPath)) {
            UserDefaults.standard.set(true, forKey: "PythonInstalled")
        } else {
            UserDefaults.standard.set(false, forKey: "PythonInstalled")
        }
        
        let rootcheck = UserDefaults.standard.string(forKey: "Admin")
        if rootcheck == "No"{
            infobox_admin_status_content_yes.isHidden = true
            infobox_admin_status_content_no.isHidden = false
            report_button.isEnabled = false
            infobox_admin_status_image_red.isHidden = false
            infobox_admin_status_image_green.isHidden = true
            tools_button.isEnabled = false
        } else if rootcheck == "Yes"{
            infobox_admin_status_content_yes.isHidden = false
            infobox_admin_status_content_no.isHidden = true
            report_button.isEnabled = true
            infobox_admin_status_image_red.isHidden = true
            infobox_admin_status_image_green.isHidden = false
            tools_button.isEnabled = true
        }
        
        UserDefaults.standard.set(kextupdaterversion, forKey: "KUVersion")
        UserDefaults.standard.removeObject(forKey: "Load Single Kext")
        UserDefaults.standard.removeObject(forKey: "Webdriver Build")
        UserDefaults.standard.set("Update", forKey: "Choice")
        UserDefaults.standard.removeObject(forKey: "Sourceurl")
        UserDefaults.standard.removeObject(forKey: "Sourceurlbl")
        UserDefaults.standard.removeObject(forKey: "Sourceurlobs")
        UserDefaults.standard.removeObject(forKey: "Bootloaderkind")
        UserDefaults.standard.set(Locale.current.languageCode, forKey: "Language")
        UserDefaults.standard.set(NSFullUserName(), forKey: "Full Name")
        UserDefaults.standard.set(NSUserName(), forKey: "User Name")
        
        let downloadpath = UserDefaults.standard.string(forKey: "Downloadpath")
        folder_download_path.stringValue = (downloadpath ?? "")
        
        let osbuildread = UserDefaults.standard.string(forKey: "OSBuild")
        let osversionread = UserDefaults.standard.string(forKey: "OSVersion")
        let osinfos = String(osversionread ?? "") + String (" (") + String(osbuildread ?? "") + String (")")
        UserDefaults.standard.set(String(osinfos), forKey: "InfoBoxOSVersion")
        infobox_system_version.stringValue = (osinfos)
        
        UserDefaults.standard.set(String(getpid()), forKey: "Pid")
        
        let keychaincheck2 = UserDefaults.standard.bool(forKey: "Keychain")
        if keychaincheck2 == true{
            keychainyes.isHidden = false
            keychainno.isHidden = true
            key_no_button.isHidden=false
            key_yes_button.isHidden=true
        }
        if keychaincheck2 == false{
            keychainyes.isHidden = true
            keychainno.isHidden = false
            key_no_button.isHidden=true
            key_yes_button.isHidden=false
        }
        
        let keychainadvise = UserDefaults.standard.string(forKey: "KeyChainAdvise")
        if keychainadvise == nil{
            self.keychain_text.isHidden=false
            self.keychain_pfeil.isHidden=false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.keychain_text.isHidden=true
                        self.keychain_pfeil.isHidden=true
                        UserDefaults.standard.set(true, forKey: "KeyChainAdvise")
                }
            }

        let leslewarning = UserDefaults.standard.bool(forKey: "LESLE Warning")
        
        let leslewarninghide = UserDefaults.standard.bool(forKey: "LESLE Warning Hide")
        if leslewarninghide == false{
            if leslewarning == true {
                self.show_lesle_warning.performClick(nil)
        }

        }
        
        let mbCheck = "/Library/PrivilegedHelperTools/com.tonymacx86.InstallHelper"
        if (FileManager.default.fileExists(atPath: mbCheck)) {
            let mute_multibeast_alert = UserDefaults.standard.bool(forKey: "MuteMultibeastAlert")
            if mute_multibeast_alert == false{
                self.mb_detected.isHidden=false
                output_window.string = NSLocalizedString("Found a reference to multibeast!\n/Library/PrivilegedHelperTools/com.tonymacx86.InstallHelper", comment: "")
            }
        }
        
        let fontsize = CGFloat(UserDefaults.standard.float(forKey: "Font Size"))
        let fontfamily = UserDefaults.standard.string(forKey: "Font Family")
        output_window.font = NSFont(name: fontfamily!, size: fontsize)

        let fontcolor = UserDefaults.standard.string(forKey: "Font Color")
        if fontcolor == "2" {
            output_window.textColor = NSColor.green
        } else if fontcolor == "3" {
            output_window.textColor = NSColor.red
        } else if fontcolor == "4" {
            output_window.textColor = NSColor.orange
        } else if fontcolor == "5" {
            output_window.textColor = NSColor.yellow
        } else if fontcolor == "0" {
            output_window.textColor = NSColor.textColor
        }
        
        let fontpt = CGFloat(UserDefaults.standard.float(forKey: "Font Size"))
        let fontfam = UserDefaults.standard.string(forKey: "Font Family")
        output_window.font = NSFont(name: fontfam!, size: fontpt)
        
    }
    
    @IBAction func start_button(_ sender: Any) {
        self.egg1.isEnabled=false
        self.egg2.isEnabled=false
        self.egg3.isEnabled=false
        self.egg4.isEnabled=false

        self.syncShellExec(path: self.scriptPath, args: ["_online_check"])
        let networkerror = UserDefaults.standard.string(forKey: "Networkerror")
        
        if networkerror == "Yes" {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Uh Oh! An error has occured.", comment: "")
            alert.informativeText = NSLocalizedString("You are not connected to the Internet or the Server is not reachable at the moment. Please try again later.", comment: "")
            alert.alertStyle = .warning
            alert.icon = NSImage(named: "notapplied")
            let Button = NSLocalizedString("Bummer", comment: "")
            alert.addButton(withTitle: Button)
            alert.runModal()
            return
        }
        
//        if let url = URL(string: "https://update.kextupdater.de/online") {
//            do {
//                print(url)
//                if try String(contentsOf: url) != "1\n"{
//                    return
//                }
//            } catch {
//                self.show_networkerror.performClick(nil)
//                return
//                //DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    //self.show_networkerror.performClick(nil)
//                //}
//            }
//        }
        
        start_button.isEnabled=false
        start_button.isHidden=true
        stop_button.isHidden=false
        kexts_button.isEnabled=false
        webdriver_button.isEnabled=false
        bootloader_button.isEnabled=false
        report_button.isEnabled=false
        efi_backup_button.isEnabled=false
        efi_button.isEnabled=false
        footer_efi_image_eject.isEnabled=false
        footer_efi_image_red.isEnabled=false
        footer_efi_image_green.isEnabled=false
        footer_efi_diskinfo_click.isEnabled=false
        tools_button.isEnabled=false
                output_window.textStorage?.mutableString.setString("")
        app_logo.isHidden = true
        surprise_xmas.isHidden = true
        surprise_snow.isHidden = true
        surprise_newyear.isHidden = true

        
        animstart()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM.yyyy, HH:mm:ss"
        let result = formatter.string(from: date)

        //output_window.textStorage?.mutableString.setString("")
        
        DispatchQueue.global(qos: .background).async {
            
            let choicecheck = UserDefaults.standard.string(forKey: "Choice")
            if choicecheck == "Single" {
            self.syncShellExec(path: self.scriptPath, args: ["massdownload"])
                for key in UserDefaults.standard.dictionaryRepresentation().keys {
                    if key.hasPrefix("dl-"){
                        UserDefaults.standard.removeObject(forKey: key)
                }
                }
            }

            let oc_config_check = UserDefaults.standard.bool(forKey: "OCConfigCheck")
            let offline_efi = UserDefaults.standard.bool(forKey: "OfflineEFI")
            let custom_efi = UserDefaults.standard.bool(forKey: "CustomEFI")
            if offline_efi == true{
                self.syncShellExec(path: self.scriptPath, args: ["_offline_efi"])
            } else if custom_efi == true{
                self.syncShellExec(path: self.scriptPath, args: ["_custom_efi"])
            } else if oc_config_check == true{
                self.syncShellExec(path: self.scriptPath, args: ["_check_oc_config"])
                for key in UserDefaults.standard.dictionaryRepresentation().keys {
                    if key.hasPrefix("OCC"){
                        UserDefaults.standard.removeObject(forKey: key)
                }
                }
            } else {
                let checklast = UserDefaults.standard.string(forKey: "Last Check")
                    if checklast != "Never"{
                    UserDefaults.standard.set(checklast, forKey: "Last Check")
                    }
                let lastcheck = (result as String)
                self.syncShellExec(path: self.scriptPath, args: ["mainscript"])
                UserDefaults.standard.set(lastcheck, forKey: "Last Check")
            }

            DispatchQueue.main.async {
                self.start_button.isEnabled=true
                self.start_button.isHidden=false
                self.stop_button.isHidden=true
                self.kexts_button.isEnabled=true
                self.webdriver_button.isEnabled=true
                self.bootloader_button.isEnabled=true
                self.report_button.isEnabled=true
                self.efi_backup_button.isEnabled=true
                self.efi_button.isEnabled=true
                self.tools_button.isEnabled=true
                self.footer_efi_image_eject.isEnabled=true
                self.footer_efi_image_red.isEnabled=true
                self.footer_efi_image_green.isEnabled=true
                self.footer_efi_diskinfo_click.isEnabled=true
                self.animstop()
                
                UserDefaults.standard.set("Update", forKey: "Choice")
                
                //self.syncShellExec(path: self.scriptPath, args: ["_cleanup"])
            }
        }
        
        let hint = UserDefaults.standard.string(forKey: "HintShown")
        if hint == nil {
            UserDefaults.standard.set(true, forKey: "HintShown")
            self.show_hint.performClick(nil)
        }

    }
    
    @IBAction func stop_button(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "OfflineEFI")
        UserDefaults.standard.set(false, forKey: "CustomEFI")
        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["stop_execution"])
                DispatchQueue.main.async {
            }
        }
    }
    
    
    @IBAction func footer_efi_efimount_bt(_ sender: NSButton) {
        sender.isEnabled = false
        DispatchQueue.global(qos: .background).async {
	
            self.syncShellExec(path: self.scriptPath, args: ["mountefi"])

            DispatchQueue.main.async {
                sender.isEnabled = true
                self.checkefi()
                let efi_mounted = UserDefaults.standard.string(forKey: "EFI Path")
                if efi_mounted == "" {
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("Boot EFI Volume not found!", comment: "")
                    alert.informativeText = NSLocalizedString("The volume containing the Boot EFI is no longer available in the system. Please connect the device to the computer and try again.", comment: "")
                    alert.alertStyle = .informational
                    alert.icon = NSImage(named: "NSError")
                    let Button = NSLocalizedString("Ok", comment: "")
                    alert.addButton(withTitle: Button)
                    alert.runModal()
                }
            }
        }
    }
    
    @IBAction func folder_download_open(_ sender: Any) {
        let downloadpath = UserDefaults.standard.string(forKey: "Downloadpath")
        //let url = URL(fileURLWithPath: downloadpath ?? "")
        do {
            try FileManager.default.contentsOfDirectory(atPath: downloadpath ?? "")
        } catch _ {
            print("")
        }
        
        let downloadpath2 = UserDefaults.standard.string(forKey: "Downloadpath")
        NSWorkspace.shared.openFile(downloadpath2 ?? "")
    }
    
    @IBAction func folder_efi_open(_ sender: Any) {
        let efipath = UserDefaults.standard.string(forKey: "EFI Path")
        //let url = URL(fileURLWithPath: efipath ?? "")
        do {
            try FileManager.default.contentsOfDirectory(atPath: efipath ?? "")
        } catch _ {
            print("")
        }
        
        let efipath2 = UserDefaults.standard.string(forKey: "EFI Path")
        NSWorkspace.shared.openFile(efipath2 ?? "")
    }
    
    @IBAction func efi_backup(_ sender: NSButton) {
        
        self.animstart()
        
        output_window.textStorage?.mutableString.setString("")
        app_logo.isHidden = true
        surprise_xmas.isHidden = true
        surprise_newyear.isHidden = true
        
        start_button.isEnabled=false
        start_button.isHidden=true
        stop_button.isHidden=false
        kexts_button.isEnabled=false
        webdriver_button.isEnabled=false
        bootloader_button.isEnabled=false
        report_button.isEnabled=false
        efi_backup_button.isEnabled=false
        efi_button.isEnabled=false
        footer_efi_image_eject.isEnabled=false
        footer_efi_image_red.isEnabled=false
        footer_efi_image_green.isEnabled=false
        footer_efi_diskinfo_click.isEnabled=false
        tools_button.isEnabled=false
                output_window.textStorage?.mutableString.setString("")
        app_logo.isHidden = true
        surprise_xmas.isHidden = true
        surprise_newyear.isHidden = true

        sender.isEnabled = false
            DispatchQueue.global(qos: .background).async {
 
                self.syncShellExec(path: self.scriptPath, args: ["efi_backup"])
 
                DispatchQueue.main.async {
                    let efi_mounted = UserDefaults.standard.string(forKey: "EFI Path")
                    if efi_mounted == "" {
                        let alert = NSAlert()
                        alert.messageText = NSLocalizedString("Boot EFI Volume not found!", comment: "")
                        alert.informativeText = NSLocalizedString("The volume containing the Boot EFI is no longer available in the system. Please connect the device to the computer and try again.", comment: "")
                        alert.alertStyle = .informational
                        alert.icon = NSImage(named: "NSError")
                        let Button = NSLocalizedString("Ok", comment: "")
                        alert.addButton(withTitle: Button)
                        alert.runModal()
                        self.syncShellExec(path: self.scriptPath, args: ["stop_execution"])
                    }
                    sender.isEnabled = true
                    self.checkefi()
                    self.start_button.isEnabled=true
                    self.start_button.isHidden=false
                    self.stop_button.isHidden=true
                    self.kexts_button.isEnabled=true
                    self.webdriver_button.isEnabled=true
                    self.bootloader_button.isEnabled=true
                    self.report_button.isEnabled=true
                    self.efi_backup_button.isEnabled=true
                    self.efi_button.isEnabled=true
                    self.tools_button.isEnabled=true
                    self.footer_efi_image_eject.isEnabled=true
                    self.footer_efi_image_red.isEnabled=true
                    self.footer_efi_image_green.isEnabled=true
                    self.animstop()
                }
            }
    }
    
    
    @IBAction func report(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Do you want to create a system report right now?", comment: "")
        alert.informativeText = NSLocalizedString("This could take some time. You can abort it every time.", comment: "")
        alert.alertStyle = .informational
        alert.icon = NSImage(named: "NSInfo")
        let Button = NSLocalizedString("Yes", comment: "")
        alert.addButton(withTitle: Button)
        let CancelButtonText = NSLocalizedString("No", comment: "")
        alert.addButton(withTitle: CancelButtonText)
        
        if alert.runModal() == .alertFirstButtonReturn {
            
            output_window.textStorage?.mutableString.setString("")
            start_button.isEnabled=false
            stop_button.isEnabled=true
            stop_button.isHidden=false
            kexts_button.isEnabled=false
            webdriver_button.isEnabled=false
            bootloader_button.isEnabled=false
            report_button.isEnabled=false
            self.efi_backup_button.isEnabled=false
            efi_button.isEnabled=false
            tools_button.isEnabled=false
            animstart()
            
            app_logo.isHidden=true
            surprise_xmas.isHidden=true
            surprise_newyear.isHidden=true
            UserDefaults.standard.set("Report", forKey: "Choice")
            
            DispatchQueue.global(qos: .background).async {
                self.syncShellExec(path: self.scriptPath, args: ["htmlreport"])
                
                DispatchQueue.main.async {
                    self.start_button.isEnabled=true
                    self.stop_button.isEnabled=false
                    self.stop_button.isHidden=true
                    self.kexts_button.isEnabled=true
                    self.webdriver_button.isEnabled=true
                    self.bootloader_button.isEnabled=true
                    self.report_button.isEnabled=true
                    self.efi_backup_button.isEnabled=true
                    self.efi_button.isEnabled=true
                    self.tools_button.isEnabled=true
                    self.animstop()
                    UserDefaults.standard.set("Update", forKey: "Choice")
                    
                }
            }
        }
     }
    
    @IBAction func paypal_button(_ sender: Any) {
        if let url = URL(string: "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=paypal@sl-soft.de&item_name=Kext-Updater&currency_code=EUR"),
            NSWorkspace.shared.open(url) {
        }
    }
    
    /**
     * Performs an "asynchronous" shell exec with non blocking UI thread
     */
    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        let filelHandler       = outputPipe.fileHandleForReading
        process.standardOutput = outputPipe
        
        let group = DispatchGroup()
        group.enter()
        filelHandler.readabilityHandler = { pipe in
            let data = pipe.availableData
            if data.isEmpty { // EOF
                filelHandler.readabilityHandler = nil
                group.leave()
                return
            }
            if let line = String(data: data, encoding: String.Encoding.utf8) {
                DispatchQueue.main.sync {
                    self.output_window.string += line
                    self.output_window.scrollToEndOfDocument(nil)
                }
            } else {
                print("Error decoding data: \(data.base64EncodedString())")
            }
        }
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }
 
    @IBAction func keychain_question_yes(_ sender: Any) {
        keychainyes.isHidden = false
        keychainno.isHidden = true
        UserDefaults.standard.set(true, forKey: "Keychain")
        keychainyes.isHidden = false
        keychainno.isHidden = true
        //keychainquestion.setIsVisible(false)
        let admincheck = UserDefaults.standard.string(forKey: "Admin")
        
        if admincheck == "Yes"{
            
            let keychain = KeychainSwift()
            let chaincheck = keychain.get("Kext Updater")
            if chaincheck == nil{
                //let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                //pwdusername.stringValue = (rootuserfull ?? "")
                //pwdwindow.setIsVisible(true)
            }
            
            syncShellExec(path: scriptPath, args: ["_checkpass"])
            
            let passcheck = UserDefaults.standard.string(forKey: "Passwordok")
            if passcheck == "No"{
                //let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                //pwdusername.stringValue = (rootuserfull ?? "")
                //pwdwindow.setIsVisible(true)
            }
        }
        keychainyes.isHidden = false
        keychainno.isHidden = true
    }
    
    @IBAction func keychain_question_no(_ sender: Any) {
        key_yes_button.isHidden=false
        key_no_button.isHidden=true
        UserDefaults.standard.set(false, forKey: "Keychain")
        let keychain = KeychainSwift()
        let chaincheck = keychain.get("Kext Updater")
        if chaincheck != nil{
        keychain.delete("Kext Updater")
        }
        //keychainquestion.setIsVisible(false)
        keychainyes.isHidden = true
        keychainno.isHidden = false
        
    }
    
    @IBAction func bug_report_click_sendmail(_ sender: Any) {
        let plist1 = self.userDesktopDirectory + "/Library/Preferences/kextupdater.slsoft.de.plist"
        let plist2 = self.userDesktopDirectory + "/Library/Preferences/kextupdaterhelper.slsoft.de.plist"
        let bdmesg = self.userDesktopDirectory + "/.ku_temp/bdmesg.txt"
        
        let bootloader = UserDefaults.standard.string(forKey: "Bootloader")
        if (bootloader?.contains("Open"))! {
            syncShellExec(path: scriptPath, args: ["bug_report"])
        }
        
        let email = "bug@kextupdater.de"

        let fileURL1 = URL(fileURLWithPath: bdmesg)
        let fileURL2 = URL(fileURLWithPath: plist1)
        let fileURL3 = URL(fileURLWithPath: plist2)
        
        let sharingService = NSSharingService(named: NSSharingService.Name.composeEmail)
        sharingService?.recipients = [email]
        sharingService?.subject = "Kext Updater Bug Report"
        let items: [Any] = ["Bug Report", fileURL1, fileURL2, fileURL3]
       
        sharingService?.perform(withItems: items)
    }
    
    /**
     * Get Users System Home
     */
    func userDesktop() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
        let userDesktopDirectory = paths[0]
        return userDesktopDirectory
    }
    let userDesktopDirectory:String = NSHomeDirectory()

    /**
     * Checks if EFI is mounted
     */
    func checkefi() {
        let bootloaderpath = UserDefaults.standard.string(forKey: "EFI Path")
        let mounted = UserDefaults.standard.string(forKey: "Mounted")
        if mounted == "Yes"{
            //footer_efi_efimount_bt.title = "efimounted".localized()
            footer_efi_image_green.isHidden = false
            footer_efi_image_eject.isHidden = false
            footer_efi_diskinfo_click.isHidden = false
            folder_efi_icon.isEnabled = true
            folder_efi_path.stringValue = (bootloaderpath ?? "")
        } else {
            //footer_efi_efimount_bt.title = "efinotmounted".localized()
            footer_efi_image_red.isHidden = false
            footer_efi_image_green.isHidden = true
            footer_efi_image_eject.isHidden = true
            footer_efi_diskinfo_click.isHidden = true
            folder_efi_icon.isEnabled = false
            folder_efi_path.stringValue = ("")
        }
    }
    
    override func awakeFromNib() {
    }
    
    @objc private func pressStartbutton(notification: NSNotification){
        start_button.performClick(nil)
    }
    
    @objc private func pressAuthRoot(notification: NSNotification){
    self.show_auth_root.performClick(nil)
    }
    
    @objc private func AppShutdown(notification: NSWorkspace){
        NSApp.stop(nil)
    }
    
    @objc private func doRefreshKeychain(notification: NSNotification){
        let keychaincheck = UserDefaults.standard.bool(forKey: "Keychain")
        if keychaincheck == true {
            keychainyes.isHidden = false
            keychainno.isHidden = true
            key_no_button.isHidden=false
            key_yes_button.isHidden=true
        }
     }
    
    @objc private func closePrefs(notification: NSNotification){
        let crt = UserDefaults.standard.bool(forKey: "CRT")
        if crt == true{
            self.crtview.isHidden=false
        } else if crt == false{
            self.crtview.isHidden=true
        }
    }
    
    @IBAction func egg1(_ sender: Any) {
        self.chime1()
    }
    
    @IBAction func egg2(_ sender: Any) {
        self.chime2()
    }
    
    @IBAction func egg3(_ sender: Any) {
        self.chime3()
    }
    
    @IBAction func egg4(_ sender: Any) {
        self.chime4()
    }
    
    /**
     * plays a chime sound
     */
    func chime() -> Void {
        let url = Bundle.main.url(forResource: "sounds/done", withExtension: "mp3")!
        do {
            player           = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /**
     * plays a chime2 sound
     */
    func chime1() -> Void {
        let url = Bundle.main.url(forResource: "sounds/mq", withExtension: "mp3")!
        do {
            player           = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /**
     * plays a chime3 sound
     */
    func chime2() -> Void {
        let url = Bundle.main.url(forResource: "sounds/pm52", withExtension: "mp3")!
        do {
            player           = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func chime3() -> Void {
        let url = Bundle.main.url(forResource: "sounds/ta", withExtension: "mp3")!
        do {
            player           = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func chime4() -> Void {
        let url = Bundle.main.url(forResource: "sounds/quadra", withExtension: "mp3")!
        do {
            player           = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /**
     * plays a chimedeath sound
     */
    func chimedeath() -> Void {
        let url = Bundle.main.url(forResource: "sounds/quadradeath", withExtension: "mp3")!
        do {
            player           = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func animstart() -> Void {
        self.app_logo_animation.isHidden=false
        self.app_logo_animation.startAnimation("")
    }
    
    func animstop() -> Void {
        self.app_logo_animation.isHidden=true
        self.app_logo_animation.stopAnimation("")
    }
    
    @objc func updatecheck() {
        let refreshtime = UserDefaults.standard.string(forKey: "Refreshtime")
        if refreshtime == "Yes" {
            self.checkefi()
            UserDefaults.standard.set("No", forKey: "Refreshtime")
        }
    }
}
