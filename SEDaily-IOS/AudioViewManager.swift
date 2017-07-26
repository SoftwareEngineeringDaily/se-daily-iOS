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

class AudioViewManager: NSObject {

    static let shared: AudioViewManager = AudioViewManager()
    
    /// The instance of `AssetPlaybackManager` that the app uses for managing playback.
    let assetPlaybackManager = Manager()
    
    /// The instance of `RemoteCommandManager` that the app uses for managing remote command events.
    var remoteCommandManager: RemoteCommandManager!
    
    private override init() {
        super.init()
        self.assetPlaybackManager.playerDelegate = self
    }
    
    var audioView: AudioView?
    var podcastModel: PodcastModel?
//    var audioManager: Manager?
    
    func setupManager(podcastModel: PodcastModel) {
        self.podcastModel = podcastModel
        self.presentAudioView()
    }
    
    fileprivate func setupAudioManager(url: URL, name: String) {
//        if podcastModel.mp3Saved {
//            let audioFile = AudioFile(fileURL: podcastModel.getSavedMP3URL(), currentTime: podcastModel.getCurrentTime()!)
//            audioManager.play(audioFile: audioFile)
//            return
//        }
//
//        guard let url = podcastModel?.getMP3asURL() else { return }
//        audioManager?.setupAudio(url: url, currentTime: podcastModel?.getCurrentTime())
//        guard let name = podcastModel?.podcastName else { return }
//        audioManager.willDownload(from: url, fileName: fileName)
        
        var savedTime: Float = 0
        if let time = podcastModel?.currentTime {
            if let float = Float(time) {
                savedTime = float
            }
        }
        log.info(savedTime, "savedtime")
        let avAsset = AVURLAsset(url: url)
        let asset = Asset(assetName: name, urlAsset: avAsset, savedTime: savedTime)
        assetPlaybackManager.asset = asset
        
        // @TODO: This takes a while
        
        // Initializer the `RemoteCommandManager`.
        remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlaybackManager)
        
        // Always enable playback commands in MPRemoteCommandCenter.
        remoteCommandManager.activatePlaybackCommands(true)
        remoteCommandManager.toggleSkipBackwardCommand(true, interval: 30)
        remoteCommandManager.toggleSkipForwardCommand(true, interval: 30)
    }

    fileprivate func presentAudioView() {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            guard !(topController is UIAlertController) else {
                // There's already a alert preseneted
                return
            }

            self.setupView(over: topController)
            
            // Move top controller's view's bottom constraint
            if let controller = topController as? ContainerViewController {
                controller.setContainerViewInset()
            }
            
            guard let url = self.podcastModel?.getMP3asURL() else { return }
            guard let name = self.podcastModel?.podcastName else { return }
            
            self.setupAudioManager(url: url, name: name)
        }
    }
    
    fileprivate func triggerRemoveContainerViewInset() {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            guard !(topController is UIAlertController) else {
                // There's already a alert preseneted
                return
            }
            
            // Move top controller's view's bottom constraint
            if let controller = topController as? ContainerViewController {
                controller.removeContainerViewInset()
            }
            
        }
    }
    
    fileprivate func setupView(over vc: UIViewController) {
        if audioView != nil {
            // Setup progress, text, other stuff
            setText(text: podcastModel?.podcastName)
            return
        }
        
        audioView = AudioView()
        audioView?.delegate = self
        
        // Can't add to view
        vc.view.addSubview(audioView!)
        
        audioView?.width = UIScreen.main.bounds.width
        audioView?.height = 110.calculateHeight()
        audioView?.center.x = vc.view.center.x
        audioView?.frame.origin.y = UIScreen.main.bounds.height

        setText(text: podcastModel?.podcastName)
        
        audioView?.animateIn()
    }
    
    fileprivate func setText(text: String?) {
        guard audioView != nil else { return }
        audioView?.setText(text: text)
    }
    
    //@TODO: Switch all handling of enabled parts of audio view to here
    //@TODO: Add manager param and update everything here (maybe)
    fileprivate func handleAudioManagerStateChange() {
        if let model = podcastModel {
            self.setText(text: model.podcastName)
        }
        
        switch assetPlaybackManager.state {
        case .initial:
            log.info("initial")
            audioView?.isFirstLoad = true
            audioView?.disableButtons()
            audioView?.activityView.startAnimating()
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
        case .stopped:
            self.triggerRemoveContainerViewInset()
            audioView?.animateOut()

            audioView = nil
//        case .willDownload:
//            audioView?.activityView.startAnimating()
//            
//            audioView?.playButton.isHidden = false
//            audioView?.pauseButton.isHidden = true
//        case .downloading:
//            audioView?.activityView.startAnimating()
//            
//            audioView?.playButton.isHidden = false
//            audioView?.pauseButton.isHidden = true
        case .playing:
            audioView?.enableButtons()
            audioView?.activityView.stopAnimating()
            
            audioView?.playButton.isHidden = true
            audioView?.pauseButton.isHidden = false
        case .paused:
            audioView?.activityView.stopAnimating()
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
        case .failed:
            audioView?.animateOut()
        case .buffering:
            audioView?.activityView.startAnimating()
            
            audioView?.stopButton.isEnabled = true
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
        case .interrupted:
            log.info("Interuppted state")
        }
    }
}

