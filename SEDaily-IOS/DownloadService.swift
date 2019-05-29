//
//  DownloadService.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/24/19.
//  Copyright © 2019 Altalogy All rights reserved.
//

protocol DownloadServiceUIDelegate: class {
	func downloadUIDidChange(progress: Int?, success: Bool?)
}
import Foundation
import UIKit

class DownloadService {
	
	weak var UIDelegate: DownloadServiceUIDelegate?
	
	var podcastViewModel: PodcastViewModel
	
	private let downloadManager = OfflineDownloadsManager.sharedInstance
	
	init(podcastViewModel: PodcastViewModel) {
		self.podcastViewModel = podcastViewModel
	}
	
	func savePodcast() {
		
		let podcastId = self.podcastViewModel._id
		
		self.downloadManager.save(
			podcast: self.podcastViewModel,
			onProgress: { progress in
				// Show progress
				let progressAsInt = Int((progress * 100).rounded())
				self.UIDelegate?.downloadUIDidChange(progress: progressAsInt, success: nil)
				self.podcastViewModel.downloadingProgress = progressAsInt
		},
			onSuccess: {
				self.UIDelegate?.downloadUIDidChange(progress: nil, success: true)
				
				
		},
			onFailure: { error in
				self.UIDelegate?.downloadUIDidChange(progress: nil, success: false)
				guard let error = error else { return }
				// Alert Error
				Helpers.alertWithMessage(title: error.localizedDescription.capitalized, message: "")
				
		})
	}
	
	func deletePodcast() {
		
		Helpers.alertWithMessageCustomAction(title: L10n.deletePodcast, message: nil, actionTitle: L10n.deletePodcastButtonTitle) { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.downloadManager.deletePodcast(podcast: strongSelf.podcastViewModel) {
				strongSelf.UIDelegate?.downloadUIDidChange(progress: nil, success: false)
			}
		}
	}
}
