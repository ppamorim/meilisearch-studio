//
//  PageViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

final class PageViewController: NSViewController {

  private weak var homeViewControllerDelegate: HomeViewControllerDelegate?

  private var viewController: IndexesViewController?

  override func viewDidLoad() {
    super.viewDidLoad()
    homeViewControllerDelegate = self.parent as? HomeViewControllerDelegate
    homeViewControllerDelegate?.pageViewController = self
  }

  func openPage(position: Int) {
    print("openPage \(position)")

    if let viewController = self.viewController {
      viewController.view.removeFromSuperview()
      self.viewController = nil
    }

    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("IndexesViewController")
    viewController = storyboard.instantiateController(identifier: identifier, creator: { coder in IndexesViewController(coder: coder) }) as! IndexesViewController

    guard let viewController: IndexesViewController = self.viewController else {
      return
    }

    self.addChild(viewController)
    viewController.view.frame = self.view.frame
    self.view.addSubview(viewController.view)

  }

}
