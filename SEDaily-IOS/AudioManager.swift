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

public class Task: NSObject {
    enum State {
        case finished(url: URL, currentTime: Double)
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
//            audioManager.loadingProgress = progress
        }
    }
    
    init(state: State, audioManager: AudioManager) {
        self.state = state
        self.audioManager = audioManager
    }
    
    var observer: Any!
    var avPlayer: AVPlayer!
    
    func download(audioUrl: URL, fileName: String) {

        // Downloading File from URL
        
        // audioUrl should be of type URL
        let audioFileName = String(audioUrl.lastPathComponent)!
        
        //path extension will consist of the type of file it is, m4a or mp4
        let pathExtension = audioFileName.pathExtension
        let name = fileName
        
        let destination: DownloadRequest.DownloadFileDestination = {_,_  in
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
                
                self.state = .finished(url: destinationUrl, currentTime: 0.0)
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
    case setup(url: URL?, currentTime: Double?)
    case stopped
    case willDownload(from: URL, fileName: String)
    case downloading(task: Task)
    case playing
    case paused
    case failed
    case buffering
}

extension PlaybackState: CustomStringConvertible {
    public var description: String {
        get {
            switch self {
                case .setup: return "setup"
                case .stopped: return "stopped"
                case .willDownload: return "willDownload"
                case .downloading: return "downloading"
                case .playing: return "playing"
                case .paused: return "paused"
                case .failed: return "failed"
                case .buffering: return "buffering"
            }
        }
    }
}

//public struct AudioFile {
//    var fileURL: URL
//    var currentTime: Double
//}

// MARK: - PlayerDelegate

/// Player delegate protocol
public protocol AudioManagerDelegate: NSObjectProtocol {
    func playerReady(_ player: AudioManager)
    func playerPlaybackStateDidChange(_ player: AudioManager)
    func playerCurrentTimeDidChange(_ player: AudioManager)
    func playerPlaybackDidEnd(_ player: AudioManager)
    func playerDidFinishDownloading(_ player: AudioManager)
    func playerDownloadProgressDidChange(_ player: AudioManager)
    func playerIsBuffering(_ player: AudioManager)
    func playerIsLikelyToKeepUp(_ player: AudioManager)
    func playerBufferTimeDidChange(_ bufferValue: Float)
    
//    func playerBufferingStateDidChange( player: AudioManager)
    
    // This is the time in seconds that the video has been buffered.
    // If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
//    func playerBufferTimeDidChange( bufferTime: Double)
}

public class AudioManager: NSObject {
    /// Player delegate.
    open weak var playerDelegate: AudioManagerDelegate?
    
    fileprivate let seekDuration: Float64 = 30
    
    internal var task: Task!
    internal var avPlayer: AVPlayer?
    internal var playerItem: AVPlayerItem?
    internal var timeObserver: Any?
    internal var startTime: Double = 0
    internal var keyObserversSet = false
    
    open var playbackState: PlaybackState = .stopped {
        didSet {
                self.playerDelegate?.playerPlaybackStateDidChange(self)
                handleStateChange()
        }
    }

    fileprivate func handleStateChange() {
        switch playbackState {
        case .setup(let url, let currentTime):
            self.task?.cancel()
            
            guard let url = url else { return }
            let avAsset = AVURLAsset(url: url)
            let avPlayerItem = AVPlayerItem(asset: avAsset)
            
            avPlayer = AVPlayer(playerItem: avPlayerItem)
            
            if let time = currentTime {
                self.startTime = time
            }
            
            self.setupPlayerItem(avPlayerItem)
            self.playbackState = .buffering
            
            // Setup observer
            self.addPlayerObservers()
        case .stopped:
            log.info("stopped")
            
            // Stop Audio
            self.avPlayer?.pause()
            // Cancel any downloads

            // Remove observers
            self.removePlayerObservers()
        case .willDownload(let audioURL, let fileName):
            log.info("will download")
            
            self.avPlayer?.pause()
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
            case .finished(let url, let currentTime):
//                self.playbackState = .playing(url: url, currentTime: currentTime)
                self.playerDelegate?.playerDidFinishDownloading(self)
            }
        case .playing:
            log.info("playing")
            self.setupSession()
            self.setupMediaPlayerControls()
            
            avPlayer?.play()
        case .paused:
            // Pause Timer
            log.info("paused")
            
            self.avPlayer?.pause()
        case .failed:
            // Remove observers
            self.removePlayerObservers()
            log.info("failed")
            //@TODO: Setup some failure errors
        case .buffering:
            log.info("buffering")
            
            self.playerDelegate?.playerIsBuffering(self)
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
        guard let duration  = avPlayer?.currentItem?.duration else{
            return
        }
        guard let playerCurrentTime = avPlayer?.currentTime().seconds else { return }
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < (CMTimeGetSeconds(duration) - seekDuration) {
            
            let time2: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
            avPlayer?.seek(to: time2, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            
        }
    }
    
    func skipBackward() {
        guard let playerCurrentTime = avPlayer?.currentTime().seconds else { return }
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        let time2: CMTime = CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
        avPlayer?.seek(to: time2, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func updateCurrentTime() {
        self.playerDelegate?.playerCurrentTimeDidChange(self)
    }
    
    public func willDownload(from url: URL, fileName: String) {
        self.playbackState = .willDownload(from: url, fileName: fileName)
    }
    
    public func setupAudio(url: URL? = nil, currentTime: Double? = 0) {
        self.playbackState = .setup(url: url, currentTime: currentTime)
    }
    
    public func play() {
        self.playbackState = .playing
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
    
    public func getCurrentTime() -> Double? {
        guard let currentTime = avPlayer?.currentItem?.currentTime().seconds else { return nil }
        guard !currentTime.isNaN else { return nil }
        return currentTime
    }
    
    public func getDuration() -> Double? {
        guard let duration = avPlayer?.currentItem?.duration.seconds else { return nil }
        guard !duration.isNaN else { return nil }
        return duration
    }
    
    open func seek(to time: CMTime) {
        if let playerItem = self.playerItem {
            return playerItem.seek(to: time)
        } else {
            startTime = time.seconds
        }
    }
}

extension Double {
    func getCMTime() -> CMTime {
        let currentTime = CMTimeMake(Int64((self) * 1000 as Float64), 1000)
        return currentTime
    }
}

// MARK: - KVO

// KVO contexts

private var PlayerObserverContext = 0
private var PlayerItemObserverContext = 0
private var PlayerLayerObserverContext = 0

// KVO player keys

private let PlayerTracksKey = "tracks"
private let PlayerPlayableKey = "playable"
private let PlayerDurationKey = "duration"
private let PlayerRateKey = "rate"

// KVO player item keys

private let PlayerStatusKey = "status"
private let PlayerEmptyBufferKey = "playbackBufferEmpty"
private let PlayerKeepUpKey = "playbackLikelyToKeepUp"
private let PlayerLoadedTimeRangesKey = "loadedTimeRanges"

// KVO player layer keys

private let PlayerReadyForDisplayKey = "readyForDisplay"

extension AudioManager {

    // MARK: - AVPlayerObservers
    
    internal func addPlayerObservers() {
        self.timeObserver = self.avPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(1,1), queue: DispatchQueue.main, using: { [weak self] timeInterval in

            self?.updateCurrentTime()
        })
        self.avPlayer?.addObserver(self, forKeyPath: PlayerRateKey, options: ([.new, .old]) , context: &PlayerObserverContext)
    }
    
    internal func removePlayerObservers() {
        if let observer = self.timeObserver {
            self.avPlayer?.removeTimeObserver(observer)
        }
        self.avPlayer?.removeObserver(self, forKeyPath: PlayerRateKey, context: &PlayerObserverContext)
    }
    
    // MARK: - Observe Value
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // PlayerRateKey, PlayerObserverContext
        //@TODO: check if buffering for too long
        // If so, restart stream
        if (context == &PlayerItemObserverContext) {
            
            // PlayerStatusKey
            
            if keyPath == PlayerKeepUpKey {
                
                // PlayerKeepUpKey
                
//                if let item = self.playerItem {
                    if (self.avPlayer?.currentItem?.isPlaybackLikelyToKeepUp)! {
                        if playbackState.description != PlaybackState.playing.description {
                            self.playerDelegate?.playerIsLikelyToKeepUp(self)
                            self.playbackState = .playing
                        }
                    }
//                }
                
//                if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
//                    switch (status.intValue as AVPlayerStatus.RawValue) {
//                    case AVPlayerStatus.readyToPlay.rawValue:
//                        self._playerView.playerLayer.player = self._avplayer
//                        self._playerView.playerLayer.isHidden = false
//                        break
//                    case AVPlayerStatus.failed.rawValue:
//                        self.playbackState = PlaybackState.failed
//                        break
//                    default:
//                        break
//                    }
//                }
                
            } else if keyPath == PlayerEmptyBufferKey {
                
                // PlayerEmptyBufferKey
                
//                if let item = self.playerItem {
//                    if item.isPlaybackBufferEmpty {
//                        self.bufferingState = .delayed
//                    }
//                }
                log.info(PlayerEmptyBufferKey)
                log.info(playerItem?.isPlaybackBufferEmpty)
                
                if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    switch (status.intValue as AVPlayerStatus.RawValue) {
                    case AVPlayerStatus.readyToPlay.rawValue:
//                        self._playerView.playerLayer.player = self._avplayer
//                        self._playerView.playerLayer.isHidden = false
                        break
                    case AVPlayerStatus.failed.rawValue:
                        self.playbackState = PlaybackState.failed
                        break
                    default:
                        break
                    }
                }
                
            } else if keyPath == PlayerLoadedTimeRangesKey {
                
                // PlayerLoadedTimeRangesKey
                if let item = self.playerItem {
//                    self.bufferingState = .ready
                    
                    let timeRanges = item.loadedTimeRanges
                    if let timeRange = timeRanges.first?.timeRangeValue {
                        let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//                        self.executeClosureOnMainQueueIfNecessary {
                            self.playerDelegate?.playerBufferTimeDidChange(Float(bufferedTime))
                        
//                        }
//                        let currentTime = CMTimeGetSeconds(item.currentTime())
//                        if (bufferedTime - currentTime) >= self.bufferSize && self.playbackState == .playing {
//                            self.playFromCurrentTime()
//                        }
                    } else {
//                        self.playFromCurrentTime()
                    }
                }
                
            }
            
        } else if (context == &PlayerLayerObserverContext) {
//            if self._playerView.playerLayer.isReadyForDisplay {
//                self.executeClosureOnMainQueueIfNecessary {
//                    self.playerDelegate?.playerReady(self)
//                }
//            }
        }
        
    }
    
//    func availableDuration(playerItem: AVPlayerItem) -> TimeInterval {
//        let loadedTimeRanges: [Any]? = playerItem.loadedTimeRanges
//        
//        let timeRange = loadedTimeRanges?[0] as? CMTimeRange ?? CMTimeRange().timeRangeValue
//        let startSeconds: Float64 = CMTimeGetSeconds(timeRange.start())
//        let durationSeconds: Float64 = CMTimeGetSeconds(timeRange.duration)
//        let result: TimeInterval = startSeconds + durationSeconds
//        return result
//    }
}

extension AudioManager {
    fileprivate func setupPlayerItem(_ playerItem: AVPlayerItem?) {
        if keyObserversSet {
            self.playerItem?.removeObserver(self, forKeyPath: PlayerEmptyBufferKey, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerKeepUpKey, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerStatusKey, context: &PlayerItemObserverContext)
            self.playerItem?.removeObserver(self, forKeyPath: PlayerLoadedTimeRangesKey, context: &PlayerItemObserverContext)
            self.keyObserversSet = false
        }
        
        if let currentPlayerItem = self.playerItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: currentPlayerItem)
        }
        
        self.playerItem = playerItem

        if startTime != 0 {
            self.seek(to: startTime.getCMTime())
        }
        
        self.playerItem?.addObserver(self, forKeyPath: PlayerEmptyBufferKey, options: ([.new, .old]), context: &PlayerItemObserverContext)
        self.playerItem?.addObserver(self, forKeyPath: PlayerKeepUpKey, options: ([.new, .old]), context: &PlayerItemObserverContext)
        self.playerItem?.addObserver(self, forKeyPath: PlayerStatusKey, options: ([.new, .old]), context: &PlayerItemObserverContext)
        self.playerItem?.addObserver(self, forKeyPath: PlayerLoadedTimeRangesKey, options: ([.new, .old]), context: &PlayerItemObserverContext)
        self.keyObserversSet = true
        
        if let updatedPlayerItem = self.playerItem {
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: updatedPlayerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: updatedPlayerItem)
        }
        
        self.avPlayer?.replaceCurrentItem(with: self.playerItem)
    }
    
    internal func playerItemDidPlayToEndTime(_ aNotification: Notification) {
        self.playbackState = .stopped
        self.playerDelegate?.playerPlaybackDidEnd(self)
    }
    
    internal func playerItemFailedToPlayToEndTime(_ aNotification: Notification) {
        self.playbackState = .failed
    }
}
