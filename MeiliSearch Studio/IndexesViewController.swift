//
//  IndexesViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa
import MeiliSearch

final class IndexesViewController: NSViewController {

  private var indexes: [Index] = []

  @IBOutlet weak var backgroundView: NSView!
  @IBOutlet weak var scrollView: NSScrollView!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var warningLabel: NSTextField!
  @IBOutlet weak var reloadButton: NSButton!
  @IBOutlet weak var progressIndicator: NSProgressIndicator!

  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundView.wantsLayer = true
    backgroundView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    tableView.delegate = self
    tableView.dataSource = self
    tableView.target = self
    loadIndexesAsync()
  }

  @IBAction func onReloadClick(_ sender: Any) {
  }

  private func loadIndexesAsync() {

    self.scrollView.isHidden = true
    self.warningLabel.isHidden = true
    self.reloadButton.isHidden = true
    self.progressIndicator.isHidden = false
    self.progressIndicator.startAnimation(nil)

    let queue = DispatchQueue(label: "LoadIndexesQueue")
    queue.asyncAfter(deadline: .now() + 0.5) {

      MeiliSearchClient.shared.client.getIndexes { [weak self] result in

        switch result {
        case .success(let indexes):

          self?.indexes = indexes

          DispatchQueue.main.async { [weak self] in
            self?.updateTableViewIfNeeded()
          }

        case .failure(let error):
          print("[IndexesViewController] error \(error)")

        }

      }

    }

  }

  private func updateTableViewIfNeeded() {
    self.tableView.reloadData()

    if self.indexes.isEmpty {
      self.progressIndicator.isHidden = true
      self.scrollView.isHidden = true
      self.warningLabel.isHidden = false
      self.reloadButton.isHidden = false
      return
    }

    self.progressIndicator.isHidden = true
    self.scrollView.isHidden = false
    self.warningLabel.isHidden = true
    self.reloadButton.isHidden = true
  }
  
}

extension IndexesViewController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
      static let IndexNameCell = "IndexName"
      static let IndexCreatedAtCell = "IndexCreatedAt"
      static let IndexUpdatedAtCell = "IndexUpdatedAt"
    }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var text: String = ""
    var cellIdentifier: String = ""

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long

    let index = indexes[row]

    if tableColumn == tableView.tableColumns[0] {
      text = index.UID
      cellIdentifier = CellIdentifiers.IndexNameCell
    } else if tableColumn == tableView.tableColumns[1] {
      if let date = index.createdAt {
        text = dateFormatter.string(from: date)
      } else {
        text = "null"
      }
      cellIdentifier = CellIdentifiers.IndexCreatedAtCell
    } else if tableColumn == tableView.tableColumns[2] {
      if let date = index.updatedAt {
        text = dateFormatter.string(from: date)
      } else {
        text = "null"
      }
      cellIdentifier = CellIdentifiers.IndexUpdatedAtCell
    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    return nil
  }

}

extension IndexesViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return indexes.count
  }

}
