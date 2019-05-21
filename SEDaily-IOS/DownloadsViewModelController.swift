//
//  DownloadsViewModelController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/21/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//


import Foundation

public class DownloadsViewModelController {
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
		self.viewModels.insert(podcast, at: modelsIndex)
		
		// Tell repository to update Datasource
		self.repository.updateDataSource(diskKey: .PodcastFolder, item: podcast.baseModelRepresentation)
	}
	
	func retrieveCachedDownloadsData(onSuccess: @escaping SuccessCallback) {
		self.repository.retrieveDownloadsData(
			onSuccess: { (podcasts) in
				self.viewModels.removeAll()
				podcasts.forEach({ podcast in
					self.viewModels.push(ViewModel(podcast: podcast))
				})
				onSuccess() },
			onFailure: { _ in })
	}
}
