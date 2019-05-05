//
//  UpvoteService.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/23/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

protocol UpvoteServiceUIDelegate: class {
	func upvoteUIDidChange(isUpvoted: Bool, score: Int)
	func upvoteUIImmediateUpdate()
}


import Foundation

class UpvoteService {
	
	private let networkService = API()
	
	var podcastViewModel: PodcastViewModel {
		didSet {
			updateViewModel()
			updateUI(isUpvoted: self.podcastViewModel.isUpvoted, score: self.podcastViewModel.score)
		}
	}
	
	weak var UIDelegate: UpvoteServiceUIDelegate?

	init(podcastViewModel: PodcastViewModel) {
		self.podcastViewModel = podcastViewModel
	}
	
	func upvote() {
		guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
			Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
			return
		}
		self.UIDelegate?.upvoteUIImmediateUpdate()
		
		let podcastId = self.podcastViewModel._id
		networkService.upvotePodcast(podcastId: podcastId, completion: { [weak self] (success, active) in
			guard success != nil else {
				self?.UIDelegate?.upvoteUIImmediateUpdate()
				return
			}
			if success == true {
				guard let active = active else { return }
				self?.addScore(active: active)
				self?.setStatus(active: active)
			} else { self?.UIDelegate?.upvoteUIImmediateUpdate() }
		})
	}
	
	func addScore(active: Bool) {
		guard active != false else {
			self.setScoreTo(self.podcastViewModel.score - 1)
			return
		}
		self.setScoreTo(self.podcastViewModel.score + 1)
	}
	
	private func updateViewModel() {
		let userInfo = ["viewModel": podcastViewModel]
		NotificationCenter.default.post(name: .viewModelUpdated, object: nil, userInfo: userInfo)
	}
	private func updateUI(isUpvoted: Bool, score: Int) {
		self.UIDelegate?.upvoteUIDidChange(isUpvoted: isUpvoted, score: self.podcastViewModel.score)
	}
	
	func setScoreTo(_ score: Int) {
		guard self.podcastViewModel.score != score else { return }
		self.podcastViewModel.score = score
	}
	private func setStatus(active: Bool) {
	self.podcastViewModel.isUpvoted = active
	}
}
