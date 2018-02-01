//
//  Comment.swift
//  SEDaily-IOS
//
//  Created by jason on 2/1/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation

public struct Comment: Codable {
    //    let author : User
    let content: String
    //   lete dateCreated : String  ---> use init() to initalize into date
    let deleted: Bool
    let post: String
    let replies: [Comment]
    let score: Int
    let upvoted: Bool?
    let downvoted: Bool?
}
