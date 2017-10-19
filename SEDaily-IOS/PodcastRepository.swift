//
//  PodcastRepository.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/13/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

enum APICheckDates {
    static let newFeedLastCheck = "newFeed"
}

enum DiskKeys: String {
    case PodcastFolder = "Podcasts"
    
    var folderPath: String {
        return self.rawValue + "/" + self.rawValue + ".json"
    }
}

protocol DataSource {
    associatedtype T
    
    func getAll(completion: @escaping ([T]?) -> Void)
    func getById(id: String, completion: @escaping (T?) -> Void)
    func insert(item: T)
    func update(item: T)
    func clean()
    func deleteById(id: String)
}

protocol RepositoryProtocol {
    associatedtype DataModel
    var oldReturnedDataArray: [DataModel] { get set }
}

public class Repository<T>: NSObject, RepositoryProtocol {
    typealias DataModel = T
    
    internal var oldReturnedDataArray: [DataModel] = []
}

enum RepositoryError: Error {
    case ErrorGettingFromAPI
    case ErrorGettingFromRealm
    case ReturnedDataEqualsLastData
}
    
class PodcastRepository: Repository<Podcast> {
    typealias RepositorySuccessCallback = ([DataModel]) -> Void
    typealias RepositoryErrorCallback = (RepositoryError) -> Void
    
    private let dataSource = PodcastDataSource()
    
    // MARK: Getters With Paging
    let tag = "podcasts"

    var lastReturnedDataArray = [DataModel]()
    
    var loading = false
    
    func getData(page: Int = 0,
                 filterObject: FilterObject,
                 onSucces: @escaping RepositorySuccessCallback,
                 onFailure: @escaping RepositoryErrorCallback) {
        self.retrieveDataFromRealmOrAPI(filterObject: filterObject, onSucces: { (returnedData) in
            onSucces(returnedData)
        }) { (error) in
            onFailure(error)
        }
    }
    
    // MARK: Realm and API data getter
    private func retrieveDataFromRealmOrAPI(filterObject: FilterObject,
                                            onSucces: @escaping RepositorySuccessCallback,
                                            onFailure: @escaping RepositoryErrorCallback) {
        // Check if we made requests today
        let alreadLoadedStartToday = self.checkAlreadyLoadedNewToday(filterObject: filterObject)
        if alreadLoadedStartToday {
            self.loading = true
            log.warning("from disk")
            // Check if we have realm data saved
            self.dataSource.getAllWith(filterObject: filterObject, completion: { (returnedData) in
                guard let data = returnedData, !data.isEmpty else {
                    self.loading = false
                    onFailure(.ErrorGettingFromRealm)
                    return
                }
                guard data != self.lastReturnedDataArray else {
                    self.loading = false
                    onFailure(.ReturnedDataEqualsLastData)
                    return
                }
                
                self.setLoadedNewToday(filterObject: filterObject)
                self.lastReturnedDataArray = data
                self.loading = false
                onSucces(data)
            })
            return
        }
        log.warning("from api")
        guard self.loading == false else { return }
        self.loading = true

        // API Call and return
        API.sharedInstance.getPosts(type: filterObject.type, createdAtBefore: filterObject.lastDate, tags: filterObject.tagsAsString, categories: filterObject.categoriesAsString, onSucces: { (podcasts) in
            self.loading = false
            guard podcasts != self.lastReturnedDataArray else {
                onFailure(.ReturnedDataEqualsLastData)
                return
            }
            self.dataSource.insert(items: podcasts)
            self.setLoadedNewToday(filterObject: filterObject)
            self.lastReturnedDataArray = podcasts
            onSucces(podcasts)
        }) { (apiError) in
            self.loading = false
            onFailure(.ErrorGettingFromAPI)
        }
    }
    
    // MARK: Already loaded today checks
    func checkAlreadyLoadedNewToday(filterObject: FilterObject) -> Bool {
        let key = "\(APICheckDates.newFeedLastCheck)-\(filterObject.dictionary)"

        let defaults = UserDefaults.standard
        if let newFeedLastCheck = defaults.string(forKey: key) {
            let todayDate = Date().dateString()
            let newFeedDate = Date(iso8601String: newFeedLastCheck)!.dateString()
            if (newFeedDate == todayDate) {
                return true
            }
            
            return false
        }
        return false
    }
    
    func setLoadedNewToday (filterObject: FilterObject) {
        let todayString = Date().iso8601String
        let key = "\(APICheckDates.newFeedLastCheck)-\(filterObject.dictionary)"
        let defaults = UserDefaults.standard
        defaults.set(todayString, forKey: key)
    }
}

import RealmSwift
import Disk

class PodcastDataSource: DataSource {
    typealias T = Podcast
    let realm = try! Realm()
    
    func getAll(completion: @escaping ([T]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let retrievedObjects = try? Disk.retrieve(DiskKeys.PodcastFolder.folderPath, from: .caches, as: [T].self)
            DispatchQueue.main.async {
                completion(retrievedObjects)
            }
        }
    }
    
    func getAllWith(filterObject: FilterObject, completion: @escaping ([T]?) -> Void) {
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
    
    func getById(id: String, completion: @escaping (T?) -> Void) {
        self.getAll { (returnedData) in
            let foundObject = returnedData?.filter({ (item) -> Bool in
                return item._id == id
            }).first
            completion(foundObject)
        }
        
    }
    
    func insert(item: T) {
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
    
    func insert(items: [T]) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Disk.append(items, to: DiskKeys.PodcastFolder.folderPath, in: .caches)
            } catch {
                //@TODO: Handle errors?
                // ...
            }
        }
    }
    
    func update(item: T) {
        
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

struct FilterObject: Codable {
    let type: String
    let tags: [Int]
    var tagsAsString: String {
        get {
            let stringArray = tags.map { String($0) }
            return stringArray.joined(separator: " ")
        }
    }
    let lastDate: String
    let categories: [Int]
    var categoriesAsString: String {
        get {
            let stringArray = categories.map { String($0) }
            return stringArray.joined(separator: " ")
        }
    }
    
    init(type: String = "",
         tags: [Int] = [],
         lastDate: String = "",
         categories: [Int] = []) {
        self.type = type
        self.tags = tags
        self.lastDate = lastDate
        self.categories = categories
    }
}
