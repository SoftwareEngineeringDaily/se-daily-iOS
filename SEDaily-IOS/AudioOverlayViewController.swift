//
//  AudioViewManager.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/29/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwiftIcons
import AVFoundation
import SnapKit
import SwifterSwift
import KTResponsiveUI
import KoalaTeaPlayer

protocol AudioOverlayDelegate: class {
	func animateOverlayIn()
	func animateOverlayOut()
	func playAudio(podcastViewModel: PodcastViewModel)
	func pauseAudio()
	func stopAudio()
	func setCurrentShowingDetailView(podcastViewModel: PodcastViewModel?)
	func setServices(upvoteService: UpvoteService, bookmarkService: BookmarkService)
}

//extension AudioOverlayDelegate {
//	func setServices(upvoteService: UpvoteService, bookmarkService: BookmarkService) { }
//}

class AudioOverlayViewController: UIViewController {
	let networkService = API()
	
	static let audioControlsViewHeight: CGFloat = 130
	
	private static var userSettingPlaybackSpeedKey = "PlaybackSpeed"
	
	/// The instance of `AssetPlaybackManager` that the app uses for managing playback.
	private var assetPlaybackManager: AssetPlayer! = nil
	
	/// The instance of `RemoteCommandManager` that the app uses for managing remote command events.
	private var remoteCommandManager: RemoteCommandManager! = nil
	
	/// The instance of PlayProgressModelController to retrieve and save progress of the playback
	private var progressController = PlayProgressModelController()
	

	
	private var audioView: AudioView?
	private var podcastViewModel: PodcastViewModel?
	private let verticalStackView = UIStackView()
	private let horizontalStackView = UIStackView()
	private var currentViewController: UIViewController?
	private weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	private var upvoteService: UpvoteService?
	private var bookmarkService: BookmarkService?
	
	init(audioOverlayDelegate: AudioOverlayDelegate) {
		self.audioOverlayDelegate = audioOverlayDelegate
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		self.verticalStackView.axis = .vertical
		self.view.addSubview(self.verticalStackView)
		
		horizontalStackView.axis = .horizontal
		horizontalStackView.distribution = .fillEqually
		self.verticalStackView.addArrangedSubview(horizontalStackView)
		
		self.audioView = AudioView(frame: CGRect.zero, audioViewDelegate: self)
		if let audioView = self.audioView {
			horizontalStackView.addArrangedSubview(audioView)
		}
		
		horizontalStackView.snp.makeConstraints { (make) in
			make.height.equalTo(
				UIView.getValueScaledByScreenHeightFor(
					baseValue: AudioOverlayViewController.audioControlsViewHeight))
		}
		self.verticalStackView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
	}
	
	
	deinit {
		
	
	}
	
	func animateIn() {
		self.view.snp.updateConstraints { (make) in
			make.bottom.equalToSuperview().offset(0)
			make.top.equalToSuperview().offset(
				UIScreen.main.bounds.height -
					UIView.getValueScaledByScreenHeightFor(
						baseValue: AudioOverlayViewController.audioControlsViewHeight))
		}
		
		UIView.animate(withDuration: 0.25) {
			self.view.superview?.layoutIfNeeded()
		}
		
		self.audioView?.showSliders()
	}
	
	func animateOut() {
		self.view.snp.updateConstraints { (make) in
			make.bottom.equalToSuperview().offset(
				UIView.getValueScaledByScreenHeightFor(
					baseValue: AudioOverlayViewController.audioControlsViewHeight))
			make.top.equalToSuperview().offset(UIScreen.main.bounds.height)
		}
		
		UIView.animate(withDuration: 0.25) {
			self.view.superview?.layoutIfNeeded()
		}
		
		self.audioView?.hideSliders()
	}
	
	@objc func closeButtonPressed() {
		self.audioOverlayDelegate?.animateOverlayOut()
	}
	
	func playAudio(podcastViewModel: PodcastViewModel) {
		self.podcastViewModel = podcastViewModel
		Tracker.logPlayPodcast(podcast: podcastViewModel)
		
		self.audioView?.hideExpandCollapseButton()
		self.setText(text: podcastViewModel.podcastTitle)
		self.saveProgress()
		self.loadAudio(podcastViewModel: podcastViewModel)
		self.createPodcastDetailViewController(podcastViewModel: podcastViewModel)
		CurrentlyPlaying.shared.setCurrentlyPlaying(id: podcastViewModel._id)
		// TODO: only mark if logged in
		networkService.markAsListened(postId: podcastViewModel._id)
		Analytics2.podcastPlayed(podcastId: podcastViewModel._id)
	}
	
	func pauseAudio() {
		self.pauseButtonPressed()
	}
	
