//
//  AppDelegate.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  private var windowControllers: [Weak<NSWindowController>] = []

  //Not nice
  var addIndexViewControllerDelegate: AddIndexViewControllerDelegate?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
    addIndexViewControllerDelegate = nil
  }

  func present(windowController: NSWindowController) {
    self.windowControllers.append(Weak(value: windowController))
    windowController.window?.makeKeyAndOrderFront(nil)
    windowController.showWindow(self)
  }

}

final class Weak<T: AnyObject> {
  weak var value : T?
  init (value: T) {
    self.value = value
  }
}
