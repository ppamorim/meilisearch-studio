//
//  ViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa
import CoreStore

final class AuthViewController: NSViewController {

  @IBOutlet weak var hostTextField: NSTextField!
  @IBOutlet weak var masterKeyTextField: NSSecureTextField!
  @IBOutlet weak var meiliLinkLabel: NSTextField!
  @IBOutlet weak var activityIndicator: NSProgressIndicator!

  override func viewDidLoad() {
    super.viewDidLoad()
    meiliLinkLabel.addGestureRecognizer(
      NSClickGestureRecognizer(
        target: self,
        action: #selector(onMeiliLinkClick)))
  }

  @objc
  private func onMeiliLinkClick() {
    NSWorkspace.shared.open(URL(string: "https://www.meilisearch.com")!)
  }

  @IBAction func onSignInClick(_ sender: Any) {

    let host: String = hostTextField.stringValue
    let masterKey: String = masterKeyTextField.stringValue

    self.toggleActivityIndicator(enabled: true)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      
      // Handles pure IP (127.0.0.1:7700) and http/https included cases.
      let safeHttpHost: String = host.contains("http") ? host : "http://\(host)"

      MeiliSearchClient.shared.setup(hostURL: safeHttpHost, key: masterKey) { [weak self] result in
        
        self?.toggleActivityIndicator(enabled: false)

        switch result {
        case .success:
          
          CoreStoreDefaults.dataStack.perform(
            asynchronous: { (transaction) -> Void in
              let instance = transaction.create(Into<MeilisearchInstance>())
              instance.host = safeHttpHost
              instance.apiKey = masterKey
            },
            completion: { [weak self] result in
              switch result {
              case .success:
                self?.showHomeViewController()
                
              case .failure(let error):
                fatalError("\(error)")
              }
            }
          )

        case .failure(let error):
          let alert = NSAlert()
          alert.messageText = "Failed to connect to a MeiliSearch instance"
          alert.runModal()

        }

      }

    }

  }

  private func toggleActivityIndicator(enabled: Bool) {
    if enabled {
      self.activityIndicator.startAnimation(nil)
      self.activityIndicator.isHidden = false
      return
    }
    self.activityIndicator.isHidden = true
    self.activityIndicator.stopAnimation(nil)
  }

  private func showHomeViewController() {
    let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
    let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("HomeViewController")) as! NSWindowController
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.present(windowController: windowController)
    self.view.window?.close()
  }

}

