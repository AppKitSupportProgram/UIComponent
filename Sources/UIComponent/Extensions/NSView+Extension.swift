//
//  NSView+Extension.swift
//  ChatLayout
//
//  Created by JH on 2024/1/12.
//  Copyright © 2024 Eugene Kazaev. All rights reserved.
//

import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSView {
    func layoutIfNeeded() {
        layoutSubtreeIfNeeded()
    }

    func setNeedsLayout() {
        needsLayout = true
    }

    func setNeedsDisplay() {
        needsDisplay = true
    }

    func setNeedsUpdateConstraints() {
        needsUpdateConstraints = true
    }

    var alpha: CGFloat {
        set {
            alphaValue = newValue
        }
        get {
            alphaValue
        }
    }

    func setWantsLayer() {
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }

    var transform: CGAffineTransform {
        set {
            setWantsLayer()
            setValue(newValue, forKeyPath: "frameTransform")
        }
        get {
            setWantsLayer()
            return value(forKeyPath: "frameTransform") as? CGAffineTransform ?? .identity
        }
    }

    var backgroundColor: NSColor? {
        set {
            setWantsLayer()
            setValue(newValue, forKeyPath: "backgroundColor")
        }
        get {
            setWantsLayer()
            return value(forKeyPath: "backgroundColor") as? NSColor
        }
    }

    static func performWithoutAnimation(_ block: () -> Void) {
        NSAnimationContext.runAnimationGroup { context in
            let allowsImplicitAnimation = context.allowsImplicitAnimation
            context.allowsImplicitAnimation = false
            block()
            context.allowsImplicitAnimation = allowsImplicitAnimation
        }
    }

    var center: NSPoint {
        get {
            return NSPoint(x: frame.midX, y: frame.midY)
        }
        set {
            frame.origin = NSPoint(
                x: newValue.x - frame.width / 2,
                y: newValue.y - frame.height / 2
            )
        }
    }
}

extension NSView {
    func insertSubview(_ view: NSView, at index: Int) {
        let subviews = self.subviews
        guard index >= 0, index <= subviews.count else { return }

        if index == subviews.count {
            addSubview(view)
        } else {
            let siblingView = subviews[index]
            addSubview(view, positioned: .below, relativeTo: siblingView)
        }
    }

    func insertSubview(_ view: NSView, aboveSubview siblingSubview: NSView) {
        addSubview(view, positioned: .above, relativeTo: siblingSubview)
    }

    func insertSubview(_ view: NSView, belowSubview siblingSubview: NSView) {
        addSubview(view, positioned: .below, relativeTo: siblingSubview)
    }

    func bringToFront() {
        guard let superview = superview else { return }
        superview.addSubview(self, positioned: .above, relativeTo: nil)
    }

    func sendToBack() {
        guard let superview = superview else { return }
        superview.addSubview(self, positioned: .below, relativeTo: nil)
    }

    func bringSubview(toFront view: NSView) {
        view.bringToFront()
    }

    func sendSubview(toBack view: NSView) {
        view.sendToBack()
    }

    func point(inside point: NSPoint, with event: NSEvent?) -> Bool {
        // 转换为视图坐标系
        let localPoint = convert(point, from: nil)
        return bounds.contains(localPoint)
    }
}

extension NSScrollView {
    var zoomScale: CGFloat {
        get {
            magnification
        }
        set {
            magnification = newValue
        }
    }

    var adjustedContentInset: NSEdgeInsets {
        contentInsets
    }

    func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        if animated {
            animator().scrollToVisible(rect)
        } else {
            scrollToVisible(rect)
        }
    }

    var contentSize: CGSize {
        set {
            documentView?.frame.size = newValue
        }
        get {
            documentView?.frame.size ?? .zero
        }
    }
}

extension NSColor {
    static let separator = NSColor.separatorColor
}

#endif

extension NSUIView {
    func _sizeThatFits(_ size: CGSize) -> CGSize {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        if let control = self as? NSControl {
            return control.sizeThatFits(size)
        } else {
            return bounds.size
        }
        #endif

        #if canImport(UIKit)
        return sizeThatFits(size)
        #endif
    }

    var _layer: CALayer? {
        layer
    }
}
