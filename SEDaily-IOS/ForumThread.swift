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
    let author: Author
    
    let commentsCount: Int
    let dateCreated: String
    let dateLastAcitiy: String // An annoying bug that will require database migrations + miner update
    let score: Int
    let deleted: Bool
    
    let downvoted: Bool?
    let upvoted: Bool?
    let podcastEpisode: PodcastLite?
}

extension ForumThread {
    
    func getDatePosted() -> Date? {
        return Date(iso8601String: self.dateCreated)
    }
    
    func getDateLastActivity() -> Date? {
        return Date(iso8601String: self.dateLastAcitiy)
    }
    
    func getDateLastActivityPretty() -> String {
        return getDateLastActivity()?.dateString() ?? ""
    }
    
    func getDatedCreatedPretty() -> String {
        return getDatePosted()?.dateString() ?? ""
    }

}
