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

class AudioViewManager: NSObject {

    static let shared: AudioViewManager = AudioViewManager()
    private override init() {}
    
    /// The instance of `AssetPlaybackManager` that the app uses for managing playback.
    var assetPlaybackManager: AssetPlayer! = nil
    
    /// The instance of `RemoteCommandManager` that the app uses for managing remote command events.
    var remoteCommandManager: RemoteCommandManager! = nil

    var audioView: AudioView?
    var podcastModel: PodcastViewModel?
    
    func setupManager(podcastModel: PodcastViewModel) {
        self.podcastModel = podcastModel
        Tracker.logPlayPodcast(podcast: podcastModel)
        self.presentAudioView()
    }
    
    fileprivate func setupAudioManager(url: URL, name: String) {
        var savedTime: Float = 0
        //@TODO: Add tracking for current time again
//        if let time = podcastModel?.currentTime {
//            if let float = Float(time) {
//                savedTime = float
//            }
//        }
        log.info(savedTime, "savedtime")
        
        let asset = Asset(assetName: name, url: url, savedTime: savedTime)
        assetPlaybackManager = AssetPlayer(asset: asset)
        assetPlaybackManager.playerDelegate = self

        // If you want remote commands
        // Initializer the `RemoteCommandManager`.
        remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlaybackManager)
        
        // Always enable playback commands in MPRemoteCommandCenter.
        remoteCommandManager.activatePlaybackCommands(true)
        remoteCommandManager.toggleChangePlaybackPositionCommand(true)
        remoteCommandManager.toggleSkipBackwardCommand(true, interval: 30)
        remoteCommandManager.toggleSkipForwardCommand(true, interval: 30)
        remoteCommandManager.toggleChangePlaybackPositionCommand(true)
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
            
            guard let url = self.podcastModel?.mp3URL else { return }
            guard let name = self.podcastModel?.podcastTitle else { return }
            
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
            setText(text: podcastModel?.podcastTitle)
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

        setText(text: podcastModel?.podcastTitle)
        
        audioView?.animateIn()
    }
    
    fileprivate func setText(text: String?) {
        guard audioView != nil else { return }
        audioView?.setText(text: text)
    }
    
    //@TODO: Switch all handling of enabled parts of audio view to here
    //@TODO: Add manager param and update everything here (maybe)
    fileprivate func handleStateChange(for state: AssetPlayerPlaybackState) {
        if let model = podcastModel {
            self.setText(text: model.podcastTitle)
        }
        
        switch state {
        case .setup:
            audioView?.isFirstLoad = true
            audioView?.disableButtons()
            audioView?.activityView.startAnimating()
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
            break
        case .playing:
            audioView?.enableButtons()
            audioView?.activityView.stopAnimating()
            
            audioView?.playButton.isHidden = true
            audioView?.pauseButton.isHidden = false
            break
        case .paused:
            audioView?.activityView.stopAnimating()
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
            break
        case .interrupted:
            //@TODO: handle interrupted
            break
        case .failed:
            audioView?.animateOut()
            break
        case .buffering:
            audioView?.activityView.startAnimating()
            
            audioView?.stopButton.isEnabled = true
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
            break
        case .stopped:
            self.triggerRemoveContainerViewInset()
            audioView?.animateOut()
            
            audioView = nil
            break
        }
    }
}

extension AudioViewManager: AssetPlayerDelegate {
    func currentAssetDidChange(_ player: AssetPlayer) {
        log.debug("asset did change")
        audioView?.currentSpeed = ._1x
    }
    
    func playerIsSetup(_ player: AssetPlayer) {
        audioView?.updateSlider(maxValue: player.maxSecondValue)
    }
    
    func playerPlaybackStateDidChange(_ player: AssetPlayer) {
        guard let state = player.state else { return }
        self.handleStateChange(for: state)
    }
    
    func playerCurrentTimeDidChange(_ player: AssetPlayer) {
        //@TODO: Add back current time tracking
//        podcastModel?.update(currentTime: Float(player.currentTime))
        
        audioView?.updateTimeLabels(currentTimeText: player.timeElapsedText, timeLeftText: player.timeLeftText)
        
        audioView?.updateSlider(currentValue: Float(player.currentTime))
    }
    
    func playerPlaybackDidEnd(_ player: AssetPlayer) {
        //@TODO: Add back current time tracking
//        podcastModel?.update(currentTime: 0.0)
    }
    
    func playerIsLikelyToKeepUp(_ player: AssetPlayer) {
        //@TODO: Nothing to do here?
    }
    
    func playerBufferTimeDidChange(_ player: AssetPlayer) {
        audioView?.updateBufferSlider(bufferValue: player.bufferedTime)
    }
    
}

extension AudioViewManager: AudioViewDelegate {
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
        assetPlaybackManager?.stop()
    }
    
    func skipForwardButtonPressed() {
        assetPlaybackManager?.skipForward(30)
    }
    
    func skipBackwardButtonPressed() {
        assetPlaybackManager?.skipBackward(30)
    }
    
    func audioRateChanged(newRate: Float) {
        // Change audio player speed
        assetPlaybackManager?.changePlayerPlaybackRate(to: newRate)
    }
}
