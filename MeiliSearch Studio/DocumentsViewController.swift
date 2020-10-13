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

  }

  @IBAction func onReloadClick(_ sender: Any?) {
    let index: Int = indexesComboBox.indexOfSelectedItem
    if index < 0 {
      loadIndexesAsync()
      return
    }
    let limit = Int(limitComboBox.intValue)
    if limit == 10 || limit == 100 || limit == 1000 {
      loadDocumentsAsync(UID: indexes[index].UID, limit: limit)
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

  struct RawDocument: Codable, Equatable {
    let title: String?
  }

  private func loadDocumentsAsync(UID: String, limit: Int) {

    self.progressIndicator.isHidden = false
    self.progressIndicator.startAnimation(nil)
    self.reloadButton.isEnabled = false

    let queue = DispatchQueue(label: "LoadDocumentsQueue")
    queue.asyncAfter(deadline: .now() + 0.5) {

      MeiliSearchClient.shared.client.getDocuments(UID: UID, limit: limit) { [weak self] (result: Result<[RawDocument], Swift.Error>) in

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

        MeiliSearchClient.shared.client.addDocuments(UID: index.UID, documents: data as Data, primaryKey: index.primaryKey) { result in

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
    self.progressIndicator.stopAnimation(nil)
    self.progressIndicator.isHidden = true
  }

  private func updateTableViewIfNeeded() {
    self.tableView.reloadData()
    self.progressIndicator.isHidden = true
    self.reloadButton.isEnabled = true
  }

}

extension DocumentsViewController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
      static let IndexNameCell = "DocumentTitle"
      static let IndexCreatedAtCell = "IndexCreatedAt"
      static let IndexUpdatedAtCell = "IndexUpdatedAt"
    }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var text: String = ""
    var cellIdentifier: String = ""

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long

    let index = rawDocuments[row]

    if tableColumn == tableView.tableColumns[0] {
      text = index.title ?? "empty"
      cellIdentifier = CellIdentifiers.IndexNameCell
    } else if tableColumn == tableView.tableColumns[1] {
      text = index.title ?? "empty"
      cellIdentifier = CellIdentifiers.IndexCreatedAtCell
    } else if tableColumn == tableView.tableColumns[2] {
      text = index.title ?? "empty"
      cellIdentifier = CellIdentifiers.IndexUpdatedAtCell
    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    return nil
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
    loadDocumentsAsync(UID: indexes[index].UID, limit: 10)
  }



}

extension DocumentsViewController: NSComboBoxDataSource {

  func numberOfItems(in comboBox: NSComboBox) -> Int {
    indexes.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    indexes[index].UID
  }

}
