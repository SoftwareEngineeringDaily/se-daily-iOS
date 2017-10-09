//
//  Extensions.swift
//  KTResponsiveUI_Example
//
//  Created by Craig Holliday on 8/28/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

let iphone7Height: CGFloat = 667.0
let iphone7Width: CGFloat = 375.0

public extension UIView {
    public func topRightPoint() -> CGPoint {
        return CGPoint(x: self.frame.maxX, y: self.frame.minY)
    }
    
    public func topMidPoint() -> CGPoint {
        return CGPoint(x: self.frame.midX, y: self.frame.minY)
    }
    
    public func topLeftPoint() -> CGPoint {
        return CGPoint(x: self.frame.minX, y: self.frame.minY)
    }
    
    public func bottomRightPoint() -> CGPoint {
        return CGPoint(x: self.frame.maxX, y: self.frame.maxY)
    }
    
    public func bottomMidPoint() -> CGPoint {
        return CGPoint(x: self.frame.midX, y: self.frame.maxY)
    }
    
    public func bottomLeftPoint() -> CGPoint {
        return CGPoint(x: self.frame.minX, y: self.frame.maxY)
    }
    
    public func leftMidPoint() -> CGPoint {
        return CGPoint(x: self.frame.minX, y: self.frame.midY)
    }
    
    public func rightMidPoint() -> CGPoint {
        return CGPoint(x: self.frame.maxX, y: self.frame.midY)
    }
    
    public class func getValueScaledByScreenHeightFor(baseValue: CGFloat) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let divisor: CGFloat = iphone7Height / baseValue
        let calculatedHeight = screenHeight / divisor
        return calculatedHeight
    }
    
    public class func getValueScaledByScreenWidthFor(baseValue: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let divisor: CGFloat = iphone7Width / baseValue
        let calculatedWidth = screenWidth / divisor
        return calculatedWidth
    }
}


