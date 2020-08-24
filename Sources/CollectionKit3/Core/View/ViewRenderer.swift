//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/22/20.
//

import UIKit

@dynamicMemberLookup
public protocol ViewRenderer: AnyViewRenderer {
  associatedtype View: UIView
  var reuseKey: String? { get }
  func makeView() -> View
  func updateView(_ view: View)
}

public extension ViewRenderer {
  // MARK: Default
  var reuseKey: String? {
    "\(type(of: self))"
  }
  func makeView() -> View {
    View()
  }
  // MARK: AnyViewRenderer
  func _makeView() -> UIView {
    if let reuseKey = reuseKey {
      return CollectionReuseManager.shared.dequeue(identifier: reuseKey, makeView())
    }
    return makeView()
  }
  func _updateView(_ view: UIView) {
    guard let view = view as? View else { return }
    return updateView(view)
  }
}
