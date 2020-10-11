//
//  HomeViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

protocol HomeViewControllerDelegate: AnyObject {
  var pageViewController: PageViewController? { get set }
  func openPage(page: Page)
}

final class HomeViewController: NSSplitViewController, HomeViewControllerDelegate {

  var pageViewController: PageViewController?

  func openPage(page: Page) {
    pageViewController?.openPage(page: page)
  }

}
