//
//  RelatedLink.swift
//  SEDaily-IOS
//
//  Created by jason on 1/26/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation

public struct RelatedLink: BaseFeedItem {
    var score: Int = 0
    
    var _id: String
    
    
    var downvoted: Bool?
    
    var upvoted: Bool?
    
    let title: String
    let url: String
    
    let postId: String?
    let post: PodcastLite?
    
 
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
  
        _id = try container.decode(String.self, forKey: ._id)
        
        if let upvotedResult = try? container.decode(Bool.self, forKey: .upvoted) {
            upvoted = upvotedResult
        } else {
            downvoted = false
        }
        if let downvotedResult = try? container.decode(Bool.self, forKey: .downvoted) {
            downvoted = downvotedResult
        } else {
            downvoted = false
        }
        
        score = try container.decode(Int.self, forKey: .score)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)

        if let value = try? container.decode(PodcastLite.self, forKey: .post) {
            post = value
            postId = post?._id
        } else {
            postId = try container.decode(String.self, forKey: .post)
            post = nil
            print("nil post \(postId)")
        }
    }
}
