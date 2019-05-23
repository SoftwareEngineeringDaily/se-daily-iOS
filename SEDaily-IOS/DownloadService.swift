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
	
	func notifyOnSuccess() {
		let userInfo = ["viewModel": podcastViewModel]
		NotificationCenter.default.post(name: .viewModelUpdated, object: nil, userInfo: userInfo)
	}
	
	func deletePodcast() {
		
		let alert = UIAlertController(title: "Are you sure you want to delete this podcast?", message: nil, preferredStyle: .alert)
		
		alert.addAction(title: "YEP! Delete it please.", style: .destructive, isEnabled: true) { _ in
			self.downloadManager.deletePodcast(podcast: self.podcastViewModel) {
				self.UIDelegate?.downloadUIDidChange(progress: nil, success: false)
			}
		}
		
		let noAction = UIAlertAction(title: "Oh no actually...", style: .cancel, handler: nil)
		alert.addAction(noAction)
		
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			
			guard !(topController is UIAlertController) else {
				// There's already a alert preseneted
				return
			}
			
			topController.present(alert, animated: true, completion: nil)
		}
	}
	
	
	
	
	
	
	
}





//private func deletePodcast() {
//	guard self.downloadButton.isSelected else { return }
//
//	let alert = UIAlertController(title: "Are you sure you want to delete this podcast?", message: nil, preferredStyle: .alert)
//
//	alert.addAction(title: "YEP! Delete it please.", style: .destructive, isEnabled: true) { _ in
//		self.downloadManager.deletePodcast(podcast: self.podcastViewModel) {
//			print("Successfully deleted")
//		}
//
//		self.downloadButton.isSelected = false
//		self.playButton.setTitle("Play", for: .normal)
//		self.playButton.isUserInteractionEnabled = true
//	}
//
//	let noAction = UIAlertAction(title: "Oh no actually...", style: .cancel, handler: nil)
//	alert.addAction(noAction)
//
//	if var topController = UIApplication.shared.keyWindow?.rootViewController {
//		while let presentedViewController = topController.presentedViewController {
//			topController = presentedViewController
//		}
//
//		guard !(topController is UIAlertController) else {
//			// There's already a alert preseneted
//			return
//		}
//
//		topController.present(alert, animated: true, completion: nil)
//	}
//}
