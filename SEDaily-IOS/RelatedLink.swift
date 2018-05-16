//
//  RelatedLink.swift
//  SEDaily-IOS
//
//  Created by jason on 1/26/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation

public struct RelatedLink: Codable {
    let score: Int?
    let title: String
    let url: String

    /*
    let postId: String?
    let post: PodcastLite?
    */
    /*
    init(image: String? = nil, score: Int? = nil, title: String, url: String) {
        self.image = image
        self.score = score
        self.title = title
        self.url = url
    }*/
    
    public init(from decoder: Decoder) throws {
        print("Throws------------------------------")
        let container = try decoder.container(keyedBy: CodingKeys.self)
  
        score = try container.decode(Int.self, forKey: .score)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
        
      /*  if let value = try? container.decode(PodcastLite.self, forKey: .post) {
            post = try PodcastLite(from: (value as? Decoder)!)
            postId = post?._id
        } else {
            postId = try container.decode(String.self, forKey: .post)
            post = nil
        }
 */
    }
    
    
}
