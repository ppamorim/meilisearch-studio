//
//  MenuViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

final class MenuViewController: NSViewController {

  private weak var homeViewControllerDelegate: HomeViewControllerDelegate?

  fileprivate let items: [String] = [
    "Indexes",
    "Documents",
    "Search",
    "Settings"
  ]

  @IBOutlet weak var tableView: NSTableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    homeViewControllerDelegate = self.parent as? HomeViewControllerDelegate
    tableView.delegate = self
    tableView.dataSource = self
    tableView.target = self
    tableView.action = #selector(tableViewClick(_:))
  }

  @objc
  private func tableViewClick(_ sender:AnyObject) {
    homeViewControllerDelegate?.openPage(position: tableView.selectedRow)
  }

}

extension MenuViewController: NSTableViewDelegate {

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Item"), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = items[row]
      return cell
    }
    return nil
  }

}

extension MenuViewController: NSTableViewDataSource {

  func numberOfRows(in tableView: NSTableView) -> Int {
    return items.count
  }

}
