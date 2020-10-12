//
//  MenuViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

struct Page {
  let title: String
  let viewControllerName: String
}

final class MenuViewController: NSViewController {

  private weak var homeViewControllerDelegate: HomeViewControllerDelegate?

  fileprivate let items: [Page] = [
    Page(title: "Indexes", viewControllerName: String(describing: IndexesViewController.self)),
    Page(title: "Documents", viewControllerName: String(describing: DocumentsViewController.self)),
    Page(title: "Search", viewControllerName: String(describing: IndexesViewController.self)),
    Page(title: "Settings", viewControllerName: String(describing: IndexesViewController.self))
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
    homeViewControllerDelegate?.openPage(page: items[tableView.selectedRow])
  }

}

extension MenuViewController: NSTableViewDelegate {

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Item"), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = items[row].title
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
