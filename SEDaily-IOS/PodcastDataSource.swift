//
//  PodcastDataSource.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/21/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import Disk

class PodcastDataSource {
    typealias GenericType = Podcast

    static func getAllBookmarks(diskKey: DiskKeys, completion: @escaping ([GenericType]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let retrievedObjects = try? Disk.retrieve(diskKey.folderPath, from: .caches, as: [GenericType].self)
            let bookmarks = retrievedObjects?.filter({ podcast -> Bool in
                return podcast.bookmarked == true
            })
            DispatchQueue.main.async {
                completion(bookmarks)
            }
        }
    }

    static func getAll(diskKey: DiskKeys, completion: @escaping ([GenericType]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let retrievedObjects = try? Disk.retrieve(diskKey.folderPath, from: .caches, as: [GenericType].self)
            DispatchQueue.main.async {
                completion(retrievedObjects)
            }
        }
    }

    static func getAllWith(diskKey: DiskKeys, filterObject: FilterObject, completion: @escaping ([GenericType]?) -> Void) {
        self.getAll(diskKey: diskKey) { (returnedData) in
            DispatchQueue.global(qos: .userInitiated).async {
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

    static func insert(diskKey: DiskKeys, items: [GenericType]) {
        self.getAll(diskKey: .PodcastFolder) { (results) in
            var newResults = results ?? [GenericType]()
            items.forEach({ newPodcast in
                if let index = results?.index(where: { oldPodcast -> Bool in
                    return newPodcast._id == oldPodcast._id
                }) {
                    newResults[index] = newPodcast
                } else {
                    newResults.append(newPodcast)
                }
            })

            self.override(diskKey: diskKey, items: newResults)
        }
    }

    static func update(diskKey: DiskKeys, item: GenericType) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.getAll(diskKey: .PodcastFolder) { (results) in
                var newResults = results ?? [GenericType]()
                if let index = results?.index(where: { oldPodcast -> Bool in
                    return item._id == oldPodcast._id
                }) {
                    newResults[index] = item
                } else {
                    newResults.append(item)
                }

                self.override(diskKey: diskKey, items: newResults)
            }
        }
    }

    static func override(diskKey: DiskKeys, items: [GenericType]) {
        do {
            try Disk.save(items, to: .caches, as: diskKey.folderPath)
        } catch let error {
            log.error(error.localizedDescription)
        }
    }

    static func clean(diskKey: DiskKeys) {
        do {
            try Disk.remove(diskKey.folderPath, from: .caches)
        } catch let error {
            log.error(error.localizedDescription)
        }
    }
}
