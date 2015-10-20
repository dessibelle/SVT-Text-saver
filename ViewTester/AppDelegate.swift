//
//  AppDelegate.swift
//  ViewTester
//
//  Created by Simon Fransson on 2015-03-13.
//  Copyright (c) 2015 Simon Fransson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var svttext: SVTTextView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.svttext = SVTTextView(frame: self.window.contentView.frame, isPreview: false)
        self.window.contentView.addSubview(self.svttext)
        
//        self.window.contentView.autoresizesSubviews = true
        self.svttext.autoresizingMask = ([NSAutoresizingMaskOptions.ViewHeightSizable, NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewMinXMargin, NSAutoresizingMaskOptions.ViewMaxXMargin, NSAutoresizingMaskOptions.ViewMinYMargin, NSAutoresizingMaskOptions.ViewMaxYMargin])
        
        self.svttext.startAnimation()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

