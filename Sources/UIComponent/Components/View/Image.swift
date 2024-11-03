//  Created by Luke Zhao on 8/23/20.

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

/// An image component that renders an UIImageView
public struct Image: Component {
    /// The underlying `UIImage` instance.
    public let image: NSUIImage

    /// Initializes an `Image` component with the name of an image asset.
    /// - Parameter imageName: The name of the image asset to load.
    /// - Note: In DEBUG mode, if the image is not found, an assertion failure is triggered.
    public init(_ imageName: String) {
        #if DEBUG
        if let image = NSUIImage(named: imageName) {
            self.init(image)
        } else {
            let error = "Image should be initialized with a valid image name. Image named \(imageName) not found."
            assertionFailure(error)
            self.init(NSUIImage())
        }
        #else
        self.init(NSUIImage(named: imageName) ?? NSUIImage())
        #endif
    }

    /// Initializes an `Image` component with an `ImageResource`.
    /// - Parameter resource: The `ImageResource` to load the image from.
    @available(macOS 14.0, iOS 17.0, *)
    public init(_ resource: ImageResource) {
        self.init(NSUIImage(resource: resource))
    }

    /// Initializes an `Image` component with the name of a system image (SFSymbol).
    /// - Parameters:
    ///   - systemName: The name of the system image to load.
    ///   - configuration: The configuration to use for the system image.
    /// - Note: In DEBUG mode, if the system image is not found, an assertion failure is triggered.
    @available(iOS 13.0, macOS 11.0, *)
    public init(systemName: String, withConfiguration configuration: NSUIImageSymbolConfiguration? = nil) {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        var systemImage = NSUIImage(systemSymbolName: systemName, accessibilityDescription: nil)
        if let configuration {
            systemImage = systemImage?.withSymbolConfiguration(configuration)
        }
        #if DEBUG
        if let systemImage {
            self.init(systemImage)
        } else {
            let error = "Image should be initialized with a valid system image name. System image named \(systemName) not found."
            assertionFailure(error)
            self.init(NSUIImage())
        }
        #else
        self.init(systemImage ?? NSUIImage())
        #endif
        #endif

        #if canImport(UIKit)
        let systemImage = NSUIImage(systemName: systemName, withConfiguration: configuration)
        #if DEBUG
        if let systemImage {
            self.init(systemImage)
        } else {
            let error = "Image should be initialized with a valid system image name. System image named \(systemName) not found."
            assertionFailure(error)
            self.init(NSUIImage())
        }
        #else
        self.init(systemImage ?? NSUIImage())
        #endif
        #endif
    }

    /// Initializes an `Image` component with a `UIImage` instance.
    /// - Parameter image: The `UIImage` instance to use for the component.
    public init(_ image: NSUIImage) {
        self.image = image
    }

    /// Calculates the layout for the image within the given constraints and returns an `ImageRenderNode`.
    /// - Parameter constraint: The constraints to use for sizing the image.
    /// - Returns: An `ImageRenderNode` that represents the laid out image.
    public func layout(_ constraint: Constraint) -> ImageRenderNode {
        ImageRenderNode(image: image, size: image.size.bound(to: constraint))
    }
}

/// A render node that represents an image.
public struct ImageRenderNode: RenderNode {
    /// The image to be rendered.
    public let image: NSUIImage
    /// The size to render the image.
    public let size: CGSize

    /// Updates the given image view with the render node's image.
    /// - Parameter view: The image view to update.
    public func updateView(_ view: NSUIImageView) {
        view.image = image
    }
}
