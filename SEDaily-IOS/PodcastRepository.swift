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

protocol RepositoryProtocol {
    associatedtype DataModel
    var lastReturnedDataArray: [DataModel] { get set }
}

public class Repository<T>: NSObject, RepositoryProtocol {
    typealias DataModel = T

    internal var lastReturnedDataArray: [DataModel] = []
}

enum RepositoryError: Error {
    case ErrorGettingFromAPI
    case ErrorGettingFromDisk
    case ReturnedDataEqualsLastData
    case ReturnedDataIsZero
}

class PodcastRepository: Repository<Podcast> {
    typealias RepositorySuccessCallback = ([DataModel]) -> Void
    typealias RepositoryErrorCallback = (RepositoryError) -> Void
    typealias DataSource = PodcastDataSource

    let networkService = API()

    // MARK: Getters With Paging
    let tag = "podcasts"
    var loading = false

    /// Retrieves the cached bookmark data from disk
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    func retrieveCachedBookmarkData(
        onSuccess: @escaping RepositorySuccessCallback,
        onFailure: @escaping RepositoryErrorCallback) {
        DataSource.getAllBookmarks(diskKey: .PodcastFolder) { diskData in
            guard let data = diskData else {
                onFailure(.ErrorGettingFromDisk)
                return
            }
            onSuccess(data)
        }
    }

    /// Retrieves bookmark data by making a network call
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    func retrieveNetworkBookmarkData(
        onSuccess: @escaping RepositorySuccessCallback,
        onFailure: @escaping RepositoryErrorCallback) {
        networkService.podcastBookmarks { (success, results) in
            if success == true {
                guard let podcasts = results else {
                    onFailure(.ErrorGettingFromAPI)
                    return
                }
                DataSource.insert(diskKey: .PodcastFolder, items: podcasts)
                onSuccess(podcasts)
            } else {
                onFailure(.ErrorGettingFromAPI)
            }
        }
    }

    func getData(
        diskKey: DiskKeys,
        filterObject: FilterObject?,
        onSuccess: @escaping RepositorySuccessCallback,
        onFailure: @escaping RepositoryErrorCallback) {

        switch diskKey {
        case .PodcastFolder:
            self.retrievePodcastData(
                filterObject: filterObject,
                onSuccess: { (returnedData) in
                    onSuccess(returnedData) },
                onFailure: { (error) in
                    PodcastRepository.clearLoadedToday()
                    onFailure(error) })
        case .OfflineDownloads:
            break
        }
    }

    // MARK: Disk and API data getter
    private func retrievePodcastData(
        filterObject: FilterObject?,
        onSuccess: @escaping RepositorySuccessCallback,
        onFailure: @escaping RepositoryErrorCallback) {

        guard let filterObject = filterObject else {
            onFailure(.ErrorGettingFromDisk)
            return
        }

        // Check if we made requests today
//        let alreadLoadedStartToday = PodcastRepository.checkAlreadyLoadedNewToday(filterObject: filterObject)
        let alreadLoadedStartToday = false

        //@TODO: Fix this special case for recommneded. We can't load from disk here because we are display top podcasts when a user is not logged in
        if alreadLoadedStartToday && filterObject.type != PodcastTypes.recommended.rawValue {
            self.loading = true
            log.warning("from disk")
            // Check if we have realm data saved
            DataSource.getAllWith(diskKey: .PodcastFolder, filterObject: filterObject, completion: { (returnedData) in
                guard let data = returnedData, !data.isEmpty else {
                    self.loading = false
                    onFailure(.ErrorGettingFromDisk)
                    return
                }
                //@TODO: check how to clear this or remove completely
                if self.returnedDataEqualLastData(returnedData: data) {
                    self.loading = false
                    onFailure(.ReturnedDataEqualsLastData)
                    return
                }

                PodcastRepository.setLoadedNewToday(filterObject: filterObject)
                self.lastReturnedDataArray = data
                self.loading = false
                onSuccess(data)
            })
            return
        }
        log.warning("from api")
        guard self.loading == false else { return }
        self.loading = true

        // API Call and return
        networkService.getPosts(
            type: filterObject.type,
            createdAtBefore: filterObject.lastDate,
            tags: filterObject.tagsAsString,
            categories: filterObject.categoriesAsString,
            onSuccess: { (podcasts) in
                self.loading = false
                if self.returnedDataEqualLastData(returnedData: podcasts) {
                    onFailure(.ReturnedDataEqualsLastData)
                    return
                }
                DataSource.insert(diskKey: .PodcastFolder, items: podcasts)
                PodcastRepository.setLoadedNewToday(filterObject: filterObject)
                self.lastReturnedDataArray = podcasts
                onSuccess(podcasts) },
            onFailure: { _ in
                self.loading = false
                onFailure(.ErrorGettingFromAPI)
        })
    }

    // MARK: Already loaded today checks
    static func checkAlreadyLoadedNewToday(filterObject: FilterObject) -> Bool {
        let key = "\(APICheckDates.newFeedLastCheck)-\(filterObject.nsDictionary)"

        let defaults = UserDefaults.standard
        if let newFeedLastCheck = defaults.string(forKey: key) {
            let todayDate = Date().dateString()
            let newFeedDate = Date(iso8601String: newFeedLastCheck)!.dateString()
            if newFeedDate == todayDate {
                return true
            }

            return false
        }
        return false
    }

    static func setLoadedNewToday (filterObject: FilterObject) {
        let todayString = Date().iso8601String
        let key = "\(APICheckDates.newFeedLastCheck)-\(filterObject.nsDictionary)"
        let defaults = UserDefaults.standard
        defaults.set(todayString, forKey: key)
    }

    static func clearLoadedToday() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation()
        for key in keys {
            if key.key.contains(APICheckDates.newFeedLastCheck) {
                defaults.removeObject(forKey: key.key)
            }
        }
    }

    func returnedDataEqualLastData(returnedData: [DataModel]) -> Bool {
        guard returnedData != self.lastReturnedDataArray else {
            return true
        }
        return false
    }
}

extension PodcastRepository {
    func updateDataSource(diskKey: DiskKeys, item: DataModel) {
        DataSource.update(diskKey: diskKey, item: item)
    }
}
