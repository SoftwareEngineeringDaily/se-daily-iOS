//
//  BookmarkViewModelController.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/4/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

public class BookmarkViewModelController {
    typealias Model = Podcast
    typealias ViewModel = PodcastViewModel
    typealias SuccessCallback = () -> Void
    typealias ErrorCallback = (RepositoryError?) -> Void

    private let repository = PodcastRepository()
    private var viewModels: [ViewModel?] = []

    var viewModelsCount: Int {
        return viewModels.count
    }

    func viewModel(at index: Int) -> ViewModel? {
        guard index >= 0 && index < viewModelsCount else { return nil }
        return viewModels[index]
    }

    func update(with podcast: PodcastViewModel) {
        let index = self.viewModels.index { (item) -> Bool in
            return item?._id == podcast._id
        }
        guard let modelsIndex = index else { return }
        self.viewModels.remove(at: modelsIndex)
        if podcast.isBookmarked {
            self.viewModels.insert(podcast, at: modelsIndex)
        }

        self.repository.updateDataSource(diskKey: .PodcastFolder, item: podcast.baseModelRepresentation)
    }

    func retrieveCachedBookmarkData(onSuccess: @escaping SuccessCallback) {
        self.repository.retrieveCachedBookmarkData(
            onSuccess: { (podcasts) in
                self.viewModels.removeAll()
                podcasts.forEach({ podcast in
                    self.viewModels.push(ViewModel(podcast: podcast))
                })
                onSuccess() },
            onFailure: { _ in })
    }

    func retrieveNetworkBookmarkData(onSuccess: @escaping SuccessCallback) {
        self.repository.retrieveNetworkBookmarkData(
            onSuccess: { (podcasts) in
                self.viewModels.removeAll()
                podcasts.forEach({ podcast in
                    self.viewModels.push(ViewModel(podcast: podcast))
                })
                onSuccess() },
            onFailure: { _ in })
    }
}
