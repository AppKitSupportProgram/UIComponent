//
//  File.swift
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

/// The key for accessing the default font from the environment.
public struct FontEnvironmentKey: EnvironmentKey {
    public static var defaultValue: NSUIFont? {
        nil
    }
}

public extension EnvironmentValues {
    /// The font value in the environment.
    var font: NSUIFont? {
        get { self[FontEnvironmentKey.self] }
        set { self[FontEnvironmentKey.self] = newValue }
    }
}

public extension Component {
    /// Modifies the font environment value for the component.
    /// - Parameter font: The UIFont to be set in the environment.
    /// - Returns: An environment component with the new font value.
    func font(_ font: NSUIFont?) -> EnvironmentComponent<NSUIFont?, Self> {
        environment(\.font, value: font)
    }
}
