//
//  AppDelegate.swift
//  Kext Updater
//
//  Created by Sascha_77 on 18.05.18.
//  Copyright 2019 Sascha_77. All rights reserved.
//

import Cocoa
import AVFoundation
import macOSThemeKit
import KeychainSwift
import APNGKit
import LetsMove

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "MainMenu") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var process:Process!
    var out:FileHandle?
    var outputTimer: Timer?
    
    var player: AVAudioPlayer?
    
    // ########## Main Window ##########
    @IBOutlet weak var mainwindow: NSWindow!
    @IBOutlet var logger:       NSTextView!

    // Top Radio Button Section
    @IBOutlet weak var check_for_updates_rb: NSButton!
    @IBOutlet weak var create_support_report_rb: NSButton!
    // Top Radio Button Section - End
    
    // Top Pulldown Menus Section
    @IBOutlet weak var exclude_kexts_bt: NSButton!
    @IBOutlet weak var exclude_kexts_wd: NSWindow!
    @IBOutlet weak var load_group_kexts_pd: NSPopUpButton!
    @IBOutlet weak var load_single_kext_pd: NSPopUpButton!
    @IBOutlet weak var load_single_kext_url: NSButton!
    @IBOutlet weak var load_single_kext_icon_light: NSImageView!
    @IBOutlet weak var load_single_kext_icon_dark: NSImageView!
    @IBOutlet weak var load_webdriver_pd: NSPopUpButton!
    @IBOutlet weak var load_bootloader_icon_light: NSImageView!
    @IBOutlet weak var load_bootloader_icon_dark: NSImageView!
    @IBOutlet weak var load_bootloader_pd: NSPopUpButton!
    @IBOutlet weak var load_bootloader_url: NSButton!
    // Top Pulldown Menus Section - End
    
    // Infobox
    @IBOutlet weak var infobox_system_version: NSTextField!
    @IBOutlet weak var infobox_admin_status_image_red: NSImageView!
    @IBOutlet weak var infobox_admin_status_image_green: NSImageView!
    @IBOutlet weak var infobox_admin_status_content_yes: NSTextField!
    @IBOutlet weak var infobox_admin_status_content_no: NSTextField!
    // Infobox - End

    // App Logo
    @IBOutlet weak var app_logo_animation: NSButton!
    @IBOutlet weak var app_logo_light: NSImageView!
    @IBOutlet weak var app_logo_dark: NSImageView!
    // App Logo - End
    
    // Folder Section
    @IBOutlet weak var folder_efi_icon: NSButton!
    @IBOutlet weak var folder_efi_path: NSTextField!
    @IBOutlet weak var folder_download_icon: NSButton!
    @IBOutlet weak var folder_download_path: NSTextField!
    @IBOutlet weak var folder_bug_report_image_light: NSImageView!
    @IBOutlet weak var folder_bug_report_image_dark: NSImageView!
    // Folder Section - End
    
    // Footer Section
    @IBOutlet weak var footer_efi_efimount_bt: NSButton!
    @IBOutlet weak var footer_efi_image_red: NSImageView!
    @IBOutlet weak var footer_efi_image_green: NSImageView!
    @IBOutlet weak var footer_efi_image_info: NSImageView!
    @IBOutlet weak var footer_efi_diskinfo_click: NSButton!
    // Footer Section - End

    //  Security Window
    @IBOutlet weak var security_window: NSWindow!
    @IBOutlet weak var cacherebuild_yes_bt: NSButton!
    @IBOutlet weak var atheros_yes_bt: NSButton!
    @IBOutlet weak var sleepfix_yes_bt: NSButton!
    //  Security Window - End
    
    // ########## Main Window - End ##########
    

    
    
    
    
    
    @IBOutlet weak var fileb: NSTextField!
    @IBOutlet weak var tempb: NSTextField!
    

    
    
    


    @IBOutlet weak var diskwindow: NSPanel!
    @IBOutlet weak var diskwindowmountpoint: NSTextField!
    @IBOutlet weak var diskwindowuuid: NSTextField!
    @IBOutlet weak var diskwindowdevicelocation: NSTextField!
    @IBOutlet weak var diskwindowremovablemedia: NSTextField!
    @IBOutlet weak var diskwindowprotocol: NSTextField!
    @IBOutlet weak var diskwindowsolidstate: NSTextField!
    @IBOutlet weak var diskwindowdrivemodel: NSTextField!
    @IBOutlet weak var imagessd: NSImageView!
    @IBOutlet weak var imagehd: NSImageView!
    @IBOutlet weak var imageusbstick: NSImageView!
    @IBOutlet weak var imageusbhd: NSImageView!


    @IBOutlet weak var applogoabout: NSImageView!
    @IBOutlet weak var applogodarkabout: NSImageView!
    @IBOutlet weak var kuversion: NSTextField!
    @IBOutlet weak var kuversion_about: NSTextField!
    @IBOutlet weak var help:         NSWindow!
    @IBOutlet weak var helpinfo: NSImageView!
    @IBOutlet weak var helpinfodark: NSImageView!
    @IBOutlet weak var aboutwindow: NSWindow!
    @IBOutlet weak var preferences: NSWindow!
    @IBOutlet weak var massdownload: NSWindow!

    @IBOutlet weak var extras: NSWindow!

    @IBOutlet weak var chimesound: NSButton!
    @IBOutlet weak var networkerror: NSWindow!



    @IBOutlet weak var crtview: NSImageView!
    @IBOutlet weak var atheros40notapplied: NSImageView!
    @IBOutlet weak var atheros40applied: NSImageView!
    @IBOutlet weak var atheros40_btn: NSButton!

    @IBOutlet weak var fixnotapplied: NSImageView!
    @IBOutlet weak var fixapplied: NSImageView!
    @IBOutlet weak var fixsleep: NSButton!
    @IBOutlet weak var btn_dl_obsolete: NSButton!
    @IBOutlet weak var btn_extras: NSButton!
    @IBOutlet weak var adminuser: NSMenuItem!
    @IBOutlet weak var pwdwindow: NSWindow!
    @IBOutlet weak var pwdusername: NSTextField!
    @IBOutlet weak var pwdpassword: NSSecureTextField!
    @IBOutlet weak var wrongpassword: NSWindow!
    @IBOutlet weak var passaccepted: NSTextField!
    @IBOutlet weak var passrefused: NSTextField!
    @IBOutlet weak var keychainquestion: NSWindow!
    @IBOutlet weak var keychainyes: NSImageView!
    @IBOutlet weak var keychainno: NSImageView!

    @IBOutlet weak var keychain: NSMenuItem!
    @IBOutlet weak var speakericon: NSImageView!
    @IBOutlet weak var speaker_icon_on_dark: NSImageView!
    @IBOutlet weak var speakericon_off: NSImageView!
    @IBOutlet weak var speaker_icon_off_dark: NSImageView!
    @IBOutlet weak var speakerslider: NSSlider!
    @IBOutlet weak var themeselector: NSPopUpButton!
    @IBOutlet weak var gatheringinfos: NSPanel!
    @IBOutlet weak var radio2empty: NSMenuItem!
    @IBOutlet weak var radio3empty: NSMenuItem!
    @IBOutlet weak var radio4empty: NSMenuItem!
    @IBOutlet weak var radio5empty: NSMenuItem!
    @IBOutlet weak var sourcesobsolete: NSImageView!
    @IBOutlet weak var sourcestargetobsolete: NSButton!





    @IBOutlet weak var tools_efi_pulldown: NSPopUpButton!
    @IBOutlet weak var tools_mount: NSButton!
    @IBOutlet weak var tools_unmount: NSButton!
    @IBOutlet weak var tools_unmountall: NSButton!
    @IBOutlet weak var tools_harddisk_icon: NSImageView!
    

    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        PFMoveToApplicationsFolderIfNecessary()
        
        gatheringinfos.setIsVisible(true)
        
        let keychaincheck = UserDefaults.standard.string(forKey: "Keychain")
        if keychaincheck == nil{
            keychainquestion.setIsVisible(true)
            keychainyes.isHidden = true
            keychainno.isHidden = false
        }
        
        let occheck = UserDefaults.standard.string(forKey: "OCChecked")
        if occheck == nil{
            UserDefaults.standard.removeObject(forKey: "OCChecked")
        }
      
        syncShellExec(path: scriptPath, args: ["initial"])

        if keychaincheck == "1"{
            keychainyes.isHidden = false
            keychainno.isHidden = true
        let admincheck = UserDefaults.standard.string(forKey: "Admin")
        
        if admincheck == "Yes"{
            let keychain = KeychainSwift()
            let chaincheck = keychain.get("Kext Updater")
            if chaincheck == nil{
                let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                pwdusername.stringValue = (rootuserfull ?? "")
                pwdwindow.setIsVisible(true)
            }
            
            syncShellExec(path: scriptPath, args: ["_checkpass"])
        
            let passcheck = UserDefaults.standard.string(forKey: "Passwordok")
            if passcheck == "No"{
                let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                pwdusername.stringValue = (rootuserfull ?? "")
                pwdwindow.setIsVisible(true)
            }
        } else {
            keychainyes.isHidden = true
            keychainno.isHidden = false
            }
        }
        
        /**
         * Decides which Mode will be used. Dark or Light.
         */
        let path = self.userDesktopDirectory + "/Library/Preferences/.GlobalPreferences.plist"
        let dictRoot = NSDictionary(contentsOfFile: path)
        if let dict = dictRoot{
            if (dict["AppleInterfaceStyle"] as? String) != nil {
                UserDefaults.standard.set("Dark", forKey: "System Theme")
            } else {
                UserDefaults.standard.set("Light", forKey: "System Theme")
            }
        }
        
        let themeinit = UserDefaults.standard.string(forKey: "Theme")
        if themeinit == nil{
            let darkmode = UserDefaults.standard.string(forKey: "System Theme")
            if darkmode == "Dark"{
                UserDefaults.standard.set("Dark", forKey: "Theme")
            }else {
                UserDefaults.standard.set("Light", forKey: "Theme")
            }
        }
        
        let theme = UserDefaults.standard.string(forKey: "Theme")
        if theme == "Light"{
            lighttheme()
        } else if theme == "Dark"{
            darktheme()
        } else if theme == "System"{
            let darkmode = UserDefaults.standard.string(forKey: "System Theme")
            if darkmode == "Dark"{
                darktheme()
                UserDefaults.standard.set("Dark", forKey: "Theme")
            } else {
                UserDefaults.standard.set("Light", forKey: "Theme")
                lighttheme()
            }
        }

        checkefi()
        
        let tmppathinit = UserDefaults.standard.string(forKey: "Temppath")
        if tmppathinit == nil{
            let defaultdir = "/tmp/kextupdater"
            UserDefaults.standard.set(defaultdir, forKey: "Temppath")
        }
 
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
        
        //let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        //let trimmedosVersion = osVersion.replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression)
        //let trimmedosVersion2 = trimmedosVersion.replacingOccurrences(of: "\\s?\\Version ", with: "", options: .regularExpression)
        //UserDefaults.standard.set(trimmedosVersion2, forKey: "OSVersion")

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
            //fileb.stringValue = (defaultdir)
            //folder_download_path.stringValue = (defaultdir)
        }
 
        let reportpathinit = UserDefaults.standard.string(forKey: "Reportpath")
        if reportpathinit == nil{
            let defaultdir = self.userDesktopDirectory + "/Desktop"
            UserDefaults.standard.set(defaultdir, forKey: "Reportpath")
            //reportp.stringValue = (defaultdir)
        }
        
        let fontsizeinit = UserDefaults.standard.string(forKey: "Font Size")
        if fontsizeinit == nil{
            UserDefaults.standard.set("15", forKey: "Font Size")
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
       
        let pcidb = UserDefaults.standard.string(forKey: "PCIDB")
        if pcidb == nil{
            UserDefaults.standard.set("0", forKey: "PCIDB")
        }

        let rootcheck = UserDefaults.standard.string(forKey: "Admin")
        if rootcheck == "No"{
            infobox_admin_status_content_yes.isHidden = true
            infobox_admin_status_content_no.isHidden = false
            footer_efi_efimount_bt.isEnabled = false
            btn_extras.isEnabled = false
            infobox_admin_status_image_red.isHidden = false
            create_support_report_rb.isEnabled = false
            infobox_admin_status_image_green.isHidden = true
        } else if rootcheck == "Yes"{
            infobox_admin_status_content_yes.isHidden = false
            infobox_admin_status_content_no.isHidden = true
            infobox_admin_status_image_green.isHidden = false
        }
        
        UserDefaults.standard.set(kextupdaterversion, forKey: "KUVersion")
        UserDefaults.standard.removeObject(forKey: "Load Single Kext")
        UserDefaults.standard.removeObject(forKey: "Webdriver Build")
        UserDefaults.standard.set("1", forKey: "Choice")
        UserDefaults.standard.removeObject(forKey: "Sourceurl")
        UserDefaults.standard.removeObject(forKey: "Sourceurlbl")
        UserDefaults.standard.removeObject(forKey: "Sourceurlobs")
        UserDefaults.standard.removeObject(forKey: "Bootloaderkind")
        UserDefaults.standard.set(Locale.current.languageCode, forKey: "Language")
        UserDefaults.standard.set(NSFullUserName(), forKey: "Full Name")
        UserDefaults.standard.set(NSUserName(), forKey: "User Name")
           
        let fontsize = CGFloat(UserDefaults.standard.float(forKey: "Font Size"))
        let fontfamily = UserDefaults.standard.string(forKey: "Font Family")
        logger.font = NSFont(name: fontfamily!, size: fontsize)

        let fontcolor = UserDefaults.standard.string(forKey: "Font Color")
        if fontcolor == "1" {
        logger.textColor = NSColor.green
        } else if fontcolor == "2" {
         logger.textColor = NSColor.red
        } else if fontcolor == "3" {
            logger.textColor = NSColor.orange
        } else if fontcolor == "4" {
            logger.textColor = NSColor.yellow
        }

        let downloadpath = UserDefaults.standard.string(forKey: "Downloadpath")
        folder_download_path.stringValue = (downloadpath ?? "")
        
        let osbuildread = UserDefaults.standard.string(forKey: "OSBuild")
        let osversionread = UserDefaults.standard.string(forKey: "OSVersion")
        let osinfos = String(osversionread ?? "") + String (" (") + String(osbuildread ?? "") + String (")")
        infobox_system_version.stringValue = (osinfos)
        
        let kuversionread = UserDefaults.standard.string(forKey: "KUVersion")
        kuversion.stringValue = String("v. ") + (kuversionread ?? "")
        kuversion_about.stringValue = (kuversionread ?? "")

        let crt = UserDefaults.standard.string(forKey: "CRT")
        if crt == "1" {
            self.crtview.isHidden = false
        } else if crt == "0" {
            self.crtview.isHidden = true
        }
 
        UserDefaults.standard.set(String(getpid()), forKey: "Pid")

        let keychaincheck2 = UserDefaults.standard.string(forKey: "Keychain")
        if keychaincheck2 == nil{
            keychainquestion.setIsVisible(true)
        }
        if keychaincheck2 == "0"{
            keychainyes.isHidden = true
            keychainno.isHidden = false
        }
        if keychaincheck2 == "1"{
            keychainyes.isHidden = false
            keychainno.isHidden = true
        }
        
        //syncShellExec(path: scriptPath, args: ["check_opencore_conf"])
        
        createtmp()
        
        gatheringinfos.setIsVisible(false)
   }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        self.removetmp()
    }
    
    @IBAction func check_for_updates(_ sender: NSButton) { // Checks by Tag which Radio-Button is pressed
         switch sender.tag {
        case 1: //Check for Updates
            load_bootloader_pd.setValue(false, forKey: "enabled")
            load_webdriver_pd.setValue(false, forKey: "enabled")
            load_single_kext_pd.setValue(false, forKey: "enabled")
            load_group_kexts_pd.setValue(false, forKey: "enabled")
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
            load_bootloader_url.isEnabled = false
            load_bootloader_pd.selectItem(at: 0)
            load_single_kext_pd.selectItem(at: 0)
            load_group_kexts_pd.selectItem(at: 0)
            load_webdriver_pd.selectItem(at: 0)
            load_bootloader_pd.selectItem(at: 0)
            break
        default:
            _ = "1"
        }
        switch sender.tag {
        case 2: //Load Group Kexts
            load_bootloader_pd.setValue(false, forKey: "enabled")
            load_webdriver_pd.setValue(false, forKey: "enabled")
            load_single_kext_pd.setValue(false, forKey: "enabled")
            load_group_kexts_pd.setValue(true, forKey: "enabled")
            load_group_kexts_pd.selectItem(at: 0)
            load_single_kext_pd.selectItem(at: 0)
            load_webdriver_pd.selectItem(at: 0)
            load_bootloader_pd.selectItem(at: 0)
            radio2empty.isHidden = true
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
            load_bootloader_url.isEnabled = false
            UserDefaults.standard.removeObject(forKey: "Load Single Kext")
            UserDefaults.standard.removeObject(forKey: "Webdriver Build")
            break
        default:
            _ = "1"
        }
        switch sender.tag {
        case 3: //Load Single Kext
            load_bootloader_pd.setValue(false, forKey: "enabled")
            load_webdriver_pd.setValue(false, forKey: "enabled")
            load_group_kexts_pd.setValue(false, forKey: "enabled")
            load_single_kext_pd.setValue(true, forKey: "enabled")
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
            load_bootloader_url.isEnabled = false
            load_group_kexts_pd.selectItem(at: 0)
            load_webdriver_pd.selectItem(at: 0)
            load_bootloader_pd.selectItem(at: 0)
            radio3empty.isHidden = true
            UserDefaults.standard.removeObject(forKey: "Webdriver Build")
            break
        default:
            _ = "1"
        }
        switch sender.tag {
        case 4: //Load Webdriver
            load_bootloader_pd.setValue(false, forKey: "enabled")
            load_single_kext_pd.setValue(false, forKey: "enabled")
            load_group_kexts_pd.setValue(false, forKey: "enabled")
            load_webdriver_pd.setValue(true, forKey: "enabled")
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
            load_bootloader_url.isEnabled = false
            load_single_kext_pd.selectItem(at: 0)
            load_group_kexts_pd.selectItem(at: 0)
            load_bootloader_pd.selectItem(at: 0)
            radio4empty.isHidden = true
            break
        default:
            _ = "1"
        }
        switch sender.tag {
        case 5: //Load Bootloader
            load_webdriver_pd.setValue(false, forKey: "enabled")
            load_single_kext_pd.setValue(false, forKey: "enabled")
            load_group_kexts_pd.setValue(false, forKey: "enabled")
            load_bootloader_pd.setValue(true, forKey: "enabled")
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
            load_bootloader_url.isEnabled = false
            load_single_kext_pd.selectItem(at: 0)
            load_group_kexts_pd.selectItem(at: 0)
            load_webdriver_pd.selectItem(at: 0)
            radio5empty.isHidden = true
            break
        default:
            _ = "1"
        }
        switch sender.tag {
        case 6: //Create Support Report
            load_bootloader_pd.selectItem(at: 0)
            load_bootloader_pd.setValue(false, forKey: "enabled")
            load_webdriver_pd.setValue(false, forKey: "enabled")
            load_single_kext_pd.setValue(false, forKey: "enabled")
            load_group_kexts_pd.setValue(false, forKey: "enabled")
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
            load_bootloader_url.isEnabled = false
            load_single_kext_pd.selectItem(at: 0)
            load_group_kexts_pd.selectItem(at: 0)
            load_webdriver_pd.selectItem(at: 0)
            load_bootloader_pd.selectItem(at: 0)
            break
        default:
            _ = "1"
        }
        
        let choicefunc = (sender as AnyObject).selectedCell()!.keyEquivalent
        UserDefaults.standard.set(choicefunc, forKey: "Choice")
    }
 
    @IBAction func exclude_kexts_wd(_ sender: Any) {
        exclude_kexts_wd.setIsVisible(true)
    }
    
    @IBAction func load_group_kext_help(_ sender: NSButton) {
        let darkmode = UserDefaults.standard.string(forKey: "Dark Mode")
        if darkmode == "Yes" {
            darktheme()
        } else if darkmode == "No" {
            lighttheme()
        }
        help.setIsVisible(true)
    }
    
    @IBAction func load_group_kexts_pd(_ sender: Any) {
        let choicefunc = (sender as AnyObject).selectedCell()!.tag
        UserDefaults.standard.set(choicefunc, forKey: "Choice")
    }

    @IBAction func load_single_kext_pd(_ sender: Any) {
        let massdl = (sender as AnyObject).selectedCell()!.tag
        if massdl == 9{
            massdownload.setIsVisible(true)
        }
        
        let kextname = (sender as AnyObject).selectedCell()!.title
        if kextname == ""{
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
        }
        if kextname.contains("- ") {
            load_single_kext_icon_dark.isEnabled = false
            load_single_kext_icon_light.isEnabled = false
            load_single_kext_url.isEnabled = false
        }
        if kextname == "ACPI Battery Manager"{
            UserDefaults.standard.set("acpibatterymanager", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-ACPI-Battery-Driver", forKey: "Sourceurl")
        }
        else if kextname == "AirportBrcmFixup"{
            UserDefaults.standard.set("airportbrcmfixup", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/AirportBrcmFixup", forKey: "Sourceurl")
        }
        else if kextname == "AppleALC"{
            UserDefaults.standard.set("applealc", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/AppleALC", forKey: "Sourceurl")
        }
        else if kextname == "AsusSMC"{
            UserDefaults.standard.set("asussmc", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/hieplpvip/AsusSMC", forKey: "Sourceurl")
        }
        else if kextname == "ATH9KFixup"{
            UserDefaults.standard.set("ath9kfixup", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/ath9kfixup", forKey: "Sourceurl")
        }
        else if kextname == "AtherosE2200Ethernet"{
            UserDefaults.standard.set("atherose2200ethernet", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/Mieze/AtherosE2200Ethernet", forKey: "Sourceurl")
        }
        else if kextname == "AtherosWiFiInjector"{
            UserDefaults.standard.set("atheroswifiinjector", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://www.hackintosh-forum.de/forum/thread/22322-atheros-wifi-injector-kext", forKey: "Sourceurl")
        }
        else if kextname == "BrcmPatchRam"{
            UserDefaults.standard.set("brcmpatchram", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-BrcmPatchRAM", forKey: "Sourceurl")
        }
        else if kextname == "BT4LEContinuityFixup"{
            UserDefaults.standard.set("bt4lecontinuityfixup", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/BT4LEContiunityFixup", forKey: "Sourceurl")
        }
        else if kextname == "CodecCommander"{
            UserDefaults.standard.set("codeccommander", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-eapd-codec-commander/overview", forKey: "Sourceurl")
        }
        else if kextname == "CPUFriend"{
            UserDefaults.standard.set("cpufriend", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/CPUFriend", forKey: "Sourceurl")
        }
        else if kextname == "FakePCIID"{
            UserDefaults.standard.set("fakepciid", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-fake-pci-id/overview", forKey: "Sourceurl")
        }
        else if kextname == "FakeSMC"{
            UserDefaults.standard.set("fakesmc", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-fakesmc-kozlek/overview", forKey: "Sourceurl")
        }
        else if kextname == "GenericUSBXHCI"{
            UserDefaults.standard.set("genericusbxhci", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Generic-USB3", forKey: "Sourceurl")
        }
        else if kextname == "HibernationFixup"{
            UserDefaults.standard.set("hibernationfixup", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/HibernationFixup", forKey: "Sourceurl")
        }
        else if kextname == "IntelMausi"{
            UserDefaults.standard.set("intelmausi", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/IntelMausi", forKey: "Sourceurl")
        }
        else if kextname == "IntelMausiEthernet"{
            UserDefaults.standard.set("intelmausiethernet", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-intel-network/overview", forKey: "Sourceurl")
        }
        else if kextname == "Lilu"{
            UserDefaults.standard.set("lilu", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/Lilu", forKey: "Sourceurl")
        }
        else if kextname == "LiluFriend"{
            UserDefaults.standard.set("lilufriend", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/PMheart/LiluFriend", forKey: "Sourceurl")
        }
        else if kextname == "NightShiftUnlocker"{
            UserDefaults.standard.set("nightshiftunlocker", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/0xFireWolf/NightShiftUnlocker", forKey: "Sourceurl")
        }
        else if kextname == "NoTouchID"{
            UserDefaults.standard.set("notouchid", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/al3xtjames/NoTouchID", forKey: "Sourceurl")
        }
        else if kextname == "NoVPAJpeg"{
            UserDefaults.standard.set("novpajpeg", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/vulgo/NoVPAJpeg", forKey: "Sourceurl")
        }
        else if kextname == "NullCpuPowerManagement"{
            UserDefaults.standard.set("nullcpupowermanagement", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/corpnewt/NullCPUPowerManagement", forKey: "Sourceurl")
        }
        else if kextname == "NullEthernet"{
            UserDefaults.standard.set("nullethernet", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Null-Ethernet", forKey: "Sourceurl")
        }
        else if kextname == "RealtekRTL8111"{
            UserDefaults.standard.set("realtekrtl8111", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/Mieze/RTL8111_driver_for_OS_X", forKey: "Sourceurl")
        }
        else if kextname == "RTCMemoryFixup"{
            UserDefaults.standard.set("rtcmemoryfixup", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/RTCMemoryFixup", forKey: "Sourceurl")
        }
        else if kextname == "SinetekRTSX"{
            UserDefaults.standard.set("sinetekrtsx", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/sinetek/Sinetek-rtsx", forKey: "Sourceurl")
        }
        else if kextname == "SystemProfilerMemoryFixup"{
            UserDefaults.standard.set("systemprofilermemoryfixup", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/Goldfish64/SystemProfilerMemoryFixup", forKey: "Sourceurl")
        }
        else if kextname == "TSCAdjustReset"{
            UserDefaults.standard.set("tscadjustreset", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/interferenc/TSCAdjustReset", forKey: "Sourceurl")
        }
        else if kextname == "USBInjectAll"{
            UserDefaults.standard.set("usbinjectall", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/os-x-usb-inject-all/overview", forKey: "Sourceurl")
        }
        else if kextname == "VirtualSMC"{
            UserDefaults.standard.set("virtualsmc", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/VirtualSMC", forKey: "Sourceurl")
        }
        else if kextname == "VoodooHDA"{
            UserDefaults.standard.set("voodoohda", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://sourceforge.net/projects/voodoohda", forKey: "Sourceurl")
        }
        else if kextname == "VoodooI2C"{
            UserDefaults.standard.set("voodooi2c", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/alexandred/VoodooI2C", forKey: "Sourceurl")
        }
        else if kextname == "VoodooPS2"{
            UserDefaults.standard.set("voodoops2", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/RehabMan/OS-X-Voodoo-PS2-Controller", forKey: "Sourceurl")
        }
        else if kextname == "VoodooSDHC"{
            UserDefaults.standard.set("voodoosdhc", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/OSXLatitude/EDP/tree/master/kextpacks/USB/VoodooSDHC", forKey: "Sourceurl")
        }
        else if kextname == "VoodooSMBus"{
            UserDefaults.standard.set("voodoosmbus", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/leo-labs/voodoosmbus", forKey: "Sourceurl")
        }
        else if kextname == "VoodooTSCSync"{
            UserDefaults.standard.set("voodootscsync", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/voodootscsync/overview", forKey: "Sourceurl")
        }
        else if kextname == "WhateverGreen"{
            UserDefaults.standard.set("whatevergreen", forKey: "Load Single Kext")
            sourcesicon()
            UserDefaults.standard.set("https://github.com/acidanthera/WhateverGreen", forKey: "Sourceurl")
        }
    }
 
    @IBAction func load_single_kext_url(_ sender: Any) {
        let targeturl = UserDefaults.standard.string(forKey: "Sourceurl")
        if let url = URL(string: targeturl ?? ""),
            NSWorkspace.shared.open(url) {
        }
    }
    
    @IBAction func load_bootloader_url(_ sender: Any) {
        let targeturl = UserDefaults.standard.string(forKey: "Sourceurl")
        if let url = URL(string: targeturl ?? ""),
            NSWorkspace.shared.open(url) {
        }
    }
    
    
    @IBAction func load_webdriver_pd(_ sender: AnyObject) {
        let webdriverbuild = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(webdriverbuild, forKey: "Webdriver Build")
    }
   
    @IBAction func load_bootloader_pd(_ sender: AnyObject) {
        let bootloaderkind = (sender as AnyObject).selectedCell()!.title
        UserDefaults.standard.set(bootloaderkind, forKey: "Bootloaderkind")
        
        let blname = (sender as AnyObject).selectedCell()!.title
        if blname == ""{
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_bootloader_url.isEnabled = false
            load_bootloader_url.isHidden = true
        }
        if blname.contains("- ") {
            load_bootloader_icon_dark.isEnabled = false
            load_bootloader_icon_light.isEnabled = false
            load_bootloader_url.isEnabled = false
            load_bootloader_url.isHidden = true
        }
        if blname == "Clover"{
            load_bootloader_icon_dark.isEnabled = true
            load_bootloader_icon_light.isEnabled = true
            load_bootloader_url.isEnabled = true
            load_bootloader_url.isHidden = false
            UserDefaults.standard.set("https://sourceforge.net/projects/cloverefiboot", forKey: "Sourceurl")
        }
        if blname == "Clover Nightly Build"{
            load_bootloader_icon_dark.isEnabled = true
            load_bootloader_icon_light.isEnabled = true
            load_bootloader_url.isEnabled = true
            load_bootloader_url.isHidden = false
            UserDefaults.standard.set("https://github.com/Dids/clover-builder/releases", forKey: "Sourceurl")
        }
        else if blname.contains("OpenCore"){
            load_bootloader_icon_dark.isEnabled = true
            load_bootloader_icon_light.isEnabled = true
            load_bootloader_url.isEnabled = true
            load_bootloader_url.isHidden = false
            UserDefaults.standard.set("https://github.com/acidanthera/OpenCorePkg", forKey: "Sourceurl")
        }
        else if blname.contains("Support"){
            load_bootloader_icon_dark.isEnabled = true
            load_bootloader_icon_light.isEnabled = true
            load_bootloader_url.isEnabled = true
            load_bootloader_url.isHidden = false
            UserDefaults.standard.set("https://github.com/acidanthera/AppleSupportPkg", forKey: "Sourceurl")
        }
        else if blname.contains("EFI"){
            load_bootloader_icon_dark.isEnabled = true
            load_bootloader_icon_light.isEnabled = true
            load_bootloader_url.isEnabled = true
            load_bootloader_url.isHidden = false
            UserDefaults.standard.set("https://sourceforge.net/projects/cloverefiboot", forKey: "Sourceurl")
        }
    }
    
    @IBAction func logo_open_hf_url(_ sender: Any) {
        if let url = URL(string: "https://www.hackintosh-forum.de"),
            NSWorkspace.shared.open(url) {
        }
    }
    
    @IBAction func egg1(_ sender: Any) {
        self.chime5()
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
    
    @IBAction func folder_efi_open(_ sender: Any) {
        let efipath = UserDefaults.standard.string(forKey: "EFI Path")
        let url = URL(fileURLWithPath: efipath ?? "")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch _ {
            print("")
        }
        
        let efipath2 = UserDefaults.standard.string(forKey: "EFI Path")
        NSWorkspace.shared.openFile(efipath2 ?? "")
    }
    
    @IBAction func folder_download_open(_ sender: Any) {
        let downloadpath = UserDefaults.standard.string(forKey: "Downloadpath")
        let url = URL(fileURLWithPath: downloadpath ?? "")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch _ {
            print("")
        }
        
        let downloadpath2 = UserDefaults.standard.string(forKey: "Downloadpath")
        NSWorkspace.shared.openFile(downloadpath2 ?? "")
    }
    
    @IBAction func bug_report_click_sendmail(_ sender: Any) {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients = ["bug@kextupdater.de"]
        service.subject = "Kext Updater Bug Report"
        service.perform(withItems: [""])
    }

    @IBAction func paypal_bt_donate(_ sender: Any) {
        if let url = URL(string: "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=paypal@sl-soft.de&item_name=Kext-Updater&currency_code=EUR"),
            NSWorkspace.shared.open(url) {
        }
    }
    
    @IBAction func footer_efi_efimount_bt(_ sender: NSButton) {
        sender.isEnabled = false
        syncShellExec(path: scriptPath, args: ["mountefi"])
        sender.isEnabled = true
        checkefi()
    }
    
    @IBAction func footer_diskinfo_wd(_ sender: Any) {
        let uuid = UserDefaults.standard.string(forKey: "EFI Root")
        let devicenode = UserDefaults.standard.string(forKey: "Device Node")?.prefix(10).replacingOccurrences(of: "/dev/", with: "").replacingOccurrences(of: "d", with: "D")
        let location = UserDefaults.standard.string(forKey: "Device Location")
        let removable = UserDefaults.standard.string(forKey: "Removable Media")
        let deviceprotocol = UserDefaults.standard.string(forKey: "Device Protocol")
        let solid = UserDefaults.standard.string(forKey: "Solid State")
        let model = UserDefaults.standard.string(forKey: "Drive Model")
        diskwindowuuid.stringValue = (uuid ?? "")
        diskwindowmountpoint.stringValue = String((devicenode ?? ""))
        diskwindowdevicelocation.stringValue = (location ?? "")
        diskwindowremovablemedia.stringValue = (removable ?? "")
        diskwindowprotocol.stringValue = (deviceprotocol ?? "")
        diskwindowsolidstate.stringValue = (solid ?? "")
        diskwindowdrivemodel.stringValue = (model ?? "")
        if deviceprotocol == "SATA"{
            if solid == "Yes"{
                imagessd.isHidden = false
            } else {
                imagehd.isHidden = false
            }
        }
        if deviceprotocol == "USB"{
            if removable == "Software-Activated"{
                imageusbstick.isHidden = false
            } else {
                imageusbhd.isHidden = false
            }
        }
        diskwindow.setIsVisible(true)
    }
    //FUCK
    
    
    
    @IBAction func keychainquestionyes(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "Keychain")
        keychainyes.isHidden = false
        keychainno.isHidden = true
        keychainquestion.setIsVisible(false)
        let admincheck = UserDefaults.standard.string(forKey: "Admin")
        
        if admincheck == "Yes"{
            
            let keychain = KeychainSwift()
            let chaincheck = keychain.get("Kext Updater")
            if chaincheck == nil{
                let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                pwdusername.stringValue = (rootuserfull ?? "")
                pwdwindow.setIsVisible(true)
            }
            
            syncShellExec(path: scriptPath, args: ["_checkpass"])
            
            let passcheck = UserDefaults.standard.string(forKey: "Passwordok")
            if passcheck == "No"{
                let rootuserfull = UserDefaults.standard.string(forKey: "RootuserFull")
                pwdusername.stringValue = (rootuserfull ?? "")
                pwdwindow.setIsVisible(true)
            }
        }
    }
 
    @IBAction func keychainquestionno(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "Keychain")
        let keychain = KeychainSwift()
        let chaincheck = keychain.get("Kext Updater")
        if chaincheck != nil{
        keychain.delete("Kext Updater")
        }
        keychainquestion.setIsVisible(false)
        keychainyes.isHidden = true
        keychainno.isHidden = false
        
    }
    
    @IBAction func keychainask(_ sender: Any) {
        keychainquestion.setIsVisible(true)
    }

    @IBAction func keychainaskmenu(_ sender: Any) {
        keychainquestion.setIsVisible(true)
    }
    
    @IBAction func getpassword(_ sender: Any) {
        password()
    }

    @IBAction func closegetpassword(_ sender: Any) {
        pwdwindow.setIsVisible(false)
    }
    
    @IBAction func closemenu(_ sender: Any) {
        self.removetmp()
    }
    @IBAction func close(_ sender: Any) {
        self.removetmp()
    }
    


    


    @IBAction func obsolete(_ sender: AnyObject) {
        let obsname = (sender as AnyObject).selectedCell()!.title
        if obsname == ""{
            sourcesobsolete.isEnabled = false
            sourcestargetobsolete.isEnabled = false
            btn_dl_obsolete.isEnabled = false
        }
 
        if obsname == "AppleBacklightFixup"{
            UserDefaults.standard.set("applebacklightfixup", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://bitbucket.org/RehabMan/applebacklightfixup", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "AzulPatcher4600"{
            UserDefaults.standard.set("azulpatcher4600", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/coderobe/AzulPatcher4600", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "CoreDisplayFixup"{
            UserDefaults.standard.set("coredisplayfixup", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/PMheart/CoreDisplayFixup", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "EnableLidWake"{
            UserDefaults.standard.set("enablelidwake", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/syscl/EnableLidWake", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "IntelGraphicsDVMTFixup"{
            UserDefaults.standard.set("intelgraphicsdvmtfixup", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/BarbaraPalvin/IntelGraphicsDVMTFixup", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "IntelGraphicsFixup"{
            UserDefaults.standard.set("intelgraphicsfixup", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/lvs1974/IntelGraphicsFixup", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "NoVPAJpeg"{
            UserDefaults.standard.set("novpajpg", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/vulgo/NoVPAJpeg", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "NvidiaGraphicsFixup"{
            UserDefaults.standard.set("nvidiagraphicsfixup", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/lvs1974/NvidiaGraphicsFixup", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        if obsname == "Shiki"{
            UserDefaults.standard.set("shiki", forKey: "Load Single Kext")
            sourcesiconobsolete()
            UserDefaults.standard.set("https://github.com/acidanthera/Shiki", forKey: "Sourceurlobs")
            UserDefaults.standard.set("d", forKey: "Choice")
        }
        
    }
    





    
    @IBAction func sourcesurlbootloader(_ sender: Any) {
        let targeturlbl = UserDefaults.standard.string(forKey: "Sourceurll")
        if let url = URL(string: targeturlbl ?? ""),
            NSWorkspace.shared.open(url) {
        }
    }
    
    @IBAction func sourcesurlobsolete(_ sender: Any) {
        let targeturlobs = UserDefaults.standard.string(forKey: "Sourceurlobs")
        if let url = URL(string: targeturlobs ?? ""),
            NSWorkspace.shared.open(url) {
        }
    }

   @IBAction func cacherebuild(_ sender: Any) {
        let rwcheck = UserDefaults.standard.string(forKey: "Read-Only")
        if rwcheck == "No"{
            logger.textStorage?.mutableString.setString("")
            extras.setIsVisible(false)
            security_window.setIsVisible(false)
            syncShellExec(path: scriptPath, args: ["rebuildcache"])
        } else{
            self.cacherebuild_yes_bt.isHidden=false
            self.atheros_yes_bt.isHidden=true
            self.sleepfix_yes_bt.isHidden=true
            security_window.setIsVisible(true)
        }
    }

    @IBAction func cacherebuild_yes(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        extras.setIsVisible(false)
        security_window.setIsVisible(false)
        syncShellExec(path: scriptPath, args: ["rebuildcache"])
    }

    @IBAction func atheros_yes(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        security_window.setIsVisible(false)
        extras.setIsVisible(false)
        asyncShellExec(path: scriptPath, args: ["ar92xx"])
        UserDefaults.standard.set("1", forKey: "Choice")
    }

    @IBAction func sleepfix_yes(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        extras.setIsVisible(false)
        security_window.setIsVisible(false)
        syncShellExec(path: scriptPath, args: ["fixsleepimage"])
        UserDefaults.standard.set("1", forKey: "Choice")
    }
    
    
    @IBAction func security_window_close(_ sender: Any) {
            security_window.setIsVisible(false)
    }

    @IBAction func extras(_ sender: Any) {
        syncShellExec(path: scriptPath, args: ["scanallefis"])
        let efi1 = UserDefaults.standard.string(forKey: "EFI1-Name")
        if efi1 == " - "{
            self.tools_efi_pulldown.isEnabled = false
            self.tools_mount.isEnabled = false
            self.tools_unmount.isEnabled = false
            self.tools_unmountall.isEnabled = false
        } else {
            self.tools_efi_pulldown.isEnabled = true
            self.tools_mount.isEnabled = true
            self.tools_unmount.isEnabled = true
            self.tools_unmountall.isEnabled = true
        }
        let efi2 = UserDefaults.standard.string(forKey: "EFI2-Name")
        if efi2 != nil{
            self.efiname.item(at: 1)?.isHidden=false
        } else {
            self.efiname.item(at: 1)?.isHidden=true
        }
        let efi3 = UserDefaults.standard.string(forKey: "EFI3-Name")
        if efi3 != nil{
            self.efiname.item(at: 2)?.isHidden=false
        } else {
            self.efiname.item(at: 2)?.isHidden=true
        }
        
        let efi4 = UserDefaults.standard.string(forKey: "EFI4-Name")
        if efi4 != nil{
            self.efiname.item(at: 3)?.isHidden=false
        } else {
            self.efiname.item(at: 3)?.isHidden=true
        }
        let efi5 = UserDefaults.standard.string(forKey: "EFI5-Name")
        if efi5 != nil{
            self.efiname.item(at: 4)?.isHidden=false
        } else {
            self.efiname.item(at: 4)?.isHidden=true
        }
        let efi6 = UserDefaults.standard.string(forKey: "EFI6-Name")
        if efi6 != nil{
            self.efiname.item(at: 5)?.isHidden=false
        } else {
            self.efiname.item(at: 5)?.isHidden=true
        }
        let efi7 = UserDefaults.standard.string(forKey: "EFI7-Name")
        if efi7 != nil{
            self.efiname.item(at: 6)?.isHidden=false
        } else {
            self.efiname.item(at: 6)?.isHidden=true
        }
        let efi8 = UserDefaults.standard.string(forKey: "EFI8-Name")
        if efi8 != nil{
            self.efiname.item(at: 7)?.isHidden=false
        } else {
            self.efiname.item(at: 7)?.isHidden=true
        }

        syncShellExec(path: scriptPath, args: ["checksleepfix"])
        let sleepcheck = UserDefaults.standard.string(forKey: "Sleepfix")
        if sleepcheck == "1" {
        fixsleep.isEnabled = false
        fixapplied.isHidden = false
        fixnotapplied.isHidden = true
        } else {
        fixsleep.isEnabled = true
        fixapplied.isHidden = true
        fixnotapplied.isHidden = false
        }
        
        syncShellExec(path: scriptPath, args: ["checkatheros40"])
        let atheros40check = UserDefaults.standard.string(forKey: "Atheros40")
        if atheros40check == "1" {
            //atheros40_btn.isEnabled = false
            atheros40applied.isHidden = false
            atheros40notapplied.isHidden = true
        } else {
            //atheros40_btn.isEnabled = true
            atheros40applied.isHidden = true
            atheros40notapplied.isHidden = true
        }
        
        //UserDefaults.standard.set("d", forKey: "Choice")
        extras.setIsVisible(true)
    }

    @IBAction func extrasclose(_ sender: Any) {
        check_for_updates_rb.setNextState()
        UserDefaults.standard.set("1", forKey: "Choice")
        extras.setIsVisible(false)
        //UserDefaults.standard.set("1", forKey: "Choice")
    }
    
    @IBAction func excludekextsreset(_ sender: Any) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("ex-"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        //exclude_kexts_wd.setIsVisible(false)
        }
     }
    

    
    @IBAction func excludekextsgo(_ sender: Any) {
        exclude_kexts_wd.setIsVisible(false)
    }
    
    @IBAction func massdlgo(_ sender: Any) {
        UserDefaults.standard.set("m", forKey: "Choice")
        UserDefaults.standard.removeObject(forKey: "Load Single Kext")
        massdownload.setIsVisible(false)
        logger.textStorage?.mutableString.setString("")
        asyncShellExec(path: scriptPath, args: ["massdownload"])
        //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.hasPrefix("dl-"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
        //}
        load_single_kext_pd.setValue(true, forKey: "enabled")
        load_single_kext_pd.selectItem(at: 0)
        
        //check_for_updates_rb.setNextState()
        //UserDefaults.standard.set("1", forKey: "Choice")
    }
    
    @IBAction func massdlselectall(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "dl-acpibatterymanager")
        UserDefaults.standard.set(true, forKey: "dl-airportbrcmfixup")
        UserDefaults.standard.set(true, forKey: "dl-applealc")
        UserDefaults.standard.set(true, forKey: "dl-applebacklightfixup")
        UserDefaults.standard.set(true, forKey: "dl-asussmc")
        UserDefaults.standard.set(true, forKey: "dl-ath9kfixup")
        UserDefaults.standard.set(true, forKey: "dl-atherose2200ethernet")
        UserDefaults.standard.set(true, forKey: "dl-atheroswifiinjector")
        UserDefaults.standard.set(true, forKey: "dl-brcmpatchram")
        UserDefaults.standard.set(true, forKey: "dl-bt4lecontinuityfixup")
        UserDefaults.standard.set(true, forKey: "dl-codeccommander")
        UserDefaults.standard.set(true, forKey: "dl-cpufriend")
        UserDefaults.standard.set(true, forKey: "dl-enablelidwake")
        UserDefaults.standard.set(true, forKey: "dl-fakepciid")
        UserDefaults.standard.set(true, forKey: "dl-fakesmc")
        UserDefaults.standard.set(true, forKey: "dl-genericusbxhci")
        UserDefaults.standard.set(true, forKey: "dl-hibernationfixup")
        UserDefaults.standard.set(true, forKey: "dl-intelmausi")
        UserDefaults.standard.set(true, forKey: "dl-intelmausiethernet")
        UserDefaults.standard.set(true, forKey: "dl-lilu")
        UserDefaults.standard.set(true, forKey: "dl-lilufriend")
        UserDefaults.standard.set(true, forKey: "dl-nightshiftunlocker")
        UserDefaults.standard.set(true, forKey: "dl-notouchid")
        UserDefaults.standard.set(true, forKey: "dl-novpajpeg")
        UserDefaults.standard.set(true, forKey: "dl-nullcpupowermanagement")
        UserDefaults.standard.set(true, forKey: "dl-nullethernet")
        UserDefaults.standard.set(true, forKey: "dl-realtekrtl8111")
        UserDefaults.standard.set(true, forKey: "dl-rtcmemoryfixup")
        UserDefaults.standard.set(true, forKey: "dl-sinetekrtsx")
        UserDefaults.standard.set(true, forKey: "dl-systemprofilermemoryfixup")
        UserDefaults.standard.set(true, forKey: "dl-tscadjustreset")
        UserDefaults.standard.set(true, forKey: "dl-usbinjectall")
        UserDefaults.standard.set(true, forKey: "dl-virtualsmc")
        UserDefaults.standard.set(true, forKey: "dl-voodoohda")
        UserDefaults.standard.set(true, forKey: "dl-voodooi2c")
        UserDefaults.standard.set(true, forKey: "dl-voodoops2")
        UserDefaults.standard.set(true, forKey: "dl-voodoosmbus")
        UserDefaults.standard.set(true, forKey: "dl-voodoosdhc")
        UserDefaults.standard.set(true, forKey: "dl-voodootscsync")
        UserDefaults.standard.set(true, forKey: "dl-whatevergreen")
        //UserDefaults.standard.set(true, forKey: "azulpatcher4600")
        //UserDefaults.standard.set(true, forKey: "coredisplayfixup")
        //UserDefaults.standard.set(true, forKey: "intelgraphicsfixup")
        //UserDefaults.standard.set(true, forKey: "intelgraphicsdvmtfixup")
        //UserDefaults.standard.set(true, forKey: "nvidiagraphicsfixup")
        //UserDefaults.standard.set(true, forKey: "novpajpeg")
        //UserDefaults.standard.set(true, forKey: "shiki")
    }
    
    @IBAction func massdldeselectall(_ sender: Any) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("dl-"){
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }

    @IBAction func ar92xx(_ sender: Any) {
        let rwcheck = UserDefaults.standard.string(forKey: "Read-Only")
        if rwcheck == "No"{
            logger.textStorage?.mutableString.setString("")
            extras.setIsVisible(false)
            asyncShellExec(path: scriptPath, args: ["ar92xx"])
            UserDefaults.standard.set("1", forKey: "Choice")
        } else{
            self.cacherebuild_yes_bt.isHidden=true
            self.atheros_yes_bt.isHidden=false
            self.sleepfix_yes_bt.isHidden=true
            security_window.setIsVisible(true)
        }
    }

    @IBAction func fixsleepimage(_ sender: Any) {
        let rwcheck = UserDefaults.standard.string(forKey: "Read-Only")
        if rwcheck == "No"{
        logger.textStorage?.mutableString.setString("")
        extras.setIsVisible(false)
        syncShellExec(path: scriptPath, args: ["fixsleepimage"])
        UserDefaults.standard.set("1", forKey: "Choice")
        } else{
            self.cacherebuild_yes_bt.isHidden=true
            self.atheros_yes_bt.isHidden=true
            self.sleepfix_yes_bt.isHidden=false
            security_window.setIsVisible(true)
        }
    }
    
    @IBOutlet weak var efiname: NSPopUpButton!

    @IBAction func efimounter(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        let efichoice = efiname.selectedCell()!.title
        let efichoice2 = efichoice.prefix(7)
        UserDefaults.standard.set(efichoice2, forKey: "EFIx")
        syncShellExec(path: scriptPath, args: ["mountefiall"])
        //checkefi()
    }
    
    @IBAction func efiunmounter(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        let efichoice = efiname.selectedCell()!.title
        let efichoice2 = efichoice.prefix(7)
        UserDefaults.standard.set(efichoice2, forKey: "EFIx")
        syncShellExec(path: scriptPath, args: ["unmountefi"])
        //checkefi()
    }
    
    @IBAction func efiunmounterall(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        syncShellExec(path: scriptPath, args: ["unmountefiall"])
        //checkefi()
    }

    @IBAction func uninstalllspcimenu(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        preferences.setIsVisible(false)
        syncShellExec(path: scriptPath, args: ["lspciuninstall"])
        UserDefaults.standard.set("1", forKey: "Choice")
    }
    
    @IBAction func resetrootuser(_ sender: Any) {
        logger.textStorage?.mutableString.setString("")
        syncShellExec(path: scriptPath, args: ["_resetrootuser"])
        let rootcheck = UserDefaults.standard.string(forKey: "Admin")
        if rootcheck == "No"{
            infobox_admin_status_content_yes.isHidden = true
            infobox_admin_status_content_no.isHidden = false
            footer_efi_efimount_bt.isEnabled = false
            btn_extras.isEnabled = false
            infobox_admin_status_image_red.isHidden = false
            infobox_admin_status_image_green.isHidden = true
            create_support_report_rb.isEnabled = false
            checkefi()
        } else if rootcheck == "Yes"{
            infobox_admin_status_content_yes.isHidden = false
            infobox_admin_status_content_no.isHidden = true
            footer_efi_efimount_bt.isEnabled = true
            btn_extras.isEnabled = true
            infobox_admin_status_image_red.isHidden = true
            infobox_admin_status_image_green.isHidden = false
            create_support_report_rb.isEnabled = true
            checkefi()
        }
        preferences.setIsVisible(false)
    }
    
    @IBAction func check(_ sender: NSButton) {
        let passcheck = UserDefaults.standard.string(forKey: "Passwordok")
        if let url = URL(string: "https://update.kextupdater.de/online") {
            do {
                if try String(contentsOf: url) != "1\n"{
                self.networkerror.setIsVisible(true)
                return
                }
            } catch {
                self.networkerror.setIsVisible(true)
                return
            }
        }

        let fontpt = CGFloat(UserDefaults.standard.float(forKey: "Font Size"))
        let fontfam = UserDefaults.standard.string(forKey: "Font Family")
        logger.font = NSFont(name: fontfam!, size: fontpt)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.M.yyyy, HH:mm:ss"
        let result = formatter.string(from: date)

        let checklast = UserDefaults.standard.string(forKey: "Last Check")
        if checklast != "Never"{
        UserDefaults.standard.set(checklast, forKey: "Last Check")
        }

        let lastcheck = (result as String)
        UserDefaults.standard.set(lastcheck, forKey: "Last Check")
        
        logger.textStorage?.mutableString.setString("")
        asyncShellExec(path: scriptPath, args: ["mainscript"])
        sender.isEnabled = true
        //self.logger.scrollToEndOfDocument(nil)
        
        load_single_kext_pd.selectItem(at: 0)
    }
   
    @IBAction func massdlstart(_ sender: Any) {
        //let oldchoice = UserDefaults.standard.string(forKey: "Choice")
        UserDefaults.standard.set("m", forKey: "Choice")
        UserDefaults.standard.removeObject(forKey: "Load Single Kext")
        massdownload.setIsVisible(false)
        logger.textStorage?.mutableString.setString("")
        syncShellExec(path: scriptPath, args: ["massdownload"])
        //DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                if key.hasPrefix("dl-"){
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
        //}
        load_single_kext_pd.setValue(true, forKey: "enabled")
        load_single_kext_pd.selectItem(at: 0)
        let massdlcheck = UserDefaults.standard.string(forKey: "Ready")
        if massdlcheck != "Error"{
            asyncShellExec(path: scriptPath, args: ["mainscript"])
        } else {
           UserDefaults.standard.removeObject(forKey: "Ready")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        //self.check_for_updates_rb.setNextState()
        UserDefaults.standard.set("d", forKey: "Choice")
        }
    }
    
    @IBAction func preferences(_ sender: Any) {
        let downloadpath = UserDefaults.standard.string(forKey: "Downloadpath")
        fileb.stringValue = (downloadpath ?? "")
        folder_download_path.stringValue = (downloadpath ?? "")
        let temppath = UserDefaults.standard.string(forKey: "Temppath")
        tempb.stringValue = (temppath ?? "")
        let speakervolume = UserDefaults.standard.string(forKey: "Speakervolume")
        let theme = UserDefaults.standard.string(forKey: "Theme")
        if speakervolume == "0" {
           
            if theme == "Dark" {
                speaker_icon_off_dark.isHidden = false
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = true
                speakericon.isHidden = true
            } else {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = false
                speakericon.isHidden = true
            }
        } else {
            if theme == "Dark" {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = false
                speakericon_off.isHidden = true
                speakericon.isHidden = true
            } else {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = true
                speakericon.isHidden = false
            }
        }
      
        preferences.setIsVisible(true)
        
        let systemmode = UserDefaults.standard.string(forKey: "ThemeTag")
        if systemmode == "0" {
            self.themeselector.selectItem(withTag: 0)
        } else if systemmode == "1" {
            self.themeselector.selectItem(withTag: 1)
        } else if systemmode == "2" {
            self.themeselector.selectItem(withTag: 2)
        }
    }
    
    @IBAction func themeselector(_ sender: Any) {
        let choicefunc = (sender as AnyObject).selectedCell()!.tag
        if choicefunc == 0 {
            UserDefaults.standard.set("Light", forKey: "Theme")
            UserDefaults.standard.set("0", forKey: "ThemeTag")
            lighttheme()
        } else if choicefunc == 1 {
            UserDefaults.standard.set("Dark", forKey: "Theme")
            UserDefaults.standard.set("1", forKey: "ThemeTag")
            darktheme()
        } else if choicefunc == 2 {
            UserDefaults.standard.set("System", forKey: "Theme")
            UserDefaults.standard.set("2", forKey: "ThemeTag")
            let systemmode = UserDefaults.standard.string(forKey: "System Theme")
            if systemmode == "Dark"{
                darktheme()
            }else {
                lighttheme()
            }
        }
        
        let speakervolume = UserDefaults.standard.string(forKey: "Speakervolume")
        let theme = UserDefaults.standard.string(forKey: "Theme")
        if speakervolume == "0" {
            
            if theme == "Dark" {
                speaker_icon_off_dark.isHidden = false
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = true
                speakericon.isHidden = true
            } else {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = false
                speakericon.isHidden = true
            }
        } else {
            if theme == "Dark" {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = false
                speakericon_off.isHidden = true
                speakericon.isHidden = true
            } else {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = true
                speakericon.isHidden = false
            }
        }
    }
  
    @IBAction func resetprefs(_ sender: Any) {
        syncShellExec(path: scriptPath, args: ["loginitem_off"])
        syncShellExec(path: scriptPath, args: ["resetprefs"])
    }
 
    @IBAction func defaultpath(_ sender: Any) {
        let defaultdir = self.userDesktopDirectory + "/Desktop/Kext-Updates"
        UserDefaults.standard.set(defaultdir, forKey: "Downloadpath")
        fileb.stringValue = (defaultdir)
        folder_download_path.stringValue = (defaultdir)
    }
    
    @IBAction func defaulttmppath(_ sender: Any) {
        let defaultdir = "/tmp/kextupdater"
        UserDefaults.standard.set(defaultdir, forKey: "Temppath")
        tempb.stringValue = (defaultdir)
    }

    
    @IBAction func volslider(_ sender: Any) {
        let speakervolume = UserDefaults.standard.string(forKey: "Speakervolume")
        let theme = UserDefaults.standard.string(forKey: "Theme")
        if speakervolume == "0" {
            
            if theme == "Dark" {
                speaker_icon_off_dark.isHidden = false
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = true
                speakericon.isHidden = true
            } else {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = false
                speakericon.isHidden = true
            }
        } else {
            if theme == "Dark" {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = false
                speakericon_off.isHidden = true
                speakericon.isHidden = true
            } else {
                speaker_icon_off_dark.isHidden = true
                speaker_icon_on_dark.isHidden = true
                speakericon_off.isHidden = true
                speakericon.isHidden = false
            }
        }
    }
    
    
    @IBAction func preferencesclose(_ sender: Any) {
        let downloadpath = UserDefaults.standard.string(forKey: "Downloadpath")
        folder_download_path.stringValue = (downloadpath ?? "")
        preferences.setIsVisible(false)
        
        let fontcolor = UserDefaults.standard.string(forKey: "Font Color")
        if fontcolor == "1"{
            logger.textColor = NSColor.green
        } else if fontcolor == "2"{
            logger.textColor = NSColor.red
        }else if fontcolor == "3"{
            logger.textColor = NSColor.orange
        } else if fontcolor == "4"{
            logger.textColor = NSColor.yellow
        }
    
        let crt = UserDefaults.standard.string(forKey: "CRT")
        if crt == "1" {
            self.crtview.isHidden = false
        } else if crt == "0" {
            self.crtview.isHidden = true
        }
        let loginitem = UserDefaults.standard.string(forKey: "LoginItem")
        if loginitem == "1" {
            syncShellExec(path: scriptPath, args: ["loginitem_on"])
        } else if loginitem == "0" {
            syncShellExec(path: scriptPath, args: ["loginitem_off"])
        }
    }




  
    @IBAction func aboutwin(_ sender: Any) {
        let darkmode = UserDefaults.standard.string(forKey: "Dark Mode")
        if darkmode == "Yes"{
            darktheme()
        } else{
            lighttheme()
        }

        aboutwindow.setIsVisible(true)
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
        process.launch()
        self.app_logo_animation.isHidden = false
        self.animstart()
        
        filelHandler.readabilityHandler = { pipe in
            let data = pipe.availableData
            if let line = String(data: data, encoding: .utf8) {
                DispatchQueue.main.sync {
                    self.logger.string += line
                }
            } else {
                print("Error decoding data: \(data.base64EncodedString())")
            }
        }
        process.waitUntilExit()
        self.animstop()
        self.app_logo_animation.isHidden = true
        filelHandler.readabilityHandler = nil
    }

    func asyncShellExec(path: String, args: [String] = []) {
        let process            = Process.init()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        let filelHandler       = outputPipe.fileHandleForReading
        process.standardOutput = outputPipe
        process.launch()
        self.app_logo_animation.isHidden = false
        self.animstart()

        DispatchQueue.global().async {
            filelHandler.readabilityHandler = { pipe in
                let data = pipe.availableData
                if let line = String(data: data, encoding: String.Encoding.utf8) {
                    DispatchQueue.main.async {
                        self.logger.string += line
                        self.logger.scrollToEndOfDocument(nil)
                        if let timer = self.outputTimer {
                            timer.invalidate()
                            self.outputTimer = nil
                        }
                    }
                } else {
                    print("Error decoding data: \(data.base64EncodedString())")
                }
            }
            process.waitUntilExit()
            DispatchQueue.main.async {
                //self.logger.scrollToEndOfDocument(nil)
                self.animstop()
                self.app_logo_animation.isHidden = true
            }
            }
        
   }

    func animstart() -> Void {
        let darkcheck = UserDefaults.standard.string(forKey: "Dark Mode")
        if darkcheck == "No"{
            let image = APNGImage(named: "animlight.apng")
            let imageView = APNGImageView(image: image)
            app_logo_animation.addSubview(imageView)
            imageView.startAnimating()
        } else {
            let image = APNGImage(named: "animdark.apng")
            let imageView = APNGImageView(image: image)
            app_logo_animation.addSubview(imageView)
            imageView.startAnimating()
        }
    }

    func animstop() -> Void {
        let darkcheck = UserDefaults.standard.string(forKey: "Dark Mode")
        if darkcheck == "No"{
            let image = APNGImage(named: "animlight.apng")
            let imageView = APNGImageView(image: image)
            app_logo_animation.addSubview(imageView)
            imageView.stopAnimating()
        } else {
            let image = APNGImage(named: "animdark.apng")
            let imageView = APNGImageView(image: image)
            app_logo_animation.addSubview(imageView)
            imageView.stopAnimating()
        }
    }
    
    func password() -> Void {
        let keychain = KeychainSwift()
        let secret = pwdpassword.stringValue
        pwdwindow.setIsVisible(false)
        keychain.set(secret, forKey: "Kext Updater")
        syncShellExec(path: scriptPath, args: ["_checkpass"])
        let passcheck = UserDefaults.standard.string(forKey: "Passwordok")
        if passcheck == "Yes" {
            wrongpassword.setIsVisible(true)
            passaccepted.isHidden = false
            passrefused.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.wrongpassword.setIsVisible(false)
                self.passaccepted.isHidden = true
                self.passrefused.isHidden = true
            })
        } else {
            wrongpassword.setIsVisible(true)
            self.passaccepted.isHidden = true
            self.passrefused.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.pwdwindow.setIsVisible(true)
                self.pwdpassword.stringValue = ""
                self.wrongpassword.setIsVisible(false)
                self.passaccepted.isHidden = true
                self.passrefused.isHidden = true
            })
        }

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
    func chime2() -> Void {
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
    func chime3() -> Void {
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
 
    /**
     * plays a chime4 sound
     */
    func chime4() -> Void {
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

    /**
     * plays a chime5 sound
     */
    func chime5() -> Void {
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
    
    /**
     * Dark Theme
     */
    func darktheme() {
        logger.textColor = NSColor.green
        logger.backgroundColor = NSColor.black
        self.app_logo_light.isHidden = true
        self.app_logo_dark.isHidden = false
        self.applogoabout.isHidden = true
        self.applogodarkabout.isHidden = false
        self.helpinfo.isHidden = true
        self.helpinfodark.isHidden = false
        self.folder_bug_report_image_light.isHidden = true
        self.folder_bug_report_image_dark.isHidden = false
        self.load_single_kext_icon_dark.isHidden = false
        self.load_bootloader_icon_dark.isHidden = false
        self.load_single_kext_icon_light.isHidden = true
        self.load_bootloader_icon_light.isHidden = true
        UserDefaults.standard.set("Yes", forKey: "Dark Mode")
        ThemeManager.darkTheme.apply()
        let image = APNGImage(named: "animdark.apng")
        let imageView = APNGImageView(image: image)
        app_logo_animation.addSubview(imageView)
    }
    
    /**
     * Light Theme
     */
    func lighttheme() {
        logger.textColor = NSColor.black
        logger.backgroundColor = NSColor.white
        self.app_logo_light.isHidden = false
        self.app_logo_dark.isHidden = true
        self.applogoabout.isHidden = false
        self.applogodarkabout.isHidden = true
        self.helpinfo.isHidden = false
        self.helpinfodark.isHidden = true
        self.folder_bug_report_image_light.isHidden = false
        self.folder_bug_report_image_dark.isHidden = true
        self.load_single_kext_icon_dark.isHidden = true
        self.load_bootloader_icon_dark.isHidden = true
        self.load_single_kext_icon_light.isHidden = false
        self.load_bootloader_icon_light.isHidden = false
        UserDefaults.standard.set("No", forKey: "Dark Mode")
        ThemeManager.lightTheme.apply()
        let image = APNGImage(named: "animlight.apng")
        let imageView = APNGImageView(image: image)
        app_logo_animation.addSubview(imageView)
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
     * Creates Temp Folder
     */
    func createtmp() {
        let tmppathinit2 = UserDefaults.standard.string(forKey: "Temppath")
        let url = URL(fileURLWithPath: tmppathinit2 ?? "")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch _ {
            print("")
        }
    }
    
    /**
     * Checks if EFI is mounted
     */
    func checkefi() {
        let cloverpath = UserDefaults.standard.string(forKey: "EFI Path")
        let mounted = UserDefaults.standard.string(forKey: "Mounted")
        if mounted == "Yes"{
        footer_efi_efimount_bt.title = "efimounted".localized()
        footer_efi_image_green.isHidden = false
        footer_efi_image_info.isHidden = false
        footer_efi_diskinfo_click.isHidden = false
        folder_efi_icon.isEnabled = true
        folder_efi_path.stringValue = (cloverpath ?? "")
        } else {
        footer_efi_efimount_bt.title = "efinotmounted".localized()
        footer_efi_image_red.isHidden = false
        footer_efi_image_green.isHidden = true
        footer_efi_image_info.isHidden = true
        footer_efi_diskinfo_click.isHidden = true
        folder_efi_icon.isEnabled = false
        folder_efi_path.stringValue = ("")
        }
    }

     /**
     * Removes Folder /tmp/kextupdater if set
     */
    func removetmp() {
        //let dlpath = UserDefaults.standard.string(forKey: "Downloadpath")
        //do {
        //    try FileManager.default.removeItem(at: dlpath)
        //} catch let error {
        //    print("Error: \(error.localizedDescription)")
        //}
        syncShellExec(path: scriptPath, args: ["exitapp"])
        //exit(0)
        NSApplication.shared.terminate(self)
    }
    
    func sourcesicon () {
    load_single_kext_icon_dark.isEnabled = true
    load_single_kext_icon_light.isEnabled = true
    load_single_kext_url.isEnabled = true
    load_single_kext_url.isHidden = false
    }

    func sourcesiconbootloader () {
    load_bootloader_icon_dark.isEnabled = true
    load_bootloader_icon_light.isEnabled = true
    load_bootloader_url.isEnabled = true
    load_bootloader_url.isHidden = false
    }
    
    func sourcesiconobsolete () {
        sourcesobsolete.isEnabled = true
        sourcestargetobsolete.isEnabled = true
        sourcestargetobsolete.isHidden = false
        btn_dl_obsolete.isEnabled = true
    }
    
    /**
     * File Browser for selecting Downloadpath
     */
    @IBAction func browseFile(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                fileb.stringValue = path
                let dlpath = (path as String)
                UserDefaults.standard.set(dlpath, forKey: "Downloadpath")
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func browseFileTmp(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                tempb.stringValue = path
                let tmppath = (path as String)
                UserDefaults.standard.set(tmppath, forKey: "Temppath")
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }

   



   
    @IBAction func changelog(_ sender: Any) {
        if let url = URL(string: "https://update.kextupdater.de/kextupdater/release_menu.html"),
            NSWorkspace.shared.open(url) {
        }
    }
}
