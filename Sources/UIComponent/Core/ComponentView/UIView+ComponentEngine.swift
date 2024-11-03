//
//  NSUIView+ComponentEngine.swift
//
//
//  Created by Luke Zhao on 7/17/24.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

extension NSUIView {
    // Access to the underlying Component Engine
    public var componentEngine: ComponentEngine {
        get {
            if let componentEngine = _componentEngine {
                return componentEngine
            }
            let componentEngine = ComponentEngine(view: self)
            _ = NSUIView.swizzle_setBounds
#if canImport(UIKit)
            _ = NSUIView.swizzle_layoutSubviews
            _ = NSUIView.swizzle_sizeThatFits
            
            
            _ = UIScrollView.swizzle_safeAreaInsetsDidChange
            _ = UIScrollView.swizzle_setContentInset
            
#endif
            _componentEngine = componentEngine
            return componentEngine
        }
    }
}

private struct AssociatedKeys {
    static var componentEngine: Void?
    static var onFirstReload: Void?
}

extension NSUIView {
    fileprivate var _componentEngine: ComponentEngine? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.componentEngine) as? ComponentEngine
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.componentEngine,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

#if canImport(UIKit)
    
    static let swizzle_sizeThatFits: Void = {
        guard let originalMethod = class_getInstanceMethod(NSUIView.self, #selector(sizeThatFits(_:))),
              let swizzledMethod = class_getInstanceMethod(NSUIView.self, #selector(swizzled_sizeThatFits(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_sizeThatFits(_ size: CGSize) -> CGSize {
        _componentEngine?.sizeThatFits(size) ?? swizzled_sizeThatFits(size)
    }
    static let swizzle_layoutSubviews: Void = {
        guard let originalMethod = class_getInstanceMethod(NSUIView.self, #selector(layoutSubviews)),
              let swizzledMethod = class_getInstanceMethod(NSUIView.self, #selector(swizzled_layoutSubviews))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_layoutSubviews() {
        swizzled_layoutSubviews()
        _componentEngine?.layoutSubview()
    }
#endif

    

    static let swizzle_setBounds: Void = {
        guard let originalMethod = class_getInstanceMethod(NSUIView.self, #selector(setter: bounds)),
              let swizzledMethod = class_getInstanceMethod(NSUIView.self, #selector(swizzled_setBounds(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_setBounds(_ bounds: CGRect) {
        swizzled_setBounds(bounds)
        _componentEngine?.setNeedsRender()
    }
}

#if canImport(UIKit)

extension UIScrollView {
    static let swizzle_safeAreaInsetsDidChange: Void = {
        guard let originalMethod = class_getInstanceMethod(UIScrollView.self, #selector(safeAreaInsetsDidChange)),
              let swizzledMethod = class_getInstanceMethod(UIScrollView.self, #selector(swizzled_safeAreaInsetsDidChange))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    static let swizzle_setContentInset: Void = {
        guard let originalMethod = class_getInstanceMethod(UIScrollView.self, #selector(setter: contentInset)),
              let swizzledMethod = class_getInstanceMethod(UIScrollView.self, #selector(swizzled_setContentInset(_:)))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_safeAreaInsetsDidChange() {
        guard responds(to: #selector(swizzled_safeAreaInsetsDidChange)) else { return }
        swizzled_safeAreaInsetsDidChange()
        if let componentEngine = _componentEngine, contentInsetAdjustmentBehavior != .never {
            componentEngine.setNeedsReload()
        }
    }

    @objc func swizzled_setContentInset(_ contentInset: NSUIEdgeInsets) {
        // when contentOffset is at the top, and contentSize is set
        // changing contentInset will not trigger a contentOffset change
        // we manually adjust the contentOffset back to the top
        // same for the horizontal axis
        let yAtTop = contentOffset.y <= -adjustedContentInset.top
        let xAtLeft = contentOffset.x <= -adjustedContentInset.left
        swizzled_setContentInset(contentInset)
        var newContentOffset = contentOffset
        if yAtTop {
            newContentOffset.y = -adjustedContentInset.top
        }
        if xAtLeft {
            newContentOffset.x = -adjustedContentInset.left
        }
        if newContentOffset != contentOffset {
            contentOffset = newContentOffset
        }
    }
}



#endif
