//
//  JSONEditorViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 18/10/2020.
//

import Cocoa

final class JSONEditorViewController: NSViewController {

  @IBOutlet weak var jsonValidatorLabel: NSTextField!
  @IBOutlet var textView: NSTextView!

  override func loadView() {
    super.loadView()
    self.jsonValidatorLabel.stringValue = ""
    textView.delegate = self

  }

  @IBAction func sendButtonClick(_ sender: Any) {

  }

}

extension JSONEditorViewController: NSTextViewDelegate {

  func textDidChange(_ notification: Notification) {

    let jsonString = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)

    if jsonString.isEmpty {
      self.jsonValidatorLabel.textColor = NSColor.white
      self.jsonValidatorLabel.stringValue = ""
      return
    }

    guard let jsonData = jsonString.data(using: String.Encoding.utf8) else {
      self.jsonValidatorLabel.textColor = NSColor.white
      self.jsonValidatorLabel.stringValue = ""
      return
    }

    if (try? JSONSerialization.jsonObject(with: jsonData, options: [])) != nil {
      self.jsonValidatorLabel.textColor = NSColor.green
      self.jsonValidatorLabel.stringValue = "Valid JSON"
    } else {
      self.jsonValidatorLabel.textColor = NSColor.red
      self.jsonValidatorLabel.stringValue = "Invalid JSON"
    }

  }

}
