//
//  PageViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

final class PageViewController: NSViewController {

  private weak var homeViewControllerDelegate: HomeViewControllerDelegate?

  private var viewController: NSViewController?

  override func viewDidLoad() {
    super.viewDidLoad()
    homeViewControllerDelegate = self.parent as? HomeViewControllerDelegate
    homeViewControllerDelegate?.pageViewController = self
  }

  func openPage(page: Page) {

    if let viewController = self.viewController {
      viewController.view.removeFromSuperview()
      self.viewController = nil
    }

    let storyboard = NSStoryboard(name: "Main", bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier(page.viewControllerName)
    viewController = storyboard.instantiateController(identifier: identifier, creator: { coder in IndexesViewController(coder: coder) })

    guard let viewController: NSViewController = self.viewController else {
      return
    }

    self.addChild(viewController)
    viewController.view.frame = self.view.frame
    self.view.addSubview(viewController.view)
    self.view.needsUpdateConstraints = true
    self.updateViewConstraints()

  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
    guard let viewController = self.viewController else {
      return
    }
    let edges: [NSLayoutConstraint.Attribute] = [.top, .bottom, .leading, .trailing]
    for edge in edges {
      self.view.addConstraint(
        NSLayoutConstraint(
          item: viewController.view,
          attribute: edge,
          relatedBy: .equal,
          toItem: self.view,
          attribute: edge,
          multiplier: 1.0,
          constant: 0))
    }
  }

}
