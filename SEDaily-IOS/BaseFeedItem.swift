//
//  BaseFeedItem.swift
//  SEDaily-IOS
//
//  Created by jason on 5/18/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation

protocol BaseFeedItem: Codable {
    var _id: String {get set}
    var score: Int {get set}
    var downvoted: Bool? {get set}
    var upvoted: Bool? {get set}    
}
