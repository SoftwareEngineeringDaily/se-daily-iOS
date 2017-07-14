//
//  AudioManager.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/29/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import Alamofire

public class Task {
    enum State {
        case finished(AudioFile)
        case inProgress
    }
    
    var state: State {
        didSet {
            audioManager.playbackState = .downloading(task: self)
        }
    }
    var audioManager: AudioManager
    
    var request: Alamofire.Request? = nil
    var progress: Int = 0 {
        didSet {
            audioManager.loadingProgress = progress
        }
    }
    
    init(state: State, audioManager: AudioManager) {
        self.state = state
        self.audioManager = audioManager
    }
    
    func download(audioUrl: URL, fileName: String) {
        //audioUrl should be of type URL
        let audioFileName = String(audioUrl.lastPathComponent)!
        
        //path extension will consist of the type of file it is, m4a or mp4
        let pathExtension = audioFileName.pathExtension
        let name = fileName
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // the name of the file here I kept is yourFileName with appended extension
            //@TODO: Set name
            documentsURL.appendPathComponent(name + "." + pathExtension)
            return (documentsURL, [.removePreviousFile])
        }
        
        self.request = Alamofire.download(audioUrl, to: destination)
            .downloadProgress { progress in
                log.info("Download Progress: \((progress.fractionCompleted * 100))")

                let convertedProgressFraction = Int(progress.fractionCompleted * 100)
                self.progress = convertedProgressFraction
            }
            .response { response in
                guard let destinationUrl = response.destinationURL else { return }
                
                self.request = nil
                
                let audioFile = AudioFile(fileURL: destinationUrl, currentTime: 0.0)
                self.state = .finished(audioFile)
            }
    }
    
    func pause() {
        guard request != nil else { return }
        request?.suspend()
    }
    
    func cancel() {
        guard request != nil else { return }
        request?.cancel()
    }
}

/// Asset playback states.
public enum PlaybackState {
    case stopped
    case willDownload(from: URL, fileName: String)
    case downloading(task: Task)
    case playing(AudioFile)
    case paused
    case failed
}

extension PlaybackState: CustomStringConvertible {
    public var description: String {
        switch self {
            case .stopped: return "stopped"
            case .willDownload: return "willDownload"
            case .downloading: return "downloading"
            case .playing: return "playing"
            case .paused: return "paused"
            case .failed: return "failed"
        }
    }
}

public struct AudioFile {
    var fileURL: URL
    var currentTime: Double
}

// MARK: - PlayerDelegate

/// Player delegate protocol
public protocol AudioManagerDelegate: NSObjectProtocol {
    func playerReady(_ player: AudioManager)
    func playerPlaybackStateDidChange(_ player: AudioManager)
    func playerCurrentTimeDidChange(_ player: AudioManager)
    func playerPlaybackDidEnd(_ player: AudioManager)
    func playerDidFinishDownloading(_ player: AudioManager)
    func playerDownloadProgressDidChange(_ player: AudioManager)
//    func playerBufferingStateDidChange(_ player: AudioManager)
    
    // This is the time in seconds that the video has been buffered.
    // If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
//    func playerBufferTimeDidChange(_ bufferTime: Double)
}

public class AudioManager: NSObject {
    /// Player delegate.
    open weak var playerDelegate: AudioManagerDelegate?
    
    var task: Task?
    var loadingProgress: Int = 0 {
        didSet {
            playerDelegate?.playerDownloadProgressDidChange(self)
        }
    }
    var audioPlayer: AVAudioPlayer? = nil
    var currentAudioFile: AudioFile? = nil
    var timer: Timer? = nil
    
    open var playbackState: PlaybackState = .stopped {
        didSet {
            // @TODO: .description doesn't work with downloading because we have to switch
            // back to that state and then use "task.state"
//            if playbackState.description != oldValue.description {
                self.playerDelegate?.playerPlaybackStateDidChange(self)
                handleStateChange()
//            }
        }
    }

