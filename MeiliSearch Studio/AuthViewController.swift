//
//  ViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

final class AuthViewController: NSViewController {

  @IBOutlet weak var hostTextField: NSTextField!
  @IBOutlet weak var masterKeyTextField: NSSecureTextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    masterKeyTextField.stringValue = "masterKey"
    // Do any additional setup after loading the view.
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  @IBAction func onSignInClick(_ sender: Any) {

    let host: String = hostTextField.stringValue
    let masterKey: String = masterKeyTextField.stringValue

    if masterKey.isEmpty {
      return
    }

    MeiliSearchClient.shared.setup(hostURL: host, key: masterKey) { [weak self] result in
      switch result {
      case .success:
        self?.showHomeViewController()
      case .failure(let error):
        let alert = NSAlert()
        alert.messageText = "Failed to connect to a MeiliSearch instance"
        alert.runModal()
      }

    }

  }

  private func showHomeViewController() {
    let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
    let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("HomeViewController")) as! NSWindowController
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.present(windowController: windowController)
    self.view.window?.close()
  }

}

