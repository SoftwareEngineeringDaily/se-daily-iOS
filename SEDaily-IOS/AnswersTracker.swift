//
//  AnswersTracker.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 8/3/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

//Web Views
//Registrants
//Installs
//Uninstalls
//Returning Users
//Follows
//Favorites

import Foundation
import Crashlytics

class Tracker {
    class func logMovedToWebView(url: String) {
        Answers.logCustomEvent(withName: "Moved_To_Webview",
                               customAttributes:
            [
                "website": url,
                "isLoggedIn": UserManager.sharedInstance.isCurrentUserLoggedIn()
            ]
        )
    }

    class func logPlayPodcast(podcast: PodcastViewModel) {
        Answers.logCustomEvent(withName: "Podcast_Play", customAttributes:
            [
                "podcastId": podcast._id,
                "podcastTitle": podcast.podcastTitle,
                "tags": podcast.tagsAsString,
                "categories": podcast.categoriesAsString,
                "isLoggedIn": UserManager.sharedInstance.isCurrentUserLoggedIn()
            ]
        )
    }
    
    class func logFeedViewed() {
        Answers.logCustomEvent(withName: "Feed_Viewed")
    }
    
    
    
    class func logRelatedLinkViewedFromFeed(url: URL) {
        Answers.logCustomEvent(withName: "RelatedLink_Viewed_From_Feed", customAttributes:
            [
                "website": url.absoluteString,
                "isLoggedIn": UserManager.sharedInstance.isCurrentUserLoggedIn()
            ]
        )
    }
  
    class func logLogin(user: User) {
        Answers.logLogin(withMethod: "SEDaily_API", success: 1, customAttributes:
            [
                "username": user.email            ]
        )
    }

    class func logRegister(user: User) {
        Answers.logSignUp(withMethod: "SEDaily_API", success: 1,
                               customAttributes:
            [
                "username": user.email            ]
        )
    }

    class func logFacebookLogin(user: User) {
        Answers.logLogin(withMethod: "Facebook", success: 1, customAttributes:
            [
                "username": user.email
            ]
        )
    }
}

extension Tracker {
    class func logLoginError(error: Error) {
        Answers.logLogin(withMethod: "SEDaily_API", success: 0, customAttributes:
            [
                "error": error.localizedDescription
            ]
        )
    }

    class func logLoginError(string: String) {
        Answers.logLogin(withMethod: "SEDaily_API", success: 0, customAttributes:
            [
                "error": string
            ]
        )
    }

    class func logRegisterError(error: Error) {
        Answers.logSignUp(withMethod: "SEDaily_API", success: 0, customAttributes:
            [
                "error": error.localizedDescription
            ]
        )
    }

    class func logRegisterError(string: String) {
        Answers.logSignUp(withMethod: "SEDaily_API", success: 0, customAttributes:
            [
                "error": string
            ]
        )
    }

    class func logFacebookLoginError(error: Error) {
        Answers.logLogin(withMethod: "Facebook_Login", success: 0, customAttributes:
            [
                "error": error.localizedDescription
            ]
        )
    }

    class func logGeneralError(error: Error) {
        Answers.logCustomEvent(withName: "Error_General",
                               customAttributes:
            [
                "error": error.localizedDescription
            ]
        )
    }

    class func logGeneralError(string: String) {
        Answers.logCustomEvent(withName: "Error_General",
                               customAttributes:
            [
                "error": string
            ]
        )
    }
}
