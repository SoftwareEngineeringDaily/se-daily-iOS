//
//  Stylesheet.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwifterSwift
import UIFontComplete

// MARK: - Stylesheet
enum Stylesheet {
    
    enum Colors {
        static let white = UIColor(hex: 0xFFFFFF)
        static let gray = UIColor(hex: 0xD6D4D2)
        static let offBlack = UIColor(hex: 0x262626)
        static let offWhite = UIColor(hex: 0xF9F9F9)
        static let clear = UIColor.clear
        
        static let blackText = UIColor(hex: 0x36322E)
        static let grayText = UIColor(hex: 0x979390)
        
        static let base = UIColor(hex: 0x4054b2)
        static let light1 = UIColor(hex: 0xFFC082)
        static let light2 = UIColor(hex: 0xFFAB58)
        static let dark1 = UIColor(hex: 0xE77607)
        static let dark2 = UIColor(hex: 0xB25800)
        
        static let secondaryColor = UIColor(hex: 0xfc4482)
        static let bufferColor = UIColor(hex: 0xb6b8b9)
    }
    
    enum Fonts {
        static let Regular = Font.helveticaNeue
        static let Bold = Font.helveticaNeueBold
    }
    
    enum Contexts {
        enum Global {
            static let StatusBarStyle = UIStatusBarStyle.lightContent
            static let StatusBarBackgroundColor = Colors.base
        }
        
        enum NavigationController {
            static let BarTintColor = Colors.white
            static let BarColor = Colors.base
        }
        
        enum EventHeader {
            static let BackgroundColor = Colors.light2
            static let TextColor = Colors.white
        }
    }
    
    enum CellContexts {
        enum EventsCell {
            static let titleTextColor = Colors.blackText
            static let detailTextColor = Colors.grayText
            static let heartTintColor = Colors.gray
            static let followTintColor = Colors.base
            static let unfollowTintColor = Colors.gray
        }
    }
    
}

// MARK: - Apply Stylesheet
extension Stylesheet {
    static func applyOn(_ navVC: UINavigationController) {
        typealias context = Contexts.NavigationController
        
        let navBar = navVC.navigationBar
        
        navBar.isTranslucent = false
        navBar.setColors(background: context.BarColor, text: context.BarTintColor)
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        UIApplication.shared.statusBarView?.backgroundColor = Contexts.Global.StatusBarBackgroundColor
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
