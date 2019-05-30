//
//  UIColor+Extensions.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/30/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	func brightened(by factor: CGFloat) -> UIColor {
		var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		return UIColor(hue: h, saturation: s, brightness: b * factor, alpha: a)
	}
	
	func getGradientColors(brightenedBy: CGFloat) -> [Any] {
		return [self.cgColor,
						self.brightened(by: brightenedBy).cgColor,
						self.cgColor]
	}
}
