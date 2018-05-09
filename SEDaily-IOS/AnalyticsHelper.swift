//
//  AnalyticsHelper.swift
//  SEDaily-IOS
//
//  Created by jason on 5/9/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation
import Firebase

class Analytics2 {
    class func forumViewed() {
        Analytics.logEvent("forum_loaded", parameters: nil)
    }
    
    class func loginFormViewed() {
        
    }
    
    class func loginNavButtonPressed() {
        Analytics.logEvent("login_button_nav_pressed", parameters: nil)
    }
    class func logoutNavButtonPressed() {
        Analytics.logEvent("logout_button_nav_pressed", parameters: nil)

    }
}
