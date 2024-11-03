//  Created by Luke Zhao on 8/23/20.

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

/// Wraps a `component` inside a `NSUIView`.
///
/// This is used to power the `.view()` and `.scrollView()` modifiers.
public struct ViewWrapperComponent<View: NSUIView>: Component {
    let component: any Component
    public init(component: any Component) {
        self.component = component
    }
    public func layout(_ constraint: Constraint) -> ViewWrapperRenderNode<View> {
        let renderNode = component.layout(constraint)
        return ViewWrapperRenderNode(size: renderNode.size.bound(to: constraint), 
                                       component: component,
                                       content: renderNode)
    }
}

/// RenderNode for the `ViewWrapperComponent`
public struct ViewWrapperRenderNode<View: NSUIView>: RenderNode {
    public let size: CGSize
    public let component: any Component
    public let content: any RenderNode

    public var id: String? {
        content.id
    }
    public func updateView(_ view: View) {
        view.componentEngine.reloadWithExisting(component: component, renderNode: content)
    }
}
