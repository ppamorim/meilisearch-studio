//
//  SearchViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 18/10/2020.
//

import Cocoa
import MeiliSearch

final class SearchViewController: NSViewController {

  private var indexes: [Index] = []
  private var rawDocuments: [RawDocument] = []

  @IBOutlet weak var indexesComboBox: NSComboBox!
  @IBOutlet weak var searchField: NSSearchField!
  @IBOutlet weak var scrollView: NSScrollView!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var resultMillisecondsLabel: NSTextField!
  @IBOutlet weak var activityIndicator: NSProgressIndicator!

  override func viewDidLoad() {
    super.viewDidLoad()
//    backgroundView.wantsLayer = true
//    backgroundView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

    searchField.delegate = self

    indexesComboBox.usesDataSource = true
    indexesComboBox.delegate = self
    indexesComboBox.dataSource = self

    tableView.delegate = self
    tableView.dataSource = self
    tableView.target = self
    loadIndexesAsync()
  }

  private func loadIndexesAsync() {

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

  private func loadDocumentsAsync() {

    let index: Int = indexesComboBox.indexOfSelectedItem

    if index < 0 {
      return
    }

    let query: String = searchField.stringValue

    let uid = indexes[index].uid

    let queue = DispatchQueue(label: "LoadDocumentsQueue")
    queue.asyncAfter(deadline: .now() + 0.5) {

      let params = SearchParameters.query(query)

      MeiliSearchClient.shared.client.index(uid).search(params) { [weak self] (result: Result<SearchResult<RawDocument>, Swift.Error>) in

        switch result {
        case .success(let searchResult):

          self?.rawDocuments = searchResult.hits

          DispatchQueue.main.async { [weak self] in

            self?.resultMillisecondsLabel.stringValue = String(format: "Result: %d ms", searchResult.processingTimeMs ?? 0)

            self?.updateTableViewIfNeeded()
          }

        case .failure(let error):
          break
        }

      }

    }

  }

  private func updateComboBoxIfNeeded() {
    self.indexesComboBox.reloadData()
    self.indexesComboBox.selectItem(at: 0)
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

  private func updateTableViewIfNeeded() {

    self.toggleActivityIndicator(enabled: false)
    self.tableView.reloadData()

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

extension SearchViewController: NSTableViewDelegate {

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    let index: [String: Any] = rawDocuments[row].value as! [String: Any]

    let dd = tableColumn!.headerCell.stringValue
    let v = index[dd]

    let cell = NSTextField()
    cell.identifier = NSUserInterfaceItemIdentifier(dd)

    if let intValue = v as? Int {
      cell.integerValue = intValue
      cell.alphaValue = 1.0
    } else if let floatValue = v as? Float {
      cell.floatValue = floatValue
      cell.alphaValue = 1.0
    } else if let stringValue = v as? String {
      cell.stringValue = stringValue
      cell.alphaValue = 1.0
    } else if let vv = v {
      cell.stringValue = "\(vv)"
      cell.alphaValue = 1.0
    } else {
      cell.stringValue = "\"null\""
      cell.alphaValue = 0.5
    }

    return cell
  }

}

extension SearchViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    rawDocuments.count
  }

}

extension SearchViewController: NSSearchFieldDelegate {

  func controlTextDidChange(_ obj: Notification) {
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
    self.perform(#selector(performSearch), with: nil, afterDelay: searchField.stringValue.isEmpty ? 0.0 : 0.25)
  }

  @objc
  private func performSearch() {
    self.toggleActivityIndicator(enabled: true)
    loadDocumentsAsync()
  }

}

extension SearchViewController: NSComboBoxDelegate {

  func comboBoxSelectionDidChange(_ notification: Notification) {
    loadDocumentsAsync()
  }

}

extension SearchViewController: NSComboBoxDataSource {

  func numberOfItems(in comboBox: NSComboBox) -> Int {
    indexes.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    indexes[index].uid
  }

}
