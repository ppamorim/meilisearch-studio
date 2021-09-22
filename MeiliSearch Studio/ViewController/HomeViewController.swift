//
//  HomeViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa
import CoreStore

protocol HomeViewControllerDelegate: AnyObject {
  var pageViewController: PageViewController? { get set }
  func openPage(page: Page)
  func disconnect()
}

final class HomeViewController: NSSplitViewController, HomeViewControllerDelegate {

  var pageViewController: PageViewController?
  var menuViewControllerDelegate: MenuViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    menuViewControllerDelegate = self.splitViewItems[0].viewController as? MenuViewControllerDelegate
    
    do {
      
      guard let instance: MeilisearchInstance = try CoreStoreDefaults.dataStack.fetchOne(From<MeilisearchInstance>()) else {
        fatalError()
      }
      
      menuViewControllerDelegate?.updateConnectionStatus(ConnectivityStatus.connecting)
      
      MeiliSearchClient.shared.setup(hostURL: instance.host!, key: instance.apiKey!) { [weak self] result in
        switch result {
        case .success:
          self?.menuViewControllerDelegate?.updateConnectionStatus(ConnectivityStatus.connected)
        case .failure(let error):
          self?.menuViewControllerDelegate?.updateConnectionStatus(ConnectivityStatus.disconnected)
        }
      }
      
    } catch {
      fatalError()
    }
    
    
  }

  func openPage(page: Page) {
    pageViewController?.openPage(page: page)
  }
  
  func disconnect() {
    
    do {
      
      guard let instance: MeilisearchInstance = try CoreStoreDefaults.dataStack.fetchOne(From<MeilisearchInstance>()) else {
        fatalError()
      }
      
      CoreStoreDefaults.dataStack.perform(
        asynchronous: { (transaction) -> Void in
          transaction.delete(instance)
        },
        completion: { [weak self] _ in
          MeiliSearchClient.shared.invalidate()
          self?.showAuthViewController()
          self?.view.window?.close()
        }
      )
      
    } catch {
      fatalError()
    }
    
  }
  
  private func showAuthViewController() {
    let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
    let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("AuthViewController")) as! NSWindowController
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.present(windowController: windowController)
  }

}
