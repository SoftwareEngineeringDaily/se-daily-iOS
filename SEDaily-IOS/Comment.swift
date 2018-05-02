//
//  Comment.swift
//  SEDaily-IOS
//
//  Created by jason on 2/1/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation
import Down
import SwiftMoment

public struct Comment: Codable {
    let author: Author
    let _id: String
    let content: String
    let dateCreated: String
    let deleted: Bool
    let rootEntity: String
    let replies: [Comment]?
    let score: Int
    let upvoted: Bool?
    let downvoted: Bool?
    let parentComment: String?
}

extension Comment {    
    
    func getDatedCreatedPretty() -> String {
        return moment(self.dateCreated)?.fromNow() ?? ""
    }
    
    func commentBody() -> NSAttributedString {
        // This should be done on the server   
        let down = Down(markdownString: self.content)
        if let content = try? down.toAttributedString() {
            return content
        } else {
            return NSAttributedString(string: self.content)
        }
    
    }
}
