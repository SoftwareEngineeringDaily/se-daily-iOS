//
//  OverlayViewController.swift
//  ExpandableOverlay
//
//  Created by Dawid Cedrych on 6/18/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import KoalaTeaPlayer

protocol OverlayViewDelegate: class {
  func didSelectInfo()
  func didTapCollapse()
}

class OverlayViewController: UIViewController, Stateful {
  var stateController: StateController? { didSet { print("set1")}}
  
  let networkService = API()
  
  private static var userSettingPlaybackSpeedKey = "PlaybackSpeed"
  
  /// The instance of `AssetPlaybackManager` that the app uses for managing playback.
  private var assetPlaybackManager: AssetPlayer! = nil
  
  /// The instance of `RemoteCommandManager` that the app uses for managing remote command events.
  private var remoteCommandManager: RemoteCommandManager! = nil
  
  /// The instance of PlayProgressModelController to retrieve and save progress of the playback
  private var progressController = PlayProgressModelController()
  
  weak var delegate: OverlayViewDelegate?
  
  var viewModel: PodcastViewModel = PodcastViewModel() {
    didSet {
      audioPlayerView?.viewModel = viewModel
      audioPlayerView?.expanded = false
      audioPlayerView?.performLayout()
    }
  }
  
  
  var expanded: Bool = false {
    didSet {
      audioPlayerView?.expanded = expanded
    }
  }
  
  var audioPlayerView: AudioPlayerView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    audioPlayerView = AudioPlayerView(frame: CGRect.zero, audioViewDelegate: self)
    view.addSubview(audioPlayerView!)
    audioPlayerView?.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  fileprivate func setText(text: String?) {
    audioPlayerView?.setText(text: text)
  }
  
  private func saveProgress() {
    
    guard viewModel != nil else { return }
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
  
  fileprivate func handleStateChange(for state: AssetPlayerPlaybackState) {
    self.setText(text: viewModel.podcastTitle)
    
    switch state {
    case .setup:
      //audioPlayerView?.isFirstLoad = true
      //audioPlayerView?.disableButtons()
      //audioPlayerView?.startActivityAnimating()
      
      audioPlayerView?.playButton.isHidden = false
      audioPlayerView?.pauseButton.isHidden = true
    case .playing:
      //audioPlayerView?.enableButtons()
      //audioPlayerView?.stopActivityAnimating()
      
      audioPlayerView?.playButton.isHidden = true
      audioPlayerView?.pauseButton.isHidden = false
    case .paused:
      //audioPlayerView?.enableButtons()
      //audioPlayerView?.stopActivityAnimating()
      
      audioPlayerView?.playButton.isHidden = false
      audioPlayerView?.pauseButton.isHidden = true
      //audioPlayerView?.pauseButton.isHidden = true
    case .interrupted:
      //@TODO: handle interrupted
      break
    case .failed:
      print("dummy")
    //self.audioOverlayDelegate?.animateOverlayOut()
    case .buffering:
      //audioPlayerView?.startActivityAnimating()
      
      //audioPlayerView?.stopButton.isEnabled = true
      audioPlayerView?.playButton.isHidden = false
      audioPlayerView?.pauseButton.isHidden = true
      //audioPlayerView?.pauseButton.isHidden = true
    case .stopped:
      // dismiss whole overlay
      
      // change play/stop button state
      CurrentlyPlaying.shared.setCurrentlyPlaying(id: "")
      let userInfo = ["viewModel": viewModel]
      NotificationCenter.default.post(name: .reloadEpisodeView, object: nil, userInfo: userInfo)
    }
  }
  
  @objc func infoTapped() {
    delegate?.didSelectInfo()
  }
  @objc func collapseTapped() {
    delegate?.didTapCollapse()
  }
}

extension OverlayViewController: AssetPlayerDelegate {
  func currentAssetDidChange(_ player: AssetPlayer) {
    log.debug("asset did change")
    if let playbackSpeedValue = UserDefaults.standard.object(forKey: OverlayViewController.userSettingPlaybackSpeedKey) as? Float,
      let playbackSpeed = PlaybackSpeed(rawValue: playbackSpeedValue) {
      audioPlayerView?.currentSpeed = playbackSpeed
      audioRateChanged(newRate: playbackSpeedValue)
    } else {
      audioPlayerView?.currentSpeed = ._1x
    }
  }
  
