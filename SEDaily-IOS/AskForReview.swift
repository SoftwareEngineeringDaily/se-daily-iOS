//
//  AskForReview.swift
//  SEDaily-IOS
//
//  Created by Eduardo Saenz on 10/15/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import WaitForIt

struct AskForReview: ScenarioProtocol {
    static let completedReviewKey = "completedReview"

    static func config() {
        /*
            Trigger an event three times minimum before executing
            Wait at least one day after the first event to execute
            Execute at most three times with a check if the review has been completed
        */
        minEventsRequired = 3
        minSecondsSinceFirstEvent = 86_400 // seconds in one day
        maxExecutionsPermitted = 3
        customConditions = {
            let defaults = UserDefaults.standard
            return !(defaults.object(forKey: completedReviewKey) != nil &&
                defaults.bool(forKey: completedReviewKey))
        }
    }

    static func setReviewed() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: AskForReview.completedReviewKey)
        defaults.synchronize()
    }
}
