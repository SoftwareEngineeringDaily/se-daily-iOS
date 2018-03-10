//
//  PodcastViewModel.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/21/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

public struct PodcastViewModel: Codable {
    let _id: String
    let uploadDateiso8601: String
    let postLinkURL: URL?
    let categories: [Int]?
    var categoriesAsString: String {
        guard let categories = self.categories else { return "" }
        let stringArray = categories.map { String(describing: $0) }
        return stringArray.joined(separator: " ")
    }
    let tags: [Int]?
    var tagsAsString: String {
        guard let tags = self.tags else { return "" }
        let stringArray = tags.map { String(describing: $0) }
        return stringArray.joined(separator: " ")
    }
    let mp3URL: URL?
    let featuredImageURL: URL?
    let encodedPodcastTitle: String
    let encodedPodcastDescription: String
    var score: Int
    var isUpvoted: Bool = false
    var isDownvoted: Bool = false
    var isBookmarked: Bool = false
    var isDownloaded: Bool {
        return downloadedFileURLString != "" && downloadedFileURLString != nil
    }
    var downloadedFileURLString: String? {
        guard let url = OfflineDownloadsManager.findURL(for: self) else {
            return nil
        }
        return url.path
    }

    var podcastTitle: String {
        return encodedPodcastTitle.htmlDecoded
    }

    init(podcast: Podcast) {
        self._id = podcast._id
        self.uploadDateiso8601 = podcast.date
        self.postLinkURL = URL(string: podcast.link)
        self.categories = podcast.categories
        self.tags = podcast.tags
        self.mp3URL = URL(string: podcast.mp3)
        self.featuredImageURL = URL(string: podcast.featuredImage ?? "")
        self.encodedPodcastTitle = podcast.title.rendered
        self.encodedPodcastDescription = podcast.content.rendered
        self.score = podcast.score

        if let upvoted = podcast.upvoted {
            self.isUpvoted = upvoted
        }
        if let downvoted = podcast.downvoted {
            self.isDownvoted = downvoted
        }

        if let bookmarked = podcast.bookmarked {
            self.isBookmarked = bookmarked
        }
    }

    init() {
        self._id = ""
        self.uploadDateiso8601 = ""
        self.postLinkURL = nil
        self.categories = []
        self.tags = []
        self.mp3URL = nil
        self.featuredImageURL = nil
        self.encodedPodcastTitle = ""
        self.encodedPodcastDescription = ""
        self.score = 0
    }

    var baseModelRepresentation: Podcast {
        return Podcast(viewModel: self)
    }
}

extension PodcastViewModel: Equatable {
    public static func == (lhs: PodcastViewModel, rhs: PodcastViewModel) -> Bool {
        return lhs._id == rhs._id &&
            lhs.uploadDateiso8601 == rhs.uploadDateiso8601 &&
            lhs.postLinkURL == rhs.postLinkURL &&
            lhs.categories ?? [] == rhs.categories ?? [] &&
            lhs.tags ?? [] == rhs.tags ?? [] &&
            lhs.mp3URL == rhs.mp3URL &&
            lhs.featuredImageURL == rhs.featuredImageURL &&
            lhs.encodedPodcastTitle == rhs.encodedPodcastTitle &&
            lhs.encodedPodcastDescription == rhs.encodedPodcastDescription &&
            lhs.score == rhs.score
    }
}

extension PodcastViewModel {
    func getLastUpdatedAsDateWith(completion: @escaping (Date?) -> Void) {
        DispatchQueue.global().async {
            // slow calculations performed here
            let date = Date(iso8601String: self.uploadDateiso8601)
            DispatchQueue.main.async {
                completion(date)
            }
        }
    }

    // This is too slow for a cell collection view call
    func getLastUpdatedAsDate() -> Date? {
        return Date(iso8601String: self.uploadDateiso8601)
    }
}

extension PodcastViewModel {
    func getFilename() -> String {
        return self.podcastTitle.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }
}

extension PodcastViewModel {
    func getHTMLDecodedDescription(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            // slow calculations performed here
            let decodedString = self.encodedPodcastDescription.htmlDecodedWithSomeEntities ?? ""
            DispatchQueue.main.async {
                completion(decodedString)
            }
        }
    }
}
