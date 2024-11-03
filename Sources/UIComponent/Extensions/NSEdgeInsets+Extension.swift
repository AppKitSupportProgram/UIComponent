import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSEdgeInsets: @retroactive Equatable {
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        lhs.top == rhs.top && lhs.left == rhs.left && lhs.right == rhs.right && lhs
            .bottom == rhs.bottom
    }

    static let zero = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension CGRect {
    func inset(by edgeInsets: NSEdgeInsets) -> CGRect {
        var result = self
        result.origin.x += edgeInsets.left
        result.origin.y += edgeInsets.top
        result.size.width -= edgeInsets.left + edgeInsets.right
        result.size.height -= edgeInsets.top + edgeInsets.bottom
        return result
    }
}
#endif
