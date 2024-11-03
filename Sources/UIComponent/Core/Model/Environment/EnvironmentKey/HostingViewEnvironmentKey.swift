//
//  HostingViewEnvironmentKey.swift
//
//
//  Created by Luke Zhao on 1/20/24.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

/// A environment key that holds a reference to the current `NSUIView` displaying the component.
public struct HostingViewEnvironmentKey: EnvironmentKey {
    public static var defaultValue: NSUIView? {
        nil
    }
    public static var isWeak: Bool {
        true
    }
}

public extension EnvironmentValues {
    /// The current NSUIView displaying the component, if one exists.
    /// This is a built-in environment value that is automatically populated during a reload.
    ///
    /// You can access the current hosting view via the ``Environment`` property wrapper inside the ``Component/layout(_:)`` method:
    /// ```swift
    /// @Environment(\.hostingView) var hostingView
    /// ```
    var hostingView: NSUIView? {
        get { self[HostingViewEnvironmentKey.self] }
        set { self[HostingViewEnvironmentKey.self] = newValue }
    }
}
