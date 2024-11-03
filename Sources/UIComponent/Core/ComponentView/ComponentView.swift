//  Created by Luke Zhao on 8/27/20.

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

/// A `NSUIView` that can render components.
/// It provides simple access to the properties and method of the underlying ``ComponentEngine``
///
/// You can set the ``component`` property with your component tree for it to render
/// The render happens on the next layout cycle. But you can call ``reloadData`` to force it to render.
///
/// Most of the code is written in ``ComponentDisplayableView``, since both ``ComponentView``
/// and ``ComponentScrollView`` supports rendering components.
///
/// See ``ComponentDisplayableView`` for usage details.
open class ComponentView: NSUIView, ComponentDisplayableView {
}

/// A `UIScrollView` that can render components
/// It provides simple access to the properties and method of the underlying ``ComponentEngine``
///
/// You can set the ``component`` property with your component tree for it to render
/// The render happens on the next layout cycle. But you can call ``reloadData`` to force it to render.
///
/// Most of the code is written in ``ComponentDisplayableView``, since both ``ComponentView``
/// and ``ComponentScrollView`` supports rendering components.
///
/// See ``ComponentDisplayableView`` for usage details.
open class ComponentScrollView: NSUIScrollView, ComponentDisplayableView {
}
