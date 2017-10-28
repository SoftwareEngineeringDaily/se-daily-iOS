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
    case ErrorGettingFromRealm
    case ReturnedDataEqualsLastData
    case ReturnedDataIsZero
}

class PodcastRepository: Repository<Podcast> {
    typealias RepositorySuccessCallback = ([DataModel]) -> Void
    typealias RepositoryErrorCallback = (RepositoryError) -> Void

    private let dataSource = PodcastDataSource()

    // MARK: Getters With Paging
    let tag = "podcasts"

    var loading = false

    func getData(page: Int = 0,
                 filterObject: FilterObject,
                 onSucces: @escaping RepositorySuccessCallback,
                 onFailure: @escaping RepositoryErrorCallback) {
        self.retrieveDataFromRealmOrAPI(
            filterObject: filterObject,
            onSucces: { (returnedData) in
                onSucces(returnedData) },
            onFailure: { (error) in
                onFailure(error) })
    }

    // MARK: Disk and API data getter
    private func retrieveDataFromRealmOrAPI(filterObject: FilterObject,
                                            onSucces: @escaping RepositorySuccessCallback,
                                            onFailure: @escaping RepositoryErrorCallback) {
        // Check if we made requests today
        let alreadLoadedStartToday = self.checkAlreadyLoadedNewToday(filterObject: filterObject)
        //@TODO: Fix this special case for recommneded. We can't load from disk here because we are display top podcasts when a user is not logged in
        if alreadLoadedStartToday && filterObject.type != PodcastTypes.recommended.rawValue {
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
        API.sharedInstance.getPosts(
            type: filterObject.type,
            createdAtBefore: filterObject.lastDate,
            tags: filterObject.tagsAsString,
            categories: filterObject.categoriesAsString,
            onSucces: { (podcasts) in
                self.loading = false
                guard podcasts != self.lastReturnedDataArray else {
                    onFailure(.ReturnedDataEqualsLastData)
                    return
                }
                self.dataSource.insert(items: podcasts)
                self.setLoadedNewToday(filterObject: filterObject)
                self.lastReturnedDataArray = podcasts
                onSucces(podcasts) },
            onFailure: { _ in
                self.loading = false
                onFailure(.ErrorGettingFromAPI)
        })
    }

    // MARK: Already loaded today checks
    func checkAlreadyLoadedNewToday(filterObject: FilterObject) -> Bool {
        let key = "\(APICheckDates.newFeedLastCheck)-\(filterObject.dictionary)"

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

    func setLoadedNewToday (filterObject: FilterObject) {
        let todayString = Date().iso8601String
        let key = "\(APICheckDates.newFeedLastCheck)-\(filterObject.dictionary)"
        let defaults = UserDefaults.standard
        defaults.set(todayString, forKey: key)
    }
}
