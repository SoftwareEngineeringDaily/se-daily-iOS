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
	func bookmarkUIImmediateUpdate()
}

import Foundation

class BookmarkService {
	
	let networkService: API = API()
	
	var podcastViewModel: PodcastViewModel

	
	weak var UIDelegate: BookmarkServiceUIDelegate?
	
	init(podcastViewModel: PodcastViewModel) {
		self.podcastViewModel = podcastViewModel
	}
	
	func setBookmark() {
		guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
		Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
		return
		}
		UIDelegate?.bookmarkUIImmediateUpdate()
		self.setBookmark(value: true)
	}
	
	private func setBookmark(value: Bool) {
		let podcastId = podcastViewModel._id
		networkService.setBookmarkPodcast(
			value: value,
			podcastId: podcastId,
			completion: { [weak self] (success, active) in
				guard success != nil else {
					self?.UIDelegate?.bookmarkUIImmediateUpdate()
					return }
				if success == true {
					guard let active = active else { return }
					self?.updateBookmarked(active: active)
				} else { self?.UIDelegate?.bookmarkUIImmediateUpdate() }
		})
		Analytics2.bookmarkButtonPressed(podcastId: podcastViewModel._id)
	}
	
	private func updateBookmarked(active: Bool) {
		
		self.podcastViewModel.isBookmarked = active
		
		let userInfo = ["viewModel": podcastViewModel]
		NotificationCenter.default.post(name: .viewModelUpdated, object: nil, userInfo: userInfo)
		
		self.UIDelegate?.bookmarkUIDidChange(isBookmarked: active)
	}
}
