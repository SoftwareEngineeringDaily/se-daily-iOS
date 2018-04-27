//
//  PodcastLite.swift
//  SEDaily-IOS
//
//  Created by jason on 4/27/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation


public struct PodcastLite: Codable {
    let _id: String
    let thread: String?
    let date: String
    let link: String
    let categories: [Int]?
    let tags: [Int]?
    let mp3: String
    let featuredImage: String?
    struct Content: Codable {
        let rendered: String
    }
    let content: Content
    struct Title: Codable {
        let rendered: String
    }
    let title: Title
    let score: Int?
    var type: String? = "new"
    var upvoted: Bool?
    var downvoted: Bool?
    var bookmarked: Bool?
    var downloaded: Bool?
}
