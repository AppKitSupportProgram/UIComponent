//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/24/20.
//

import UIKit

public struct Flow: Component, VerticalLayoutProtocol {
  public var lineSpacing: CGFloat
  public var interitemSpacing: CGFloat

  public var alignContent: MainAxisAlignment
  public var alignItems: CrossAxisAlignment
  public var justifyContent: MainAxisAlignment
  public var children: [Component]

  public init(lineSpacing: CGFloat = 0,
              interitemSpacing: CGFloat = 0,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              alignContent: MainAxisAlignment = .start,
              children: [Component]) {
    self.lineSpacing = lineSpacing
    self.interitemSpacing = interitemSpacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.alignContent = alignContent
    self.children = children
  }

  public init(spacing: CGFloat,
              justifyContent: MainAxisAlignment = .start,
              alignItems: CrossAxisAlignment = .start,
              alignContent: MainAxisAlignment = .start,
              children: [Component]) {
    self.init(lineSpacing: spacing,
              interitemSpacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              alignContent: alignContent,
              children: children)
  }
  
  public func layout(_ constraint: Constraint) -> Renderer {
    let crossMax = cross(constraint.maxSize)
    let childConstraint = Constraint(minSize: .zero, maxSize: size(main: .infinity, cross: crossMax))
    var renderers: [Renderer] = children.map {
      $0.layout(childConstraint)
    }
    var positions: [CGPoint] = []
    
    // calculate line size base on item sizes
    var lineData: [(lineSize: CGSize, count: Int)] = []
    var currentLineItemCount = 0
    var currentLineWidth: CGFloat = 0
    var currentLineMaxHeight: CGFloat = 0
    var totalHeight: CGFloat = 0
    for renderer in renderers {
      if currentLineWidth + cross(renderer.size) > crossMax, currentLineItemCount != 0 {
        lineData.append((lineSize: size(main: currentLineMaxHeight,
                                        cross: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing),
                         count: currentLineItemCount))
        totalHeight += currentLineMaxHeight
        currentLineMaxHeight = 0
        currentLineWidth = 0
        currentLineItemCount = 0
      }
      currentLineMaxHeight = max(currentLineMaxHeight, main(renderer.size))
      currentLineWidth += cross(renderer.size) + interitemSpacing
      currentLineItemCount += 1
    }
    if currentLineItemCount > 0 {
      lineData.append((lineSize: size(main: currentLineMaxHeight,
                                      cross: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing),
                       count: currentLineItemCount))
      totalHeight += currentLineMaxHeight
    }
    
    var (mainOffset, mainSpacing) = LayoutHelper.distribute(justifyContent: alignContent,
                                                            maxPrimary: main(constraint.maxSize),
                                                            totalPrimary: totalHeight,
                                                            minimunSpacing: lineSpacing,
                                                            numberOfItems: lineData.count)

    // layout each line
    var lineStartIndex = 0
    for (var lineSize, count) in lineData {
      let range = lineStartIndex ..< (lineStartIndex + count)
      
      // resize flex items
      let flexCount = children[range].reduce(0) { result, next in
        result + ((next as? Flexible)?.flex ?? 0)
      }
      if flexCount > 0, crossMax != .infinity {
        let crossPerFlex = max(0, crossMax - cross(lineSize)) / flexCount
        for index in range {
          let child = children[index]
          if let child = child as? Flexible {
            let crossReserved = crossPerFlex * child.flex + cross(renderers[index].size)
            let constraint = Constraint(minSize: size(main: alignItems == .stretch ? main(lineSize) : 0, cross: crossReserved),
                                        maxSize: size(main: .infinity, cross: crossReserved))
            renderers[index] = child.layout(constraint)
          }
        }
        lineSize = size(main: main(lineSize), cross: crossMax)
      }
      
      // distribute on the cross axis
      var (crossOffset, crossSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                                maxPrimary: crossMax,
                                                                totalPrimary: cross(lineSize),
                                                                minimunSpacing: interitemSpacing,
                                                                numberOfItems: count)

      // finally, layout all of the items on this line
      for (itemIndex, var child) in renderers[lineStartIndex ..< (lineStartIndex + count)].enumerated() {
        let childComponent = children[lineStartIndex + itemIndex]
        if alignItems == .stretch, main(child.size) != main(lineSize) {
          // relayout items with a fixed main size
          child = childComponent.layout(Constraint(minSize: size(main: main(lineSize), cross: 0),
                                                   maxSize: size(main: main(lineSize), cross: crossMax)))
          renderers[lineStartIndex + itemIndex] = child
        }
        let alignValue: CGFloat
        switch alignItems {
        case .start, .stretch:
          alignValue = 0
        case .end:
          alignValue = main(lineSize) - main(child.size)
        case .center:
          alignValue = (main(lineSize) - main(child.size)) / 2
        }
        positions.append(point(main: mainOffset + alignValue, cross: crossOffset))
        crossOffset += cross(child.size) + crossSpacing
      }
  
      mainOffset += main(lineSize) + mainSpacing
      lineStartIndex += count
    }
    
    let intrisicMain = mainOffset - mainSpacing
    let finalMain = alignContent != .start && main(constraint.maxSize) != .infinity ? max(main(constraint.maxSize), intrisicMain) : intrisicMain
    let finalSize = size(main: finalMain, cross: crossMax)
    return renderer(size: finalSize, children: renderers, positions: positions)
  }
}


public extension Flow {
  init(spacing: CGFloat = 0, justifyContent: MainAxisAlignment = .start, alignItems: CrossAxisAlignment = .start, @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(spacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              children: content())
  }
}

public extension Flow {
  init(lineSpacing: CGFloat = 0,
       interitemSpacing: CGFloat = 0,
       justifyContent: MainAxisAlignment = .start,
       alignItems: CrossAxisAlignment = .start,
       alignContent: MainAxisAlignment = .start,
       @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(lineSpacing: lineSpacing, interitemSpacing: interitemSpacing, justifyContent: justifyContent, alignItems: alignItems, alignContent: alignContent, children: content())
  }
  init(spacing: CGFloat = 0,
       justifyContent: MainAxisAlignment = .start,
       alignItems: CrossAxisAlignment = .start,
       alignContent: MainAxisAlignment = .start,
       @ComponentArrayBuilder _ content: () -> [Component]) {
    self.init(spacing: spacing, justifyContent: justifyContent, alignItems: alignItems, alignContent: alignContent, children: content())
  }
}
