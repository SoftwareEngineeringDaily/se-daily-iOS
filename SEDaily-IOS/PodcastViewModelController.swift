//
//  PodcastViewModelController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/12/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

enum APIError: Error {
    case NoResponseDataError
    case JSONParseError
    case GeneralFailure
}

public class PodcastViewModelController {
    typealias Model = Podcast
    typealias ViewModel = PodcastViewModel
    typealias SuccessCallback = () -> Void
    typealias ErrorCallback = (RepositoryError?) -> Void

    fileprivate let repository = PodcastRepository()
    fileprivate var viewModels: [ViewModel?] = []
    
    let networkService = API()

    var viewModelsCount: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> ViewModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }

    func clearViewModels() {
        self.viewModels.removeAll()
    }

    func update(with podcast: PodcastViewModel) {
        let index = self.viewModels.index { (item) -> Bool in
            return item?._id == podcast._id
        }
        guard let modelsIndex = index else { return }
        self.viewModels.remove(at: modelsIndex)
        self.viewModels.insert(podcast, at: modelsIndex)

        // Tell repository to update Datasource
        self.repository.updateDataSource(diskKey: .PodcastFolder, item: podcast.baseModelRepresentation)
    }

    func fetchData(type: String = "",
                   createdAtBefore beforeDate: String = "",
                   tags: [Int] = [],
                   categories: [Int] = [],
                   clearData: Bool = false,
                   onSuccess: @escaping SuccessCallback,
                   onFailure: @escaping ErrorCallback) {
        if clearData {
            self.clearViewModels()
        }
        let filterObject = FilterObject(type: type, tags: tags, lastDate: beforeDate, categories: categories)
        repository.getData(
            diskKey: .PodcastFolder,
            filterObject: filterObject,
            onSuccess: { (podcasts) in
                let newViewModels: [ViewModel?] = podcasts.map { model in
                    return ViewModel(podcast: model)
                }
                guard !self.viewModels.isEmpty else {
                    self.viewModels.append(contentsOf: newViewModels)
                    onSuccess()
                    return
                }

                //@TODO: Do this in the background?
                let filteredArray = newViewModels.filter { newPodcast in
                    let contains = self.viewModels.contains { currentPodcast in
                        return newPodcast == currentPodcast
                    }
                    return !contains
                }

                guard filteredArray.count != 0 else {
                    // OnFailure Nothing to append
                    //@TODO: Change handle error
                    onFailure(.ReturnedDataIsZero)
                    return
                }

                self.viewModels.append(contentsOf: filteredArray)
                onSuccess() },
            onFailure: { (error) in
                // If there is no data, clear loaded today and clear last returned data
                if self.viewModelsCount == 0 {
                    self.repository.lastReturnedDataArray.removeAll()
                    PodcastRepository.clearLoadedToday()
                }
                onFailure(error) })
    }

    func fetchSearchData(searchTerm: String,
                         createdAtBefore beforeDate: String = "",
                         firstSearch: Bool,
                         onSuccess: @escaping SuccessCallback,
                         onFailure: @escaping (APIError?) -> Void) {
        if firstSearch {
            self.clearViewModels()
        }
        networkService.getPostsWith(
            searchTerm: searchTerm,
            createdAtBefore: beforeDate,
            onSuccess: { (podcasts) in
                let newViewModels: [ViewModel?] = podcasts.map { model in
                    return ViewModel(podcast: model)
                }

                guard !self.viewModels.isEmpty else {
                    self.viewModels.append(contentsOf: newViewModels)
                    onSuccess()
                    return
                }

                //@TODO: Do this in the background?
                let filteredArray = newViewModels.filter { newPodcast in
                    let contains = self.viewModels.contains { currentPodcast in
                        return newPodcast == currentPodcast
                    }
                    return !contains
                }

                guard filteredArray.count != 0 else {
                    // OnFailure Nothing to append
                    //@TODO: Change handle error
                    onFailure(.GeneralFailure)
                    return
                }

                self.viewModels.append(contentsOf: filteredArray)
                onSuccess() },
            onFailure: { (apiError) in
                //@TODO: handle error
                log.error(apiError?.localizedDescription ?? "")
                onFailure(apiError) })
    }
}
