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

enum ConnectivityStatus {
  case connecting, disconnected, connected
}

protocol MenuViewControllerDelegate: AnyObject {
  func updateConnectionStatus(_ status: ConnectivityStatus)
}

final class MenuViewController: NSViewController, MenuViewControllerDelegate {

  private weak var homeViewControllerDelegate: HomeViewControllerDelegate?

  fileprivate let items: [Page] = [
    Page(title: "Home", icon: "house", viewControllerName: ""),
    Page(title: "Indexes", icon: "doc.on.doc", viewControllerName: String(describing: IndexesViewController.self)),
    Page(title: "Documents", icon: "doc.plaintext", viewControllerName: String(describing: DocumentsViewController.self)),
    Page(title: "Search", icon: "doc.text.magnifyingglass", viewControllerName: String(describing: SearchViewController.self)),
    Page(title: "Settings", icon: "gearshape", viewControllerName: String(describing: SettingsViewController.self))
  ]

  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var connectionStatusLabel: NSTextField!
  @IBOutlet weak var disconnectButton: NSButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    homeViewControllerDelegate = self.parent as? HomeViewControllerDelegate
    tableView.delegate = self
    tableView.dataSource = self
    tableView.target = self
    tableView.action = #selector(tableViewClick(_:))
    tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
  }

  @objc
  private func tableViewClick(_ sender:AnyObject) {
    homeViewControllerDelegate?.openPage(page: items[tableView.selectedRow])
  }
  
  @IBAction func disconnectButtonTouchUpInside(_ sender: Any) {
    homeViewControllerDelegate?.disconnect()
  }
  
  func updateConnectionStatus(_ status: ConnectivityStatus) {
    switch status {
    case ConnectivityStatus.disconnected:
      connectionStatusLabel.stringValue = "Status: Disconnected"
    case ConnectivityStatus.connected:
      connectionStatusLabel.stringValue = "Status: Connected"
    case ConnectivityStatus.connecting:
      connectionStatusLabel.stringValue = "Status: Connecting"
    }
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
