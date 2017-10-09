//
//  CustomView.swift
//  KTResponsiveUI_Example
//
//  Created by Craig Holliday on 8/28/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

// Protocol to make sure we have common function to use to layout subviews
// This is easier than overriding init() in every class
public protocol KTLayoutProtocol {
    init()
    func performLayout()
}

public extension KTLayoutProtocol where Self: UIView {
    // Our custom init
    //  - Parameters:
    //      - origin: Point of origin (default is (0,0) like a grid)
    //      - topInset: points from the top of immediate superview or origin when set (default is 0)
    //      - leftInset: points from the left of immediate superview or origin when set (default is 0)
    //      - width: width of view. Will be calculated using .getValueScaledByScreenWidthFor(baseValue: CGFloat) Extension
    //      - height: height of view. Will be calculated using .getValueScaledByScreenHeightFor(baseValue: CGFloat) Extension
    init(origin: CGPoint,
         leftInset: CGFloat,
         topInset: CGFloat,
         width: CGFloat,
         height: CGFloat,
         keepEqual: Bool) {
        
        // Calculate position of new frame
        let cx = origin.x + UIView.getValueScaledByScreenWidthFor(baseValue: leftInset)
        let cy = origin.y + UIView.getValueScaledByScreenHeightFor(baseValue: topInset)

        // Calculate width and height
        var cWidth = UIView.getValueScaledByScreenWidthFor(baseValue: width)
        var cHeight = UIView.getValueScaledByScreenHeightFor(baseValue: height)
        
        // Here we check if either width or height is 0 which we are assuming means that the variable that isn't 0 should be equal to the variable that has been set
        if keepEqual {
            if width == 0 {
                cWidth = cHeight
            }
            if height == 0 {
                cHeight = cWidth
            }
        }
        
        // Create new frame
        let newFrame = CGRect(x: cx, y: cy, width: cWidth, height: cHeight)
        
        self.init()
        self.frame = newFrame
        self.performLayout()
    }
    
    // ---
    init(leftInset: CGFloat, topInset: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: leftInset,
                  topInset: topInset,
                  width: width,
                  height: height,
                  keepEqual: false)
    }
    init(leftInset: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: leftInset,
                  topInset: 0,
                  width: width,
                  height: height,
                  keepEqual: false)
    }
    init(topInset: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: 0,
                  topInset: topInset,
                  width: width,
                  height: height,
                  keepEqual: false)
    }
    
    // ---
    init(origin: CGPoint, leftInset: CGFloat, topInset: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: leftInset,
                  topInset: topInset,
                  width: width,
                  height: height,
                  keepEqual: false)
    }
    init(origin: CGPoint, leftInset: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: leftInset,
                  topInset: 0,
                  width: width,
                  height: height,
                  keepEqual: false)
    }
    init(origin: CGPoint, topInset: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: 0,
                  topInset: topInset,
                  width: width,
                  height: height,
                  keepEqual: false)
    }
    
    // ---
    init(leftInset: CGFloat, topInset: CGFloat, width: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: leftInset,
                  topInset: topInset,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(leftInset: CGFloat, topInset: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: leftInset,
                  topInset: topInset,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    
    // ---
    init(origin: CGPoint, leftInset: CGFloat, topInset: CGFloat, width: CGFloat) {
        self.init(origin: origin,
                  leftInset: leftInset,
                  topInset: topInset,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(origin: CGPoint, leftInset: CGFloat, topInset: CGFloat, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: leftInset,
                  topInset: topInset,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    
    // ---
    init(leftInset: CGFloat, width: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: leftInset,
                  topInset: 0,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(leftInset: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: leftInset,
                  topInset: 0,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    init(topInset: CGFloat, width: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: 0,
                  topInset: topInset,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(topInset: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: 0,
                  topInset: topInset,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    
    // ---
    init(origin: CGPoint, leftInset: CGFloat, width: CGFloat) {
        self.init(origin: origin,
                  leftInset: leftInset,
                  topInset: 0,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(origin: CGPoint, leftInset: CGFloat, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: leftInset,
                  topInset: 0,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    init(origin: CGPoint, topInset: CGFloat, width: CGFloat) {
        self.init(origin: origin,
                  leftInset: 0,
                  topInset: topInset,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(origin: CGPoint, topInset: CGFloat, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: 0,
                  topInset: topInset,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    
    // ---
    init(width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: 0,
                  topInset: 0,
                  width: width,
                  height: 0,
                  keepEqual: false)
    }
    init(origin: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: 0,
                  topInset: 0,
                  width: width,
                  height: height,
                  keepEqual: false)
    }
    
    // ---
    init(width: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: 0,
                  topInset: 0,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(height: CGFloat) {
        self.init(origin: CGPoint(x: 0,y: 0),
                  leftInset: 0,
                  topInset: 0,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    
    // ---
    init(origin: CGPoint, width: CGFloat) {
        self.init(origin: origin,
                  leftInset: 0,
                  topInset: 0,
                  width: width,
                  height: 0,
                  keepEqual: true)
    }
    init(origin: CGPoint, height: CGFloat) {
        self.init(origin: origin,
                  leftInset: 0,
                  topInset: 0,
                  width: 0,
                  height: height,
                  keepEqual: true)
    }
    
}

// Everything boiled down to a single extension
extension UIView: KTLayoutProtocol {
    @objc open func performLayout() {}
}
