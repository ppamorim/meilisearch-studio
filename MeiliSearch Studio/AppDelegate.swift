//
//  AppDelegate.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  private weak var windowController: NSWindowController?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func present(windowController: NSWindowController) {
    self.windowController = windowController
    self.windowController?.window?.makeKeyAndOrderFront(nil)
    self.windowController?.showWindow(self)
  }

}

