//  Created by Luke Zhao on 8/22/20.

import UIKit

public protocol UIComponentRenderableView {
  init()
}
extension UIView: UIComponentRenderableView {}

@dynamicMemberLookup
public protocol ViewRenderNode: AnyViewRenderNode {
  associatedtype View: UIComponentRenderableView
  func makeView() -> View
  func updateView(_ view: View)
}

extension ViewRenderNode {
  // MARK: Default
  public func makeView() -> View {
    View()
  }
  public func _makeView() -> Any {
    if View.self is UIView.Type, let reuseKey = reuseKey {
      return ReuseManager.shared.dequeue(identifier: reuseKey, makeView() as! UIView)
    }
    return makeView()
  }
  // MARK: AnyViewRenderNode
  public func _updateView(_ view: Any) {
    guard let view = view as? View else { return }
    return updateView(view)
  }
}
