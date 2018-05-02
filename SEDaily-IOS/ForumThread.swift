//
//  ForumThread.swift
//  SEDaily-IOS
//
//  Created by jason on 4/24/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation
import SwiftMoment

public struct ForumThread: Codable {
    let _id: String
    
    let title: String

    let content: String
    let author: Author
    
    let commentsCount: Int
    let dateCreated: String
    let dateLastAcitiy: String // An annoying bug that will require database migrations + miner update
    var score: Int = 0
    let deleted: Bool
    
    let downvoted: Bool?
    var upvoted: Bool?
    let podcastEpisode: PodcastLite?
}

extension ForumThread {
    func getCommentsSummary() -> String {
        if commentsCount != 1 {
            return  "\(commentsCount) comments"
        } else {
            return  "\(commentsCount) comment"
        }
    }
    
    func getDateLastActivityPretty() -> String {
        return moment(self.dateLastAcitiy)?.fromNow() ?? ""
    }
    
    func getDatedCreatedPretty() -> String {
        return moment(self.dateCreated)?.fromNow() ?? ""
    }
}
