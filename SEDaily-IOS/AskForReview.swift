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
        minEventsRequired = 1 // hit play at least once
        maxExecutionsPermitted = 1 // show at most once
    }
}