extension AudioViewManager: ManagerDelegate {
    func currentAssetDidChange(_ player: Manager) {
        log.info("Current Asset Changed")
    }

    func playerBufferTimeDidChange(_ bufferValue: Float) {
        audioView?.updateBufferSlider(bufferValue: bufferValue)
    }

    func playerIsLikelyToKeepUp(_ player: Manager) {
        let duration = player.duration
        log.error(duration, "duration")
        audioView?.updateSlider(maxValue: Float(duration))
    }

    func playerIsBuffering(_ player: Manager) {
        handleAudioManagerStateChange()
    }

    func playerDownloadProgressDidChange(_ player: Manager) {
//        audioView.updateDownloadProgress(progress: player.loadingProgress)
    }

    func playerDidFinishDownloading(_ player: Manager) {
//        podcastModel.update(mp3Saved: true)
    }

    func playerPlaybackDidEnd(_ player: Manager) {
        log.info("playback did end")
        podcastModel?.update(currentTime: 0.0)
    }
    
    func playerCurrentTimeDidChange(_ player: Manager) {
        let duration = player.duration
        let currentTime = player.playbackPosition
//        guard let currentTime = player.getCurrentTime() else { return }
        podcastModel?.update(currentTime: currentTime)
//
//        guard let duration = player.getDuration() else { return }
        let timeLeft = Float(duration - currentTime)
        
        audioView?.updateTimeLabels(currentTime: currentTime, timeLeft: timeLeft)

        audioView?.updateSlider(currentValue: Float(currentTime))
    }
    
    func playerPlaybackStateDidChange(_ player: Manager) {
        log.error(player.state)
        if player.state == .playing {
            let duration = player.duration
            audioView?.updateSlider(maxValue: Float(duration))
        }
        handleAudioManagerStateChange()
    }
    
    func playerReady(_ player: Manager) {
        
    }
}

extension AudioViewManager: AudioViewDelegate {
    func playbackSliderValueChanged(value: Float) {
        let cmTime = CMTimeMake(Int64(value), 1)
        assetPlaybackManager.seekTo(TimeInterval(value))
    }

    func playButtonPressed() {
        assetPlaybackManager.play()
    }
    
    func pauseButtonPressed() {
        assetPlaybackManager.pause()
    }
    
    func stopButtonPressed() {
        assetPlaybackManager.stop()
    }
    
    func skipForwardButtonPressed() {
        assetPlaybackManager.skipForward(30)
    }
    
    func skipBackwardButtonPressed() {
        assetPlaybackManager.skipBackward(30)
    }
}
