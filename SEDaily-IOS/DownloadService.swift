////
////  DownloadService.swift
////  SEDaily-IOS
////
////  Created by Dawid Cedrych on 4/24/19.
////  Copyright © 2019 Altalogy All rights reserved.
////
//
//protocol DownloadServiceUIDelegate: class {
//	func UIDidChange(isUpvoted: Bool, score: Int)
//}
//import Foundation
//
//class DownloadService {
//	
//	private let downloadManager = OfflineDownloadsManager.sharedInstance
//	
//	func savePodcast() {
//		guard !self.downloadButton.isSelected else { return }
//		self.downloadButton.isSelected = true
//		
//		self.playButton.isUserInteractionEnabled = false
//		
//		let podcastId = self.podcastViewModel._id
//		
//		self.downloadManager.save(
//			podcast: self.podcastViewModel,
//			onProgress: { progress in
//				// Show progress
//				let progressAsInt = Int((progress * 100).rounded())
//				self.playButton.setTitle(String(progressAsInt) + "%", for: .normal)},
//			onSucces: {
//				// Show success by changing download
//				self.delegate?.modelDidChange(viewModel: self.podcastViewModel)
//				//                self.audioOverlayDelegate?.animateOverlayIn()
//				//                self.audioOverlayDelegate?.playAudio(podcastViewModel: self.podcastViewModel)
//				//                self.audioOverlayDelegate?.pauseAudio()
//				self.playButton.setTitle("Play", for: .normal)
//				self.playButton.isUserInteractionEnabled = true},
//			onFailure: { error in
//				self.playButton.setTitle("Play", for: .normal)
//				self.playButton.isUserInteractionEnabled = true
//				
//				guard let error = error else { return }
//				// Alert Error
//				Helpers.alertWithMessage(title: error.localizedDescription.capitalized, message: "")})
//	}
//	
//	
//}
//
//
//
//
//
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
