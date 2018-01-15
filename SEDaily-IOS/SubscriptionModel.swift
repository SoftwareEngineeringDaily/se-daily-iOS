//
//  SubscriptionModel.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 1/15/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation

public struct StripeModel: Codable {
    let _id: String
    let planFrequency: String
    let dateCreated: String
}

public struct SubscriptionModel: Codable {
    let _id: String
    let createdAt: String
    let username: String
    let subscription: StripeModel
}

extension SubscriptionModel {
    func getCreatedAtDate() -> Date? {
        let date = Date(iso8601String: self.createdAt)
        return date
    }

    func getPlanFrequency() -> String {
        return self.subscription.planFrequency.capitalized
    }
}
