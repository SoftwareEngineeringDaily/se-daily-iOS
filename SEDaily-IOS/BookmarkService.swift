//
//  BookmarkService.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/24/19.
//  Copyright © 2019 Altalogy All rights reserved.
//

protocol BookmarkServiceModelDelegate: class {
	func bookmarkModelDidChange(viewModel: PodcastViewModel)
}
protocol BookmarkServiceUIDelegate: class {
	func bookmarkUIDidChange(isBookmarked: Bool)
}

import Foundation

class BookmarkService {
	
	let networkService: API = API()
	
	var podcastViewModel: PodcastViewModel

	weak var modelDelegate: BookmarkServiceModelDelegate?
	weak var UIDelegate: BookmarkServiceUIDelegate?
	
	init(podcastViewModel: PodcastViewModel) {
		self.podcastViewModel = podcastViewModel
	}
	
	func setBookmark() {
		
		guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
		Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
		return
		}

		self.setBookmark(value: true)
	}
	
	private func setBookmark(value: Bool) {
		let podcastId = podcastViewModel._id
		networkService.setBookmarkPodcast(
			value: value,
			podcastId: podcastId,
			completion: { (success, active) in
				guard success != nil else { return }
				if success == true {
					guard let active = active else { return }
					self.updateBookmarked(active: active)
				}
		})
		Analytics2.bookmarkButtonPressed(podcastId: podcastViewModel._id)
	}
	
	private func updateBookmarked(active: Bool) {
		
		self.podcastViewModel.isBookmarked = active
		self.modelDelegate?.bookmarkModelDidChange(viewModel: self.podcastViewModel)
		self.UIDelegate?.bookmarkUIDidChange(isBookmarked: active)
	}
}
