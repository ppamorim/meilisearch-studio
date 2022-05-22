//
//  DocumentsViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa
import MeiliSearch

final class DocumentsViewController: NSViewController {

  private var indexes: [Index] = []
  private var rawDocuments: [RawDocument] = []

  private weak var windowController: NSWindowController?

  @IBOutlet weak var backgroundView: NSView!
  @IBOutlet weak var scrollView: NSScrollView!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var indexesComboBox: NSComboBox!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
  @IBOutlet weak var reloadButton: NSButton!
  @IBOutlet weak var limitComboBox: NSComboBox!

  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundView.wantsLayer = true
    backgroundView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

    indexesComboBox.usesDataSource = true
    indexesComboBox.delegate = self
    indexesComboBox.dataSource = self

    tableView.delegate = self
    tableView.dataSource = self
    tableView.target = self
    loadIndexesAsync()
  }

  @IBAction func onAddClick(_ sender: Any) {

    let i: Int = indexesComboBox.indexOfSelectedItem
    if i < 0 {
      return
    }
    let index: Index = indexes[i]

    let alert = NSAlert()
    alert.messageText = "Add documents"
    alert.informativeText = "You can either add the documents by using the file explorer or JSON."
    alert.alertStyle = .warning
    alert.addButton(withTitle: "File")
    alert.addButton(withTitle: "JSON")
    alert.addButton(withTitle: "Cancel")
    switch alert.runModal() {
    case .alertFirstButtonReturn:
      self.openFilePicker(index)
    case .alertSecondButtonReturn:
      self.openJSONLoader(index)
    default:
      break
    }
    
  }

  private func openFilePicker(_ index: Index) {
    let op = NSOpenPanel()
    op.canChooseFiles = true
    op.canChooseDirectories = false
    op.runModal()
    if op.urls.isEmpty {
      return
    }
    let url = op.urls[0]
    createDocuments(index, url)
  }

  private func openJSONLoader(_ index: Index) {

    let appDelegate = NSApplication.shared.delegate as! AppDelegate
//    appDelegate.addIndexViewControllerDelegate = self

    let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
    let windowController = storyboard.instantiateController(
      withIdentifier: NSStoryboard.SceneIdentifier("JSONEditorWindowController")) as! NSWindowController
    self.windowController = windowController
    windowController.window?.makeKeyAndOrderFront(nil)
    windowController.showWindow(self)

  }

  @IBAction func onReloadClick(_ sender: Any?) {
    let index: Int = indexesComboBox.indexOfSelectedItem
    if index < 0 {
      loadIndexesAsync()
      return
    }
    let limit = Int(limitComboBox.intValue)
    if limit == 10 || limit == 100 || limit == 1000 {
      loadDocumentsAsync(uid: indexes[index].uid, limit: limit)
    }

  }

  private func loadIndexesAsync() {

    self.progressIndicator.isHidden = false
    self.progressIndicator.startAnimation(nil)

    let queue = DispatchQueue(label: "LoadIndexesQueue")
    queue.asyncAfter(deadline: .now() + 0.5) {

      MeiliSearchClient.shared.client.getIndexes { [weak self] result in

        switch result {
        case .success(let indexes):

          self?.indexes = indexes

          DispatchQueue.main.async { [weak self] in
            self?.updateComboBoxIfNeeded()
          }

        case .failure(let error):
          print("[IndexesViewController] error \(error)")

        }

      }

    }

  }

  private func loadDocumentsAsync(uid: String, limit: Int) {

    self.progressIndicator.isHidden = false
    self.progressIndicator.startAnimation(nil)
    self.reloadButton.isEnabled = false

    let queue = DispatchQueue(label: "LoadDocumentsQueue")
    queue.asyncAfter(deadline: .now() + 0.5) {

      MeiliSearchClient.shared.client.index(uid).getDocuments(
        options: GetParameters(offset: 0, limit: limit)
      ) { [weak self] (result: Result<[RawDocument], Swift.Error>) in

        switch result {
        case .success(let rawDocuments):

          self?.rawDocuments = rawDocuments

          DispatchQueue.main.async { [weak self] in
            self?.updateTableViewIfNeeded()
          }

        case .failure(let error):
          print("[IndexesViewController] error \(error)")

        }

      }

    }

  }

  private func createDocuments(_ index: Index, _ url: URL) {

    let queue = DispatchQueue(label: "CreateDocumentsQueue")
    queue.async {

      do {

        let data: NSData = try NSData(contentsOf: url)

        MeiliSearchClient.shared.client.index(index.uid).addDocuments(documents: data as Data, primaryKey: index.primaryKey) { result in

          switch result {
          case .success(let update):
            print(update)

            DispatchQueue.main.async { [weak self] in
              self?.onReloadClick(nil)
            }

          case .failure(let error):
            print(error)
          }

        }

      } catch {
        print(error)
      }

    }

  }

  private func updateComboBoxIfNeeded() {
    self.indexesComboBox.reloadData()
    self.indexesComboBox.selectItem(at: 0)
    self.progressIndicator.stopAnimation(nil)
    self.progressIndicator.isHidden = true
  }

  private func updateTableViewIfNeeded() {
    self.tableView.reloadData()
    self.progressIndicator.isHidden = true
    self.reloadButton.isEnabled = true

    tableView.tableColumns.forEach { tableColumn in
      tableView.removeTableColumn(tableColumn)
    }

    if rawDocuments.isEmpty {
      return
    }

    let rawDocument = rawDocuments[0]

    let values: [String: Any] = rawDocument.value as! [String: Any]
    let sortedKeys = Array(values.keys).sorted(by: <)

    sortedKeys.forEach { (key: String) in
      let tableColumn: NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(key))
      tableColumn.isEditable = false
      tableColumn.headerCell.stringValue = key
      (tableColumn.dataCell as! NSTextFieldCell).identifier = tableColumn.identifier
      tableView.addTableColumn(tableColumn)
    }

  }

}

extension DocumentsViewController: NSTableViewDelegate {

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    let index: [String: Any] = rawDocuments[row].value as! [String: Any]

    let headerKey: String = tableColumn!.headerCell.stringValue
    let value = index[headerKey]

    let cell = NSTextField()
    cell.identifier = NSUserInterfaceItemIdentifier(headerKey)

    if let intValue = value as? Int {
      cell.integerValue = intValue
    } else if let floatValue = value as? Float {
      cell.floatValue = floatValue
    } else if let stringValue = value as? String {
      cell.stringValue = stringValue
    } else if let safeValue = value {
      cell.stringValue = "\(safeValue)"
    } else {
      cell.stringValue = "Not set"
    }

    return cell
  }

}

extension DocumentsViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    rawDocuments.count
  }

}

extension DocumentsViewController: NSComboBoxDelegate {

  func comboBoxSelectionDidChange(_ notification: Notification) {
    let index: Int = indexesComboBox.indexOfSelectedItem
    loadDocumentsAsync(uid: indexes[index].uid, limit: 10)
  }

}

extension DocumentsViewController: NSComboBoxDataSource {

  func numberOfItems(in comboBox: NSComboBox) -> Int {
    indexes.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    indexes[index].uid
  }

}
