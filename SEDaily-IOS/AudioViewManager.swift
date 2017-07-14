//
//  AudioViewManager.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/29/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwiftIcons

class AudioViewManager: NSObject{

    static let shared: AudioViewManager = AudioViewManager()
    private override init() {
        super.init()
        self.audioManager = AudioManager()
        self.audioManager.playerDelegate = self
    }
    
    var audioView: AudioView!
    var podcastModel: PodcastModel!
    var audioManager: AudioManager!
    
    func setupManager(podcastModel: PodcastModel) {
        self.podcastModel = podcastModel
        self.presentAudioView()
    }
    
    fileprivate func setupAudioManager() {
        if podcastModel.mp3Saved {
            let audioFile = AudioFile(fileURL: podcastModel.getSavedMP3URL(), currentTime: podcastModel.getCurrentTime()!)
            audioManager.play(audioFile: audioFile)
            return
        }

        guard let url = podcastModel.getMP3asURL() else { return }
        guard let fileName = podcastModel.podcastName else { return }
        audioManager.willDownload(from: url, fileName: fileName)
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
            self.setupAudioManager()
        }
    }
    
    fileprivate func setupView(over vc: UIViewController) {
        if audioView != nil {
            // Setup progress, text, other stuff
            setText(text: podcastModel.podcastName)
            return
        }
        
        audioView = AudioView()
        audioView.delegate = self
        vc.view.addSubview(audioView)
        
        audioView.width = UIScreen.main.bounds.width
        audioView.height = 110.calculateHeight()
        audioView.center.x = vc.view.center.x
        audioView.frame.origin.y = UIScreen.main.bounds.height

        setText(text: podcastModel.podcastName)
        
        audioView.animateIn()
    }
    
    fileprivate func setText(text: String?) {
        audioView.setText(text: text)
    }
    
    fileprivate func handleAudioManagerStateChange() {
        if let model = podcastModel {
            self.setText(text: model.podcastName)
        }
        
        switch audioManager.playbackState {
        case .stopped:
            audioView.animateOut()

            audioView = nil
        case .willDownload:
            audioView.activityView.startAnimating()
            
            audioView.playButton.isHidden = false
            audioView.pauseButton.isHidden = true
        case .downloading:
            audioView.activityView.startAnimating()
            
            audioView.playButton.isHidden = false
            audioView.pauseButton.isHidden = true
        case .playing:
            audioView.activityView.stopAnimating()
            
            audioView.playButton.isHidden = true
            audioView.pauseButton.isHidden = false
            audioView.progressLabel.text = ""
        case .paused:
            audioView.activityView.stopAnimating()
            
            audioView.playButton.isHidden = false
            audioView.pauseButton.isHidden = true
        case .failed:
            audioView.animateOut()
        }
    }
}

extension AudioViewManager: AudioManagerDelegate {
    func playerDownloadProgressDidChange(_ player: AudioManager) {
        audioView.updateDownloadProgress(progress: player.loadingProgress)
    }

    func playerDidFinishDownloading(_ player: AudioManager) {
        podcastModel.update(mp3Saved: true)
    }

    func playerPlaybackDidEnd(_ player: AudioManager) {
        
    }
    
    func playerCurrentTimeDidChange(_ player: AudioManager) {
        guard let currentTime = player.audioPlayer?.currentTime else { return }
        podcastModel.update(currentTime: currentTime)
        
        guard let duration = player.audioPlayer?.duration else { return }
        let progress = Float(currentTime / duration)
        audioView.updateCurrentTimeProgress(progress: progress)
    }
    
    func playerPlaybackStateDidChange(_ player: AudioManager) {
        handleAudioManagerStateChange()
    }
    
    func playerReady(_ player: AudioManager) {
        
    }
}

extension AudioViewManager: AudioViewDelegate {
    func playButtonPressed() {
        audioManager.play()
    }
    
    func pauseButtonPressed() {
        audioManager.pause()
    }
    
    func stopButtonPressed() {
        audioManager.stop()
    }
    
    func skipForwardButtonPressed() {
        audioManager.skipForward()
    }
    
    func skipBackwardButtonPressed() {
        audioManager.skipBackward()
    }
}
