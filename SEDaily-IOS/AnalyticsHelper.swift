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
        Analytics.logEvent("forum_list_viewed", parameters: nil)
    }
    
    class func forumThreadViewed(forumThread: ForumThread) {
        Analytics.logEvent("forum_thread_viewed", parameters: [
            AnalyticsParameterItemID: "id-\(forumThread.title)",
            AnalyticsParameterItemName: forumThread.title,
            AnalyticsParameterContentType: "view"
        ])
    }
    
    class func loginFormViewed() {
        
    }
    class func newPodcastsListViewed() {
        Analytics.logEvent("podcast_new_list_viewed", parameters: nil)
    }
    class func topPodcastsListViewed() {
        Analytics.logEvent("podcast_top_list_viewed", parameters: nil)
    }
    class func recommendedPodcastsListViewed() {
        Analytics.logEvent("podcast_recommended_list_viewed", parameters: nil)
    }
    
    class func loginNavButtonPressed() {
        Analytics.logEvent("login_button_nav_pressed", parameters: nil)
    }
    class func logoutNavButtonPressed() {
        Analytics.logEvent("logout_button_nav_pressed", parameters: nil)

    }
}
