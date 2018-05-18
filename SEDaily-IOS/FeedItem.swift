//
//  FeedItem.swift
//  SEDaily-IOS
//
//  Created by jason on 5/15/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation



import Foundation

public struct FeedItem: Codable {
    let _id: String
    let randomOrder: Double
    var relatedLink: RelatedLink
    //    let author: Author // Is a string at times..
}
