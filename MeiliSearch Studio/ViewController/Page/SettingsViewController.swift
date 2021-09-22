//
//  SettingsViewController.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 18/10/2020.
//

import Cocoa
import MeiliSearch

final class SettingsViewController: NSViewController {

  @IBOutlet weak var backgroundView: ColoredView!
  @IBOutlet weak var clipView: NSClipView!
  @IBOutlet var textView: NSTextView!
  @IBOutlet weak var buildLabel: NSTextField!
  
  override func loadView() {
    super.loadView()
    backgroundView.backgroundColor = NSColor.controlBackgroundColor
    clipView.wantsLayer = true
    clipView.layer?.cornerRadius = 8.0
    
    buildLabel.stringValue = "Version 1.0.0 - Alpha"
    
    textView.string = """
    MIT License

    Copyright (c) 2021 Pedro Paulo Amorim

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    """
  }
  
}