	func stopAudio() {
		self.stopButtonPressed()
		CurrentlyPlaying.shared.setCurrentlyPlaying(id: "")
	}
	
	private func saveProgress() {
		
		guard self.podcastViewModel != nil else { return }
		progressController.retrieve()
	}
	
	private func loadAudio(podcastViewModel: PodcastViewModel) {
		var fileURL: URL? = nil
		fileURL = podcastViewModel.mp3URL
		if let urlString = podcastViewModel.downloadedFileURLString {
			fileURL = URL(fileURLWithPath: urlString)
		}
		guard let url = fileURL else { return }
		self.setupAudioManager(
			url: url,
			podcastViewModel: podcastViewModel)
	}
	
	private func createPodcastDetailViewController(podcastViewModel: PodcastViewModel) {
		if let currentViewController = self.currentViewController {
			self.verticalStackView.removeArrangedSubview(currentViewController.view)
			currentViewController.willMove(toParentViewController: nil)
			currentViewController.view.removeFromSuperview()
			currentViewController.removeFromParentViewController()
		}
//		guard let bookmarkService = self.bookmarkService else { return }
//		guard let upvoteService = self.upvoteService else { return }
	
		let podcastDetailViewController = EpisodeViewController(nibName: nil, bundle: nil, audioOverlayDelegate: audioOverlayDelegate)
		podcastDetailViewController.viewModel = podcastViewModel
		
		let navVC = UINavigationController(rootViewController: podcastDetailViewController)
		navVC.view.backgroundColor = .white
		self.addChildViewController(navVC)
		
		self.verticalStackView.insertArrangedSubview(navVC.view, at: 0)
		self.verticalStackView.sendSubview(toBack: navVC.view)
		navVC.didMove(toParentViewController: self)
		
		self.currentViewController = navVC
	}
	
	fileprivate func setupAudioManager(url: URL, podcastViewModel: PodcastViewModel) {
		var savedTime: Float = 0
		
		//Load Saved time
		
		
		if progressController.episodesPlayProgress[podcastViewModel._id] != nil {
			savedTime = progressController.episodesPlayProgress[podcastViewModel._id]!.currentTime
		} else {
			progressController.episodesPlayProgress[podcastViewModel._id]?.currentTime = 0
		}
		
		log.info(savedTime, "savedtime")
		
		let asset = Asset(assetName: podcastViewModel.podcastTitle, url: url, savedTime: savedTime)
		assetPlaybackManager = AssetPlayer(asset: asset)
		assetPlaybackManager.playerDelegate = self
		
		// If you want remote commands
		// Initializer the `RemoteCommandManager`.
		self.remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlaybackManager)
		
		// Always enable playback commands in MPRemoteCommandCenter.
		self.remoteCommandManager.activatePlaybackCommands(true)
		self.remoteCommandManager.toggleChangePlaybackPositionCommand(true)
		self.remoteCommandManager.toggleSkipBackwardCommand(true, interval: 30)
		self.remoteCommandManager.toggleSkipForwardCommand(true, interval: 30)
		self.remoteCommandManager.toggleChangePlaybackPositionCommand(true)
	}
	
	fileprivate func triggerRemoveContainerViewInset() {
		self.audioOverlayDelegate?.animateOverlayOut()
	}
	
	fileprivate func setText(text: String?) {
		audioView?.setText(text: text)
	}
	
	//@TODO: Switch all handling of enabled parts of audio view to here
	//@TODO: Add manager param and update everything here (maybe)
	fileprivate func handleStateChange(for state: AssetPlayerPlaybackState) {
		if let podcastViewModel = self.podcastViewModel {
			self.setText(text: podcastViewModel.podcastTitle)
		}
		
		switch state {
		case .setup:
			audioView?.isFirstLoad = true
			audioView?.disableButtons()
			audioView?.startActivityAnimating()
			
			audioView?.playButton.isHidden = false
			audioView?.pauseButton.isHidden = true
		case .playing:
			audioView?.enableButtons()
			audioView?.stopActivityAnimating()
			
			audioView?.playButton.isHidden = true
			audioView?.pauseButton.isHidden = false
		case .paused:
			audioView?.enableButtons()
			audioView?.stopActivityAnimating()
			
			audioView?.playButton.isHidden = false
			audioView?.pauseButton.isHidden = true
		case .interrupted:
			//@TODO: handle interrupted
			break
		case .failed:
			self.audioOverlayDelegate?.animateOverlayOut()
		case .buffering:
			audioView?.startActivityAnimating()
			
			//audioView?.stopButton.isEnabled = true
			audioView?.playButton.isHidden = false
			audioView?.pauseButton.isHidden = true
		case .stopped:
			self.triggerRemoveContainerViewInset()
			self.audioOverlayDelegate?.animateOverlayOut()
		}
	}
}

