//
//  HomeViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 11/10/2020.
//

import Cocoa

protocol HomeViewControllerDelegate: AnyObject {
  var pageViewController: PageViewController? { get set }
  func openPage(position: Int)
}

final class HomeViewController: NSSplitViewController, HomeViewControllerDelegate {

  var pageViewController: PageViewController?

  func openPage(position: Int) {
    pageViewController?.openPage(position: position)
  }

}