    fileprivate func handleStateChange() {
        switch playbackState {
        case .stopped:
            log.info("stopped")
            
            self.timer?.invalidate()
            // Stop Audio
            self.audioPlayer?.pause()
            // Cancel any downloads
            self.task?.cancel()
            // @TODO: Set everything to nil
        case .willDownload(let audioURL, let fileName):
            log.info("will download")
            
            self.timer?.invalidate()
            self.audioPlayer?.pause()
            self.task?.cancel()
            
            task = Task(state: .inProgress, audioManager: self)
            
            task?.download(audioUrl: audioURL, fileName: fileName)
            
            playbackState = .downloading(task: task!)
        case .downloading(let task):
            log.info("downloading")
            // If the download task finished, start playback
            switch task.state {
            case .inProgress:
                break
            case .finished(let audioFile):
                self.playbackState = .playing(audioFile)
                self.playerDelegate?.playerDidFinishDownloading(self)
            }
        case .playing(let audioFile):
            log.info("playing")

            self.setupSession()
            self.setupMediaPlayerControls()
            self.task?.cancel()
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFile.fileURL, fileTypeHint: "mp3")
                self.currentAudioFile = audioFile
                
                audioPlayer?.currentTime = audioFile.currentTime
                audioPlayer?.play()
                setupTimer()
                
                // set audio once because this changes state
            } catch let error {
                log.error(error.localizedDescription)
                break
            }
        case .paused:
            log.info("paused")
            
            self.timer?.invalidate()
            self.audioPlayer?.pause()
        case .failed:
            log.info("failed")
            //@TODO: Setup some failure errors
        }
    }
    
    func setupSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch let error {
            log.error(error.localizedDescription)
        }
    }
    
    func setupMediaPlayerControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [30]
        commandCenter.skipBackwardCommand.removeTarget(nil)
        commandCenter.skipBackwardCommand.addTarget(self, action: #selector(self.skipBackward))
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.skipForwardCommand.removeTarget(nil)
        commandCenter.skipForwardCommand.addTarget(self, action: #selector(self.skipForward))
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.removeTarget(nil)
        
        commandCenter.playCommand.addTarget(self, action: #selector(self.targetPlay))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.pauseCommand.addTarget(self, action: #selector(self.pause))
    }
    
    func skipForward() {
        guard let currentTime = audioPlayer?.currentTime else { return }
        guard let duration = audioPlayer?.duration else { return }
        audioPlayer?.stop()
        audioPlayer?.currentTime = currentTime + 30.0
        if duration <= currentTime + 30 {
            self.stop()
            self.playerDelegate?.playerPlaybackDidEnd(self)
        }
        audioPlayer?.play()
    }
    
    func skipBackward() {
        guard let currentTime = audioPlayer?.currentTime else { return }
        audioPlayer?.stop()
        audioPlayer?.currentTime = currentTime - 30.0
        if 0.0 >= currentTime - 30 {
            audioPlayer?.currentTime = 0.0
        }
        audioPlayer?.play()
    }
    
    func setupTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
    }
    
    func updateCurrentTime() {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime
        guard currentTime <= player.duration else {
            self.playerDelegate?.playerPlaybackDidEnd(self)
            return
        }
        self.currentAudioFile?.currentTime = currentTime
        self.playerDelegate?.playerCurrentTimeDidChange(self)
    }
    
    public func willDownload(from url: URL, fileName: String) {
        self.playbackState = .willDownload(from: url, fileName: fileName)
    }
    
    public func play(audioFile: AudioFile? = nil) {
        //@TODO: Check if there is a current audio file
        // if not, wtf?
        guard let file = audioFile else {
            self.playbackState = .playing(self.currentAudioFile!)
            return
        }
        self.playbackState = .playing(file)
    }
    
    // Stil can't figure out why @obj is needed for some target functions
    public func targetPlay() {
        self.play()
    }
    
    public func pause() {
        self.playbackState = .paused
    }
    
    public func stop() {
        self.playbackState = .stopped
    }
}


