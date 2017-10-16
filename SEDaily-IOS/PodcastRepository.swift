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
    
    func getAll() -> [T]?
    func getById(id: String) -> T?
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
    let filtersRepo = Filters.shared
    
    // MARK: Getters With Paging
    let tag = "podcasts"

    var lastReturnedDataArray = [DataModel]()
    
    var loading = false
    
    func getData(page: Int = 0,
                 lastItemDate: String,
                 type: String,
                 tags: String,
                 categories: String,
                 onSucces: @escaping RepositorySuccessCallback,
                 onFailure: @escaping RepositoryErrorCallback) {
        self.retrieveDataFromRealmOrAPI(type: type, lastItemDate: lastItemDate, tags: tags, categories: categories, onSucces: { (returnedData) in
            onSucces(returnedData)
        }) { (error) in
            onFailure(error)
        }
    }
    
    // MARK: Realm and API data getter
    private func retrieveDataFromRealmOrAPI(type: String,
                                            lastItemDate: String,
                                            tags: String,
                                            categories: String,
                                            onSucces: @escaping RepositorySuccessCallback,
                                            onFailure: @escaping RepositoryErrorCallback) {
        // Check if we made requests today
        let alreadLoadedStartToday = self.alreadyLoadedNewToday(tag: self.tag, lastItemDate: lastItemDate)
log.debug(lastItemDate)
//        if alreadLoadedStartToday {
//            self.loading = true
//            log.warning("from disk")
//            // Check if we have realm data saved
//            //@TODO: Replace get all
//            let persistantData = self.dataSource.getAllWith(filters: filtersRepo.getActiveFilters())
//            guard let data = persistantData, !data.isEmpty else {
//                self.loading = false
//                onFailure(.ErrorGettingFromRealm)
//                return
//            }
//            guard data != self.lastReturnedDataArray else {
//                self.loading = false
//                onFailure(.ReturnedDataEqualsLastData)
//                return
//            }
//
//            self.setLoadedNewToday(tagId: self.tag, lastItemDate: lastItemDate)
//            self.lastReturnedDataArray = data
//            self.loading = false
//            onSucces(data)
//            return
//        }
        log.warning("from api")
        guard self.loading == false else { return }
        self.loading = true

        // API Call and return
        API.sharedInstance.getPosts(type: type, createdAtBefore: lastItemDate, tags: tags, categories: categories, onSucces: { (podcasts) in
            self.loading = false
            guard podcasts != self.lastReturnedDataArray else {
                onFailure(.ReturnedDataEqualsLastData)
                return
            }
            self.dataSource.insert(items: podcasts)
            self.setLoadedNewToday(tagId: self.tag, lastItemDate: lastItemDate)
            self.lastReturnedDataArray = podcasts
            onSucces(podcasts)
        }) { (apiError) in
            self.loading = false
            onFailure(.ErrorGettingFromAPI)
        }
    }
    
    // MARK: Already loaded today checks
    func alreadyLoadedNewToday (tag: String, lastItemDate: String?) -> Bool {
        let defaults = UserDefaults.standard
        // @TODO: we may be able to add this to the filters dictionary
        var key = APICheckDates.newFeedLastCheck
        
        filtersRepo.add(filter: lastItemDate ?? "", for: .lastItemDate)
        filtersRepo.add(filter: String(tag), for: .tag)
        
        let filters = filtersRepo.getActiveFilters()
        
        key = "\(key)-\(filters.description)"
        
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
    
    func setLoadedNewToday (tagId: String, lastItemDate: String?) {
        let todayString = Date().iso8601String
        var key = APICheckDates.newFeedLastCheck
        
        filtersRepo.add(filter: lastItemDate ?? "", for: .lastItemDate)
        filtersRepo.add(filter: String(tag), for: .tag)
        let filters = filtersRepo.getActiveFilters()
        
        key = "\(key)-\(filters.description)"
        
        let defaults = UserDefaults.standard
        defaults.set(todayString, forKey: key)
    }
}

import RealmSwift
import Disk

class PodcastDataSource: DataSource {
    typealias T = Podcast
    
    func getAll() -> [T]? {
        let retrievedObjects = try? Disk.retrieve(DiskKeys.PodcastFolder.folderPath, from: .caches, as: [T].self)
        return retrievedObjects
    }
    
    func getAllWith(filters: FilterDictionary) -> [T]? {
        let all = self.getAll()
//        var predicates = [NSPredicate]()
//        for (key,value) in filters {
//            print(key)
//            print(value)
//            if value == "" { continue }
//            if let key = key.realmKey {
//                let predicate = NSPredicate(format: "%K = %@", key, value)
//                predicates.append(predicate)
//            }
//        }

//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        let filteredObjects = realmObjects.filter(compoundPredicate)
        let filteredObjects = all

        if let dateString = filters[.lastItemDate] {
            if let passedDate = Date(iso8601String: dateString) {
                //@TODO: Gaurd
                let dateFilteredObjects = filteredObjects?.filter { $0.getLastUpdatedAsDate()! >= passedDate }
                //@TODO: Gaurd
                return Array(dateFilteredObjects!.prefix(10))
            }
        }
        // Prefix = to max paging
        return Array(filteredObjects!.prefix(10))
    }
    
    func getById(id: String) -> T? {
        let retrievedObjects = try? Disk.retrieve(DiskKeys.PodcastFolder.folderPath, from: .caches, as: [T].self)
        return retrievedObjects?.filter({ (item) -> Bool in
            return item._id == id
        }).first
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
                try Disk.save(items, to: .caches, as: DiskKeys.PodcastFolder.folderPath)
//                try Disk.append(items, to: DiskKeys.PodcastFolder.folderPath, in: .caches)
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
}

import Foundation

typealias FilterDictionary = [FilterKeys: String]

enum FilterKeys: String, Hashable {
    case state = "state"
    case city = "city"
    case tag = "tag"
    case lastItemDate = "lastItemDate"
    case type = "type"
    
    var hashValue: Int {
        switch self {
        case .state:
            return 0
        case .city:
            return 1
        case .tag:
            return 2
        case .lastItemDate:
            return 3
        case .type:
            return 4
        }
    }
}

// Realm Keys
extension FilterKeys {
    var realmKey: String? {
        switch self {
        case .state:
            return "contact.state"
        case .city:
            return "contact.city"
        case .tag:
            return nil
        case .lastItemDate:
            return "lastUpdate"
        case .type:
            return "animal"
        }
    }
}

extension FilterKeys: Equatable {
    static func == (lhs: FilterKeys, rhs: FilterKeys) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

public class Filters: NSObject {
    static let shared: Filters = Filters()
    private override init() {}
    
    private var activeFilters = FilterDictionary()
    
    func getActiveFilters() -> FilterDictionary {
        return self.activeFilters
    }
    
    func add(filter: String, for key: FilterKeys) {
        activeFilters[key] = filter
    }
}
