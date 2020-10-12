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
  @IBOutlet weak var progressIndicator: NSProgressIndicator!
  @IBOutlet weak var scrollView: NSScrollView!
  @IBOutlet weak var tableView: NSTableView!

  @IBOutlet weak var indexesComboBox: NSComboBox!
  @IBOutlet weak var indexesProgressBar: NSProgressIndicator!

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

  @IBAction func onReloadClick(_ sender: Any) {
  }

  private func loadIndexesAsync() {

    self.indexesProgressBar.isHidden = false
    self.indexesProgressBar.startAnimation(nil)

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

    self.scrollView.isHidden = true
    self.progressIndicator.isHidden = false
    self.progressIndicator.startAnimation(nil)

    let queue = DispatchQueue(label: "LoadIndexesQueue")
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

  private func updateComboBoxIfNeeded() {
    self.indexesComboBox.reloadData()
    self.indexesProgressBar.stopAnimation(nil)
  }

  private func updateTableViewIfNeeded() {
    self.tableView.reloadData()

    if self.indexes.isEmpty {
      self.progressIndicator.isHidden = true
      self.scrollView.isHidden = true
      return
    }

    self.progressIndicator.isHidden = true
    self.scrollView.isHidden = false
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
