//
//  PodcastDataSource.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/21/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import Disk

protocol DataSource {
    associatedtype GenericType

    static func getAll(completion: @escaping ([GenericType]?) -> Void)
    static func getById(id: String, completion: @escaping (GenericType?) -> Void)
    static func insert(item: GenericType)
    static func update(item: GenericType)
    static func clean()
    static func deleteById(id: String)
}

class PodcastDataSource: DataSource {
    typealias GenericType = Podcast

    static func getAll(completion: @escaping ([GenericType]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let retrievedObjects = try? Disk.retrieve(DiskKeys.PodcastFolder.folderPath, from: .caches, as: [GenericType].self)
            DispatchQueue.main.async {
                completion(retrievedObjects)
            }
        }
    }

    static func getAllWith(filterObject: FilterObject, completion: @escaping ([GenericType]?) -> Void) {
        self.getAll { (returnedData) in
            DispatchQueue.global(qos: .userInitiated).async {
                //@TODO: Guard
                guard let filteredObjects = returnedData?.filter({ (podcast) -> Bool in
                    return podcast.tags!.contains(filterObject.tags) &&
                        podcast.categories!.contains(filterObject.categories) &&
                        podcast.type == filterObject.type
                })
                else {
                    completion(nil)
                    return
                }

                let dateString = filterObject.lastDate
                if let passedDate = Date(iso8601String: dateString) {
                    let dateFilteredObjects = filteredObjects.filter({ (podcast) -> Bool in
                        return podcast.getLastUpdatedAsDate()! < passedDate
                    })
                    DispatchQueue.main.async {
                        completion(Array(dateFilteredObjects.prefix(10)))
                    }
                    return
                }
                DispatchQueue.main.async {
                    // Prefix = max paging
                    completion(Array(filteredObjects.prefix(10)))
                }
                return
            }
        }
    }

    static func getById(id: String, completion: @escaping (GenericType?) -> Void) {
        self.getAll { (returnedData) in
            let foundObject = returnedData?.filter({ (item) -> Bool in
                return item._id == id
            }).first
            completion(foundObject)
        }
    }

    static func getIndexById(id: String, completion: @escaping (Int?) -> Void) {
        self.getAll { (returnedData) in
            let index = returnedData?.index { (item) -> Bool in
                return item._id == id
            }
            completion(index)
        }
    }

    static func insert(item: GenericType) {
        //@TODO: When would this fail
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.append(item, to: DiskKeys.PodcastFolder.folderPath, in: .caches)
            } catch {
                //@TODO: Handle errors?
                // ...
            }
        }
    }

    static func insert(items: [GenericType]) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.append(items, to: DiskKeys.PodcastFolder.folderPath, in: .caches)
            } catch {
                //@TODO: Handle errors?
                // ...
            }
        }
    }

    static func update(item: GenericType) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.getIndexById(id: item._id, completion: { (index) in
                guard let index = index else { return }
                self.getAll(completion: { (podcasts) in
                    guard var allPodcasts = podcasts else { return }
                    allPodcasts.remove(at: index)
                    allPodcasts.insert(item, at: index)
                    self.override(with: allPodcasts)
                })
            })
        }
    }

    static func override(with items: [GenericType]) {
        do {
            try Disk.save(items, to: .caches, as: DiskKeys.PodcastFolder.folderPath)
        } catch let error {
            log.error(error.localizedDescription)
        }
    }

    static func clean() {
        do {
            try Disk.remove(DiskKeys.PodcastFolder.folderPath, from: .caches)
        } catch let error {
            log.error(error.localizedDescription)
        }
    }

    static func deleteById(id: String) {

    }
}
