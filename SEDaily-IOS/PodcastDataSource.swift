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

    func getAll(completion: @escaping ([GenericType]?) -> Void)
    func getById(id: String, completion: @escaping (GenericType?) -> Void)
    func insert(item: GenericType)
    func update(item: GenericType)
    func clean()
    func deleteById(id: String)
}

enum DiskKeys: String {
    case PodcastFolder = "Podcasts"

    var folderPath: String {
        return self.rawValue + "/" + self.rawValue + ".json"
    }
}

class PodcastDataSource: DataSource {
    typealias GenericType = Podcast

    func getAll(completion: @escaping ([GenericType]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let retrievedObjects = try? Disk.retrieve(DiskKeys.PodcastFolder.folderPath, from: .caches, as: [GenericType].self)
            DispatchQueue.main.async {
                completion(retrievedObjects)
            }
        }
    }

    func getAllWith(filterObject: FilterObject, completion: @escaping ([GenericType]?) -> Void) {
        self.getAll { (returnedData) in
            DispatchQueue.global(qos: .userInitiated).async {
                //@TODO: Guard
                let filteredObjects = returnedData?.filter({ (podcast) -> Bool in
                    return podcast.tags!.contains(filterObject.tags) &&
                        podcast.categories!.contains(filterObject.categories) &&
                        podcast.type == filterObject.type
                })

                let dateString = filterObject.lastDate
                if let passedDate = Date(iso8601String: dateString) {
                    //@TODO: Gaurd
                    let dateFilteredObjects = filteredObjects?.filter({ (podcast) -> Bool in
                        return podcast.getLastUpdatedAsDate()! < passedDate
                    })
                    //@TODO: Gaurd
                    DispatchQueue.main.async {
                        completion(Array(dateFilteredObjects!.prefix(10)))

                    }
                    return
                }
                DispatchQueue.main.async {
                    // Prefix = to max paging
                    completion(Array(filteredObjects!.prefix(10)))

                }
                return
            }
        }
    }

    func getById(id: String, completion: @escaping (GenericType?) -> Void) {
        self.getAll { (returnedData) in
            let foundObject = returnedData?.filter({ (item) -> Bool in
                return item._id == id
            }).first
            completion(foundObject)
        }

    }

    func insert(item: GenericType) {
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

    func insert(items: [GenericType]) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.append(items, to: DiskKeys.PodcastFolder.folderPath, in: .caches)
            } catch {
                //@TODO: Handle errors?
                // ...
            }
        }
    }

    func update(item: GenericType) {

    }

    func clean() {
        try? Disk.remove(DiskKeys.PodcastFolder.rawValue, from: .caches)
    }

    func deleteById(id: String) {

    }

    //@TODO: We may need to check if items exist?
    //    func checkIfExists(item: Podcast) {
    //        self.getById(id: item._id) { (returnedItem) in
    //            if returnedItem != nil {
    //                log.info("not nil")
    //            }
    //            log.info("nil?")
    //        }
    //    }
}
