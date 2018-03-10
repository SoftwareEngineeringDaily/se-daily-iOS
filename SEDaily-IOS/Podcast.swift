//
//  Podcast.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/12/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

enum PodcastTypes: String {
    case new
    case top
    case recommended
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

    var description: String {
        switch self {
        case .All:
            return L10n.tabTitleAll
        case .Business_and_Philosophy:
            return L10n.tabTitleBusinessAndPhilosophy
        case .Blockchain:
            return L10n.tabTitleBlockchain
        case .Cloud_Engineering:
            return L10n.tabTitleCloudEngineering
        case .Data:
            return L10n.tabTitleData
        case .JavaScript:
            return L10n.tabTitleJavaScript
        case .Machine_Learning:
            return L10n.tabTitleMachineLearning
        case .Open_Source:
            return L10n.tabTitleOpenSource
        case .Security:
            return L10n.tabTitleSecurity
        case .Hackers:
            return L10n.tabTitleHackers
        case .Greatest_Hits:
            return L10n.tabTitleGreatestHits
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
    var upvoted: Bool?
    var downvoted: Bool?
    var bookmarked: Bool?
    var downloaded: Bool?
}

extension Podcast {
    init(viewModel: PodcastViewModel) {
        self._id = viewModel._id
        self.date = viewModel.uploadDateiso8601
        var link = ""
        if let postLinkString = viewModel.postLinkURL?.absoluteString {
            link = postLinkString
        }
        self.link = link
        self.categories = viewModel.categories
        self.tags = viewModel.tags
        var mp3 = ""
        if let mp3UrlString = viewModel.mp3URL?.absoluteString {
            mp3 = mp3UrlString
        }
        self.mp3 = mp3
        var featuredImage = ""
        if let featuredImageUrlString = viewModel.featuredImageURL?.absoluteString {
            featuredImage = featuredImageUrlString
        }
        self.featuredImage = featuredImage
        self.content = Content(rendered: viewModel.encodedPodcastDescription)
        self.title = Title(rendered: viewModel.encodedPodcastTitle)
        self.score = viewModel.score
        self.upvoted = viewModel.isUpvoted
        self.downvoted = viewModel.isDownvoted
        self.bookmarked = viewModel.isBookmarked
    }
}

extension Podcast: Equatable {
    public static func == (lhs: Podcast, rhs: Podcast) -> Bool {
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