extension AudioOverlayViewController: AssetPlayerDelegate {
	func currentAssetDidChange(_ player: AssetPlayer) {
		log.debug("asset did change")
		if let playbackSpeedValue = UserDefaults.standard.object(forKey: AudioOverlayViewController.userSettingPlaybackSpeedKey) as? Float,
			let playbackSpeed = PlaybackSpeed(rawValue: playbackSpeedValue) {
			audioView?.currentSpeed = playbackSpeed
			audioRateChanged(newRate: playbackSpeedValue)
		} else {
			audioView?.currentSpeed = ._1x
		}
	}
	
	func playerIsSetup(_ player: AssetPlayer) {
		audioView?.updateSlider(maxValue: player.maxSecondValue)
	}
	
	func playerPlaybackStateDidChange(_ player: AssetPlayer) {
		guard let state = player.state else { return }
		self.handleStateChange(for: state)
	}
	
	func playerCurrentTimeDidChange(_ player: AssetPlayer) {
		
		// Update progress
		guard let podcastViewModel = self.podcastViewModel  else { return }
		let progress = PlayProgress(id: podcastViewModel._id, currentTime: Float(player.currentTime), totalLength: Float(player.maxSecondValue))
		progressController.episodesPlayProgress[podcastViewModel._id] = progress
		
		if round(player.currentTime).truncatingRemainder(dividingBy: 5.0) == 0.0 {
			progressController.save()
		}
		
		audioView?.updateTimeLabels(currentTimeText: player.timeElapsedText, timeLeftText: player.timeLeftText)

		audioView?.updateSlider(currentValue: Float(player.currentTime))
	}
	
	func playerPlaybackDidEnd(_ player: AssetPlayer) {
		// Reset progress
		if let podcastViewModel = self.podcastViewModel {
			progressController.episodesPlayProgress[podcastViewModel._id]?.currentTime = 0.0
			progressController.save()
		}
	}
	
	func playerIsLikelyToKeepUp(_ player: AssetPlayer) {
		//@TODO: Nothing to do here?
	}
	
	func playerBufferTimeDidChange(_ player: AssetPlayer) {
		audioView?.updateBufferSlider(bufferValue: player.bufferedTime)
	}
	
}

extension AudioOverlayViewController: AudioViewDelegate {
	func playbackSliderValueChanged(value: Float) {
		let cmTime = CMTimeMake(Int64(value), 1)
		assetPlaybackManager?.seekTo(cmTime)
	}
	
	func playButtonPressed() {
		assetPlaybackManager?.play()
	}
	
	func pauseButtonPressed() {
		assetPlaybackManager?.pause()
	}
	
	func stopButtonPressed() {
		self.audioOverlayDelegate?.animateOverlayOut()
		assetPlaybackManager?.stop() //
	}
	
	func skipForwardButtonPressed() {
		assetPlaybackManager?.skipForward(30)
	}
	
	func expandButtonPressed() {
		self.view.snp.updateConstraints({ (make) in
			make.top.equalToSuperview().offset(0)
		})
		
		UIView.animate(withDuration: 0.25) {
			self.view.superview?.layoutIfNeeded()
		}
	}
	
	func collapseButtonPressed() {
		self.view.snp.updateConstraints({ (make) in
			make.top.equalToSuperview().offset(
				UIScreen.main.bounds.height -
					UIView.getValueScaledByScreenHeightFor(
						baseValue: AudioOverlayViewController.audioControlsViewHeight))
		})
		UIView.animate(withDuration: 0.25) {
			self.view.superview?.layoutIfNeeded()
		}
	}
	
	func skipBackwardButtonPressed() {
		assetPlaybackManager?.skipBackward(30)
	}
	
	func audioRateChanged(newRate: Float) {
		assetPlaybackManager?.changePlayerPlaybackRate(to: newRate)
		UserDefaults.standard.set(newRate, forKey: AudioOverlayViewController.userSettingPlaybackSpeedKey)
	}
	
	func setCurrentShowingDetailView(podcastViewModel: PodcastViewModel?) {
		self.audioView?.showExpandCollapseButton()
		if let podcastViewModel = podcastViewModel,
			let currentPlayingPodcastViewModel = self.podcastViewModel {
			if currentPlayingPodcastViewModel._id == podcastViewModel._id {
				self.audioView?.hideExpandCollapseButton()
			}
		}
	}
	
	func setServices(upvoteService: UpvoteService, bookmarkService: BookmarkService) {
		self.upvoteService = upvoteService
		self.bookmarkService = bookmarkService
	}
}