  func playerIsSetup(_ player: AssetPlayer) {
    audioPlayerView?.updateSlider(maxValue: player.maxSecondValue)
  }
  
  func playerPlaybackStateDidChange(_ player: AssetPlayer) {
    guard let state = player.state else { return }
    self.handleStateChange(for: state)
  }
  
  func playerCurrentTimeDidChange(_ player: AssetPlayer) {
    
    // Update progress
    let podcastViewModel = self.viewModel
    let progress = PlayProgress(id: podcastViewModel._id, currentTime: Float(player.currentTime), totalLength: Float(player.maxSecondValue))
    progressController.episodesPlayProgress[podcastViewModel._id] = progress
    
    if round(player.currentTime).truncatingRemainder(dividingBy: 5.0) == 0.0 {
      progressController.save()
    }
    
    audioPlayerView?.updateTimeLabels(currentTimeText: player.timeElapsedText, timeLeftText: player.timeLeftText)
    
    audioPlayerView?.updateSlider(currentValue: Float(player.currentTime))
  }
  
  func playerPlaybackDidEnd(_ player: AssetPlayer) {
    // Reset progress
    progressController.episodesPlayProgress[viewModel._id]?.currentTime = 0.0
    progressController.save()
  }
  
  func playerIsLikelyToKeepUp(_ player: AssetPlayer) {
    //@TODO: Nothing to do here?
  }
  
  func playerBufferTimeDidChange(_ player: AssetPlayer) {
    audioPlayerView?.updateBufferSlider(bufferValue: player.bufferedTime)
  }
  
}


extension OverlayViewController: AudioPlayerViewDelegate {
  func detailsButtonPressed() {
    
  }
  
  
  func playButtonPressed() {
    if stateController?.isFirstLoad ?? true {
      loadAudio(podcastViewModel: viewModel)
      stateController?.isFirstLoad = false
    } else {
      assetPlaybackManager?.play() }
  }
  
  func pauseButtonPressed() {
    assetPlaybackManager?.pause()
  }
  
  func stopButtonPressed() {
    
  }
  
  func skipForwardButtonPressed() {
    assetPlaybackManager?.skipForward(30)
  }
  
  func skipBackwardButtonPressed() {
    assetPlaybackManager?.skipBackward(30)
  }
  
  func collapseButtonPressed() {
    
  }
  
  func audioRateChanged(newRate: Float) {
    
  }
  
  func playbackSliderValueChanged(value: Float) {
    let cmTime = CMTimeMake(Int64(value), 1)
    assetPlaybackManager?.seekTo(cmTime)
  }
  
  
}

extension OverlayViewController: AudioOverlayDelegate {
  func animateOverlayIn() {
    
  }
  
  func animateOverlayOut() {
    
  }
  
  func pauseAudio() {
    
  }
  
  
  func playAudio(podcastViewModel: PodcastViewModel) {
    viewModel = podcastViewModel
    Tracker.logPlayPodcast(podcast: podcastViewModel)
    self.setText(text: podcastViewModel.podcastTitle)
    self.saveProgress()
    self.loadAudio(podcastViewModel: podcastViewModel)
    CurrentlyPlaying.shared.setCurrentlyPlaying(id: podcastViewModel._id)
    // TODO: only mark if logged in
    networkService.markAsListened(postId: podcastViewModel._id)
    Analytics2.podcastPlayed(podcastId: podcastViewModel._id)
    PlayProgressModelController.saveRecentlyListenedEpisodeId(id: podcastViewModel._id)
  }
  
  
  func stopAudio() {
    
  }
  
  func setCurrentShowingDetailView(podcastViewModel: PodcastViewModel?) {
    
  }
  
  
}
