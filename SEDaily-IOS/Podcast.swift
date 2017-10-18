//
//  Podcast.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/12/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

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
            lhs.score == rhs.score
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

public struct PodcastViewModel {
    let _id: String
    let uploadDateiso8601: String
    let postLinkURL: URL?
    let categories: [Int]?
    let tags: [Int]?
    let mp3URL: URL?
    let featuredImageURL: URL?
    private let encodedPodcastTitle: String
    private let encodedPodcastDescription: String
    let score: Int
    
    var podcastTitle: String {
        get {
            return encodedPodcastTitle.htmlDecoded
        }
    }
    var podcastDescription: String {
        get {
            return encodedPodcastDescription.htmlDecoded
        }
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
}

extension PodcastViewModel: Equatable {
    public static func ==(lhs: PodcastViewModel, rhs: PodcastViewModel) -> Bool {
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
