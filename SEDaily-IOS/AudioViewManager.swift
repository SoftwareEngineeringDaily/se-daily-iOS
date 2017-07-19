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

class AudioViewManager: NSObject{

    static let shared: AudioViewManager = AudioViewManager()
    private override init() {
        super.init()
        self.audioManager = AudioManager()
        self.audioManager?.playerDelegate = self
    }
    
    var audioView: AudioView?
    var podcastModel: PodcastModel?
    var audioManager: AudioManager?
    
    func setupManager(podcastModel: PodcastModel) {
        self.podcastModel = podcastModel
        self.presentAudioView()
    }
    
    fileprivate func setupAudioManager() {
//        if podcastModel.mp3Saved {
//            let audioFile = AudioFile(fileURL: podcastModel.getSavedMP3URL(), currentTime: podcastModel.getCurrentTime()!)
//            audioManager.play(audioFile: audioFile)
//            return
//        }
//
        guard let url = podcastModel?.getMP3asURL() else { return }
        audioManager?.setupAudio(url: url, currentTime: podcastModel?.getCurrentTime())
//        guard let fileName = podcastModel.podcastName else { return }
//        audioManager.willDownload(from: url, fileName: fileName)
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
            self.setupAudioManager()
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
    fileprivate func handleAudioManagerStateChange() {
        if let model = podcastModel {
            self.setText(text: model.podcastName)
        }
        
        guard let audioManager = audioManager else { return }
        switch audioManager.playbackState {
        case .setup:
            audioView?.isFirstLoad = true
            audioView?.activityView.startAnimating()
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
        case .stopped:
            audioView?.animateOut()

            audioView = nil
        case .willDownload:
            audioView?.activityView.startAnimating()
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
        case .downloading:
            audioView?.activityView.startAnimating()
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
        case .playing:
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
            
            audioView?.playButton.isHidden = false
            audioView?.pauseButton.isHidden = true
        }
    }
}

extension AudioViewManager: AudioManagerDelegate {
    func playerBufferTimeDidChange(_ bufferValue: Float) {
        audioView?.updateBufferSlider(bufferValue: bufferValue)
    }

    func playerIsLikelyToKeepUp(_ player: AudioManager) {
        guard let duration = player.getDuration() else { return }

        audioView?.updateSlider(maxValue: Float(duration))
    }

    func playerIsBuffering(_ player: AudioManager) {
        handleAudioManagerStateChange()
    }

    func playerDownloadProgressDidChange(_ player: AudioManager) {
//        audioView.updateDownloadProgress(progress: player.loadingProgress)
    }

    func playerDidFinishDownloading(_ player: AudioManager) {
//        podcastModel.update(mp3Saved: true)
    }

    func playerPlaybackDidEnd(_ player: AudioManager) {
        log.info("playback did end")
        podcastModel?.update(currentTime: 0.0)
    }
    
    func playerCurrentTimeDidChange(_ player: AudioManager) {
        guard let currentTime = player.getCurrentTime() else { return }
        podcastModel?.update(currentTime: currentTime)
        log.info(currentTime)
        log.info(player.getDuration())
        guard let duration = player.getDuration() else { return }
        let timeLeft = Double(duration - currentTime)
        
        var currentTimeString = ""
        Helpers.hmsFrom(seconds: Int(currentTime), completion: { hours, minutes, seconds in
            let hoursString = Helpers.getStringFrom(seconds: hours)
            let minutesString = Helpers.getStringFrom(seconds: minutes)
            let secondsString = Helpers.getStringFrom(seconds: seconds)
            
            if hoursString == "00" {
                currentTimeString = "\(minutesString):\(secondsString)"
                return
            }
            currentTimeString = "\(hoursString):\(minutesString):\(secondsString)"
        })
        
        var timeLeftString = ""
        Helpers.hmsFrom(seconds: Int(timeLeft), completion: { hours, minutes, seconds in
            let hoursString = Helpers.getStringFrom(seconds: hours)
            let minutesString = Helpers.getStringFrom(seconds: minutes)
            let secondsString = Helpers.getStringFrom(seconds: seconds)

            if hoursString == "00" {
                timeLeftString = "-" + "\(minutesString):\(secondsString)"
                return
            }
            timeLeftString = "-" + "\(hoursString):\(minutesString):\(secondsString)"
        })
        
        audioView?.updateTimeLabels(currentTimeString: currentTimeString, timeLeftString: timeLeftString)

        audioView?.updateSlider(currentValue: Float(currentTime))
    }
    
    func playerPlaybackStateDidChange(_ player: AudioManager) {
        handleAudioManagerStateChange()
    }
    
    func playerReady(_ player: AudioManager) {
        
    }
}

extension AudioViewManager: AudioViewDelegate {
    func playbackSliderValueChanged(value: Float) {
        let cmTime = CMTimeMake(Int64(value), 1)
        //@TODO: This is slowing down ui
        audioManager?.seek(to: cmTime)
    }

    func playButtonPressed() {
        audioManager?.play()
    }
    
    func pauseButtonPressed() {
        audioManager?.pause()
    }
    
    func stopButtonPressed() {
        audioManager?.stop()
    }
    
    func skipForwardButtonPressed() {
        audioManager?.skipForward()
    }
    
    func skipBackwardButtonPressed() {
        audioManager?.skipBackward()
    }
}
