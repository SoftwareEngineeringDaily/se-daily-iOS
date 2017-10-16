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
    static func config() {
        /*
            I believe this means that we need to trigger an even three times minimum
            There has to be a day between events being triggered
            We will only show the review 3 times (There needs to be some check if the user has already reviewed)
         
            So the popup will only be showed every three days and only 3 times
        */
        minEventsRequired = 3
        minSecondsSinceFirstEvent = 86400 // seconds in one day
        maxExecutionsPermitted = 3
    }
}
