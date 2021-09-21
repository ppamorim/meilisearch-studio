//
//  AppDelegate.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa
import CoreStore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  let dataStack = DataStack(xcodeModelName: "Model")

  private var windowControllers: [Weak<NSWindowController>] = []

  //Not nice
  var addIndexViewControllerDelegate: AddIndexViewControllerDelegate?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    do {
      try dataStack.addStorageAndWait()
      CoreStoreDefaults.dataStack = self.dataStack
    } catch {
      print(error)
    }
    
    do {
      let count = try dataStack.fetchCount(From<MeilisearchInstance>())
      let storyboard: NSStoryboard = NSStoryboard(name: "Main", bundle: Bundle.main)
      let identifier: String = count == 0 ? "AuthViewController" : "HomeViewController"
      let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(identifier)) as! NSWindowController
      present(windowController: windowController)
    } catch {
      print(error)
    }
    
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
