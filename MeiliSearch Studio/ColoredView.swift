//
//  ColoredView.swift
//  MeiliSearch Studio
//
//  Created by Pedro Paulo de Amorim on 22/09/2021.
//

import Foundation
import Cocoa
@IBDesignable class ColoredView: NSView {
    @IBInspectable var backgroundColor: NSColor = .clear
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        backgroundColor.set()
        dirtyRect.fill()
    }
}
