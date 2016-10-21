//
//  AppDelegate.swift
//  PDF
//
//  Created by Jialin Yang on 9/19/16.
//  Copyright © 2016 Jialin Yang. All rights reserved.
//

import Cocoa
import Quartz
@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate{

    @IBOutlet weak var LoadTxt: NSMenuItem!
    
    @IBOutlet weak var JumpingPage: NSMenuItem!

    @IBOutlet weak var NextP: NSMenuItem!

    @IBOutlet weak var PreviousP: NSMenuItem!

    @IBOutlet weak var Zooming: NSMenuItem!
    
    @IBOutlet weak var Zoomfiting: NSMenuItem!
    
    @IBOutlet weak var Zoomouting: NSMenuItem!
    
    @IBOutlet weak var OpenFiling: NSMenuItem!
    
    @IBOutlet weak var SearchPreviousItem: NSMenuItem!
    
    @IBOutlet weak var SearchNextItem: NSMenuItem!
    
    
    // Multiple window structure, the window array
    
    var aboutinfo =  Aboutinfo ()
    
    var pdfwindow = [ pdfviewcontroller ]()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NewWindow(self)
        // Insert code here to initialize your application
    }
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func NewWindow(sender: AnyObject) {
        let pdfw = pdfviewcontroller()
        pdfwindow.append(pdfw)
        pdfw.showWindow(self)
    }


    @IBAction func aboutpanel(sender: AnyObject) {
        aboutinfo = Aboutinfo()
        aboutinfo.showWindow(self)
    }
    
}

