//
//  Extensions.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

extension Int {
    func calculateHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let divisor: CGFloat = 667 / CGFloat(self)
        let calculatedHeight = screenHeight / divisor
        return calculatedHeight
    }
    
    func calculateWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let divisor: CGFloat = 375.0 / CGFloat(self)
        let calculatedWidth = screenWidth / divisor
        return calculatedWidth
    }
}

extension Double {
    func calculateHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let divisor: CGFloat = 667 / CGFloat(self)
        let calculatedHeight = screenHeight / divisor
        return calculatedHeight
    }
    
    func calculateWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let divisor: CGFloat = 375.0 / CGFloat(self)
        let calculatedWidth = screenWidth / divisor
        return calculatedWidth
    }
}

extension CGFloat {
    func calculateHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let divisor: CGFloat = 667 / self
        let calculatedHeight = screenHeight / divisor
        return calculatedHeight
    }
    
    func calculateWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let divisor: CGFloat = 375.0 / self
        let calculatedWidth = screenWidth / divisor
        return calculatedWidth
    }
}
