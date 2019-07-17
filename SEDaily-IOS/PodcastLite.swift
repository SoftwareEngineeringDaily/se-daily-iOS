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
    let title: String
    let rendered:String
    let featuredImage: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let titleHolder = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .title)
        rendered = try titleHolder.decode(String.self, forKey: .rendered)
      
        featuredImage = try container.decode(String.self, forKey: .featuredImage)
        _id = try container.decode(String.self, forKey: ._id)
        thread = try container.decode(String.self, forKey: .thread)
        title = ""
    }
}
