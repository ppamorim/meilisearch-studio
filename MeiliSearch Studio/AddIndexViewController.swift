//
//  AddIndexViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 12/10/2020.
//

import Cocoa

protocol AddIndexViewControllerDelegate: AnyObject {
  func onIndexAdded()
}

final class AddIndexViewController: NSViewController {

  @IBOutlet weak var uidTextField: NSTextField!
  @IBOutlet weak var primaryKeyTextField: NSTextField!
  @IBOutlet weak var createButton: NSButton!

  private weak var delegate: AddIndexViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    self.delegate = appDelegate.addIndexViewControllerDelegate
  }

  @IBAction func onCreateButtonClick(_ sender: Any) {
    createButton.isEnabled = false

    let UID: String = uidTextField.stringValue

    if UID.isEmpty {
      return
    }

    createIndexAsync(UID) { [weak self] in
      self?.delegate?.onIndexAdded()
      self?.view.window?.close()
    }

  }

  private func createIndexAsync(_ UID: String, _ completion: @escaping () -> Void) {

    let queue = DispatchQueue(label: "CreateIndexQueue")
    queue.async {

      MeiliSearchClient.shared.client.createIndex(UID: UID) { result in

        switch result {
        case .success:
          DispatchQueue.main.async {
            completion()
          }

        case .failure(let error):
          print("[IndexesViewController] error \(error)")

        }

      }

    }

  }

}
