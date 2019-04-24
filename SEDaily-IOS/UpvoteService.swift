//
//  UpvoteService.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/23/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

protocol UpvoteServiceModelDelegate: class {
	func modelDidChange(viewModel: PodcastViewModel)
}
protocol UpvoteServiceUIDelegate: class {
	func UIDidChange(isUpvoted: Bool, score: Int)
}


import Foundation

class UpvoteService {
	var podcastViewModel: PodcastViewModel {
		didSet {
			updateViewModel()
			updateUI(isUpvoted: self.podcastViewModel.isUpvoted, score: self.podcastViewModel.score)
		}
	}
	private let networkService = API()
	weak var modelDelegate: UpvoteServiceModelDelegate?
	weak var UIDelegate: UpvoteServiceUIDelegate?


	init(podcastViewModel: PodcastViewModel) {
		self.podcastViewModel = podcastViewModel
	}
	
	func upvote() {
		guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
			Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
			return
		}
		
		let podcastId = self.podcastViewModel._id
		networkService.upvotePodcast(podcastId: podcastId, completion: { (success, active) in
			guard success != nil else { return }
			if success == true {
				guard let active = active else { return }
				self.addScore(active: active)
				self.setStatus(active: active)
			}
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
		self.modelDelegate?.modelDidChange(viewModel: self.podcastViewModel)
	}
	private func updateUI(isUpvoted: Bool, score: Int) {
		self.UIDelegate?.UIDidChange(isUpvoted: isUpvoted, score: self.podcastViewModel.score)
	}
	
	func setScoreTo(_ score: Int) {
		guard self.podcastViewModel.score != score else { return }
		self.podcastViewModel.score = score
	}
	private func setStatus(active: Bool) {
	self.podcastViewModel.isUpvoted = active
	}

}


