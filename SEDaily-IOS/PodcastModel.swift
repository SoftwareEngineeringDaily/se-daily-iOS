//
//  PodcastModel.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//


import UIKit
import RealmSwift
import ObjectMapper
import SwifterSwift

public class RealmString: Object {
    dynamic var stringValue = ""
}

public class PodcastModel: Object, Mappable {
    dynamic var key: String? = nil
    dynamic var podcastId: String? = nil
    dynamic var podcastName: String? = nil
    dynamic var podcastDesc: String? = nil
    dynamic var uploadDate: String? = nil
    dynamic var mp3URL: String? = nil
    dynamic var link: String? = nil
    dynamic var type: String? = nil
    dynamic var score: String? = nil
    dynamic var currentTime: String = "0"
    dynamic var imageURLString: String? = nil
    dynamic var tags: String = ""
    dynamic var categories: String = ""
    
    dynamic var mp3Saved: Bool = false
    
    dynamic var isNew: Bool = false
    dynamic var isTop: Bool = false
    dynamic var isRecommended: Bool = false
    
    dynamic var isUpvoted: Bool = false
    dynamic var isDownvoted: Bool = false
    
    override public static func primaryKey() -> String? {
        return "key"
    }
    
    //Impl. of Mappable protocol
    required convenience public init?(map: Map) {
        self.init()
    }
    
    // Mappable
    public func mapping(map: Map) {
        key <- map["_id"]
        podcastId <- map["_id"]
        podcastName <- map["title.rendered"]
        podcastDesc <- (map["content.rendered"], TransformOf<String, String>(fromJSON: { $0.map { String($0).htmlDecoded } }, toJSON: { $0!.htmlDecoded }))
        uploadDate <- map["date"]
        mp3URL <- map["mp3"]
        link <- map["link"]
        score <- (map["score"], TransformOf<String, Int>(fromJSON: { $0.map { String($0) } }, toJSON: { Int($0!) }))
        imageURLString <- map["featuredImage"]
        isUpvoted <- map["upvoted"]
        isDownvoted <- map["downvoted"]
        
        if let unwrappedTags = map.JSON["tags"] as? [Int] {
            for intTag in unwrappedTags {
                tags += "\(intTag),"
            }
        }
        
        if let unwrappedCategories = map.JSON["categories"] as? [Int] {
            for intTag in unwrappedCategories {
                categories += "\(intTag),"
            }
        }
    }
    
    func getDescription() -> String {
        guard let desc = podcastDesc else { return "" }
        return desc
    }
    
    func getMP3asURL() -> URL? {
        guard let urlString = self.mp3URL else {
            return nil
        }
        guard let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
    
    func getSavedMP3URL() -> URL {
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // the name of the file here I kept is yourFileName with appended extension
        documentsURL.appendPathComponent(self.podcastName! + "." + "mp3")
        return documentsURL
    }
    
    func getCurrentTime() -> Double? {
        return Double(self.currentTime)
    }
}

extension PodcastModel {
    func save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self, update: true)
        }
    }
    
    class func all() -> Results<PodcastModel> {
        let realm = try! Realm()
        return realm.objects(PodcastModel.self)
    }
    
    class func filterByTag(tag: String) -> Results<PodcastModel> {
        let realm = try! Realm()
        return realm.objects(PodcastModel.self).filter ("tags contains '\(tag)'")
    }
    
    class func getRecommended() -> Results<PodcastModel> {
        return self.all().filter("isRecommended == true").sorted(byKeyPath: "uploadDate", ascending: false)
    }
    
    class func getTop() -> Results<PodcastModel> {
        return self.all().filter("isTop == true").sorted(byKeyPath: "score", ascending: false)
    }
    
    func updateFrom(item: PodcastModel) {
        guard self.podcastName == item.podcastName else { return }
        let realm = try! Realm()
        try! realm.write {
            realm.add(item, update: true)
        }
    }
    
    func update(name: String) {
        let realm = try! Realm()
        try! realm.write {
            self.podcastName = podcastName
        }
    }
    
    func update(currentTime: Float) {
        log.info(currentTime)
        let realm = try! Realm()
        try! realm.write {
            self.currentTime = String(currentTime)
        }
    }
    
    func update(mp3Saved: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.mp3Saved = mp3Saved
        }
    }
    
    func update(isNew: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.isNew = isNew
        }
    }
    
    func update(isTop: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.isTop = isTop
        }
    }
    
    func update(isRecommended: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.isRecommended = isRecommended
        }
    }
    
    func update(isUpvoted: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.isUpvoted = isUpvoted
            self.isDownvoted = false
        }
    }
    
    func update(isDownvoted: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.isDownvoted = isDownvoted
            self.isUpvoted = false
        }
    }
    
    func delete() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
}
