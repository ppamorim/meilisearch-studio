//
//  MenuViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

struct Page {
  let title: String
  let icon: String
  let viewControllerName: String
}

final class MenuViewController: NSViewController {

  private weak var homeViewControllerDelegate: HomeViewControllerDelegate?

  fileprivate let items: [Page] = [
    Page(title: "Indexes", icon: "staroflife", viewControllerName: String(describing: IndexesViewController.self)),
    Page(title: "Documents", icon: "doc.text.magnifyingglass", viewControllerName: String(describing: DocumentsViewController.self)),
    Page(title: "Search", icon: "", viewControllerName: String(describing: IndexesViewController.self)),
    Page(title: "Settings", icon: "", viewControllerName: String(describing: IndexesViewController.self))
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

  func tintedImage(_ image: NSImage?, tint: NSColor) -> NSImage? {
      guard let uimage = image, let tinted = uimage.copy() as? NSImage else { return image }
      tinted.lockFocus()
      tint.set()

      let imageRect = NSRect(origin: NSZeroPoint, size: uimage.size)
      imageRect.fill(using: .sourceAtop)

      tinted.unlockFocus()
      return tinted
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Item"), owner: nil) as? NSTableCellView {
      let item = items[row]
      let image: NSImage? = !item.icon.isEmpty ? NSImage(named: item.icon) : nil
      cell.imageView?.image = tintedImage(image, tint: NSColor.white)
      cell.textField?.stringValue = item.title
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
