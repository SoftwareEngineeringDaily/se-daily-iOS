//
//  ForumThread.swift
//  SEDaily-IOS
//
//  Created by jason on 4/24/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation

public struct ForumThread: Codable {
    let _id: String
    let title: String
    let content: String
    let commentsCount: Int
    let dateCreated: String
    let dateLastActivity: String
    let score: Int
    let deleted: Bool
    
    let downvoted: Bool?
    let upvoted: Bool?
}
