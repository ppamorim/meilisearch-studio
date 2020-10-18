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
  private var originalIndexes: [Index] = []
  private weak var windowController: NSWindowController?

  @IBOutlet weak var backgroundView: NSView!
  @IBOutlet weak var statusBarView: NSView!
  @IBOutlet weak var scrollView: NSScrollView!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var searchField: NSSearchField!

  @IBOutlet weak var modifyButton: NSButton!
  @IBOutlet weak var deleteButton: NSButton!
  @IBOutlet weak var reloadButton: NSButton!
  @IBOutlet weak var reloadProgressIndicator: NSProgressIndicator!

  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    return dateFormatter
  }()
  
  deinit {
    windowController = nil
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.addIndexViewControllerDelegate = nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    backgroundView.wantsLayer = true
    backgroundView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    searchField.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
    tableView.target = self
    tableView.action = #selector(indexSelected)
    loadIndexesAsync()
  }

  @objc
  private func indexSelected() {
    let index: Int = self.tableView.selectedRow
    let itemSelected: Bool = index >= 0
    modifyButton.isEnabled = itemSelected
    deleteButton.isEnabled = itemSelected
  }

  @IBAction func addIndexClick(_ sender: Any) {
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.addIndexViewControllerDelegate = self

    let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
    let windowController = storyboard.instantiateController(
      withIdentifier: NSStoryboard.SceneIdentifier("AddIndexWindowController")) as! NSWindowController
    self.windowController = windowController
    windowController.window?.makeKeyAndOrderFront(nil)
    windowController.showWindow(self)
  }

  @IBAction func modifyIndexClick(_ sender: Any) {
  }

  @IBAction func deleteIndexClick(_ sender: Any) {

    let index: Int = self.tableView.selectedRow

    if index < 0 {
      return
    }

    let UID: String = indexes[index].UID

    let delete = dialogCustomCancel(
      question: "Are you sure to delete the Index \"\(UID)\"?",
      text: "This index will be deleted and you can't undo this action.",
      firstButtonText: "Delete")

    if delete {
      deleteIndexAsync(UID)
    }
  }

  @IBAction func onReloadClick(_ sender: Any) {
    loadIndexesAsync(clean: false)
  }

  private func loadIndexesAsync(clean: Bool = true) {

    self.reloadProgressIndicator.isHidden = false
    self.reloadProgressIndicator.startAnimation(nil)
    self.reloadButton.isEnabled = false

    let queue = DispatchQueue(label: "LoadIndexesQueue")
    queue.asyncAfter(deadline: .now() + 0.5) {

      MeiliSearchClient.shared.client.getIndexes { [weak self] result in

        switch result {
        case .success(let indexes):

          self?.originalIndexes = indexes
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

  private func deleteIndexAsync(_ UID: String) {

    let queue = DispatchQueue(label: "DeleteIndexQueue")
    queue.async {

      MeiliSearchClient.shared.client.deleteIndex(UID: UID) { [weak self] result in

        switch result {
        case .success:

          DispatchQueue.main.async { [weak self] in
            self?.loadIndexesAsync(clean: false)
          }

        case .failure(let error):
          print("[IndexesViewController] error \(error)")

        }

      }

    }

  }



  private func updateTableViewIfNeeded() {
    self.tableView.reloadData()
    self.reloadProgressIndicator.isHidden = true
    self.reloadProgressIndicator.stopAnimation(nil)

    //Menu
    self.reloadButton.isEnabled = true


  }

  private func dialogCustomCancel(question: String, text: String, firstButtonText: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: firstButtonText)
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
  }
  
}

extension IndexesViewController: NSSearchFieldDelegate {

  func controlTextDidChange(_ obj: Notification) {
    let UID: String = searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    self.indexes = originalIndexes.filter { (index: Index) in index.UID.contains(UID) }
    self.updateTableViewIfNeeded()
  }

}

extension IndexesViewController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let IndexNameCell = "IndexName"
    static let IndexPrimaryKey = "IndexPrimaryKey"
    static let IndexCreatedAtCell = "IndexCreatedAt"
    static let IndexUpdatedAtCell = "IndexUpdatedAt"
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var text: String = ""
    var cellIdentifier: String = ""

    let index = indexes[row]

    if tableColumn == tableView.tableColumns[0] {
      text = index.UID
      cellIdentifier = CellIdentifiers.IndexNameCell
    } else if tableColumn == tableView.tableColumns[1] {
      text = index.primaryKey ?? "\"null\""
      cellIdentifier = CellIdentifiers.IndexPrimaryKey
    } else if tableColumn == tableView.tableColumns[2] {
      if let date = index.createdAt {
        text = dateFormatter.string(from: date)
      } else {
        text = "null"
      }
      cellIdentifier = CellIdentifiers.IndexCreatedAtCell
    } else if tableColumn == tableView.tableColumns[3] {
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

extension IndexesViewController: AddIndexViewControllerDelegate {

  func onIndexAdded() {
    loadIndexesAsync(clean: false)
  }

}
