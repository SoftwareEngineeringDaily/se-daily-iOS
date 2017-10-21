//
//  Podcast.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/12/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

enum PodcastTypes: String {
    case new = "new"
    case top = "top"
    case recommended = "recommended"
}

enum PodcastCategoryIds: Int {
    case All = -1
    case Business_and_Philosophy = 1068
    case Blockchain = 1082
    case Cloud_Engineering = 1079
    case Data = 1081
    case JavaScript = 1084
    case Machine_Learning = 1080
    case Open_Source = 1078
    case Security = 1083
    case Hackers = 1085
    case Greatest_Hits = 1069
    
    //@TODO: Add l10n here
    var description: String {
        switch self {
        case .All:
            return "All"
        case .Business_and_Philosophy:
            return "Business and Philosophy"
        case .Blockchain:
            return "Blockchain"
        case .Cloud_Engineering:
            return "Cloud Engineering"
        case .Data:
            return "Data"
        case .JavaScript:
            return "JavaScript"
        case .Machine_Learning:
            return "Machine Learning"
        case .Open_Source:
            return "Open Source"
        case .Security:
            return "Security"
        case .Hackers:
            return "Hackers"
        case .Greatest_Hits:
            return "Greatest Hits"
        }
    }
}

public struct Podcast: Codable {
    let _id: String
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
    let score: Int
    var type: String? = "new"
}

extension Podcast: Equatable {
    public static func ==(lhs: Podcast, rhs: Podcast) -> Bool {
        return lhs._id == rhs._id &&
            lhs.date == rhs.date &&
            lhs.link == rhs.link &&
            lhs.categories ?? [] == rhs.categories ?? [] &&
            lhs.tags ?? [] == rhs.tags ?? [] &&
            lhs.mp3 == rhs.mp3 &&
            lhs.featuredImage == rhs.featuredImage &&
            lhs.content.rendered == rhs.content.rendered &&
            lhs.title.rendered == rhs.title.rendered &&
            lhs.score == rhs.score &&
            lhs.type == rhs.type
    }
}

extension Podcast {
    func getLastUpdatedAsDateWith(completion: @escaping (Date?) -> Void) {
        DispatchQueue.global().async {
            // slow calculations performed here
            let date = Date(iso8601String: self.date)
            DispatchQueue.main.async {
                completion(date)
            }
        }
    }
    
    func getLastUpdatedAsDate() -> Date? {
        return Date(iso8601String: self.date)
    }
}

// Extension to go Encodable -> Dictionary
extension Encodable {
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
}

