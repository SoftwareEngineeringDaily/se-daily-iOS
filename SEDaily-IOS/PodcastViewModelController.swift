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
    
    var viewModelsCount: Int {
        return viewModels.count
    }
    
    func viewModel(at index: Int) -> ViewModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }
    
    func fetchData(type: String = "",
                   createdAtBefore beforeDate: String = "",
                   tags: String = "-1",
                   categories: String = "",
                   page: Int = 0,
                   onSucces: @escaping SuccessCallback,
                   onFailure: @escaping ErrorCallback) {
        repository.getData(lastItemDate: beforeDate, type: type, tags: tags, categories: categories, onSucces: { (podcasts) in
            let newViewModels: [ViewModel?] = podcasts.map { model in
                return ViewModel(podcast: model)
            }
            let currentModelIDs = self.viewModels.map { $0?._id }
            guard !currentModelIDs.isEmpty else {
                self.viewModels.append(contentsOf: newViewModels)
                onSucces()
                return
            }
            let filteredArray = newViewModels.filter({ (podcast) -> Bool in
                return currentModelIDs.contains(where: { (element) -> Bool in
                    return podcast?._id != element
                })
            })
            self.viewModels.append(contentsOf: filteredArray)
            onSucces()
        }) { (error) in
            //@TODO: make this not api error
            onFailure(error)
        }
    }
}
