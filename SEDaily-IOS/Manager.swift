//
//  Manager.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 7/22/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import AVFoundation
import MediaPlayer

// MARK: - PlayerDelegate

/// Player delegate protocol
public protocol ManagerDelegate: NSObjectProtocol {
    func currentAssetDidChange(_ player: Manager)
    func playerReady(_ player: Manager)
    func playerPlaybackStateDidChange(_ player: Manager)
    func playerCurrentTimeDidChange(_ player: Manager)
    func playerPlaybackDidEnd(_ player: Manager)
    func playerDidFinishDownloading(_ player: Manager)
    func playerDownloadProgressDidChange(_ player: Manager)
    func playerIsBuffering(_ player: Manager)
    func playerIsLikelyToKeepUp(_ player: Manager)
    func playerBufferTimeDidChange(_ bufferValue: Float)
    
//    func playerBufferingStateDidChange( player: AudioManager)
    
    // This is the time in seconds that the video has been buffered.
    // If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
    //    func playerBufferTimeDidChange( bufferTime: Double)
}

public class Manager: NSObject {
    /// Player delegate.
    open weak var playerDelegate: ManagerDelegate?
    
    // MARK: Types
    
    /// Notification that is posted when the `nextTrack()` is called.
    static let nextTrackNotification = Notification.Name("nextTrackNotification")
    
    /// Notification that is posted when the `previousTrack()` is called.
    static let previousTrackNotification = Notification.Name("previousTrackNotification")
    
    /// An enumeration of possible playback states that `AssetPlaybackManager` can be in.
    ///
    /// - initial: The playback state that `AssetPlaybackManager` starts in when nothing is playing.
    /// - playing: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` != 0.
    /// - paused: The playback state that `AssetPlaybackManager` is in when its `AVPlayer` has a `rate` == 0.
    /// - interrupted: The playback state that `AssetPlaybackManager` is in when audio is interrupted.
    enum playbackState {
        case initial, playing, paused, interrupted, failed, buffering, stopped
    }
    
    /// Notification that is posted when currently playing `Asset` did change.
    static let currentAssetDidChangeNotification = Notification.Name("currentAssetDidChangeNotification")
    
    /// Notification that is posted when the internal AVPlayer rate did change.
    static let playerRateDidChangeNotification = Notification.Name("playerRateDidChangeNotification")
    
    // MARK: Properties
    
    /// The instance of AVPlayer that will be used for playback of AssetPlaybackManager.playerItem.
    let player = AVPlayer()
    
    /// The instance of `MPNowPlayingInfoCenter` that is used for updating metadata for the currently playing `Asset`.
    fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    /// A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)` method.
    private var timeObserverToken: Any?
    
    /// The progress in percent for the playback of `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    dynamic var percentProgress: Float = 0
    
    /// The total duration in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    dynamic var duration: Float = 0
    
    /// The current playback position in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    dynamic var playbackPosition: Float = 0
    //@TODO: see about setting this state on init
    /// The state that the internal `AVPlayer` is in.
    var state: Manager.playbackState = .initial {
        didSet {
            self.playerDelegate?.playerPlaybackStateDidChange(self)
//            handleStateChange()
        }
    }
    
    /// A Bool for tracking if playback should be resumed after an interruption.  See README.md for more information.
    private var shouldResumePlaybackAfterInterruption = true
    
    /// The AVPlayerItem associated with AssetPlaybackManager.asset.urlAsset
    fileprivate var playerItem: AVPlayerItem! {
        willSet {
            if playerItem != nil {
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), context: nil)
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), context: nil)
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: nil)
            }
        }
        didSet {
            if playerItem != nil {
                playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.initial, .new], context: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(AssetPlaybackManager.handleAVPlayerItemDidPlayToEndTimeNotification(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                
                playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: ([.new, .old]), context: nil)
                playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: ([.new, .old]), context: nil)
                playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: ([.new, .old]), context: nil)
            }
        }
    }
    
    /// The Asset that is currently being loaded for playback.
    var asset: Asset! {
        willSet {
            self.state = .initial
            self.player.pause()
            if asset != nil {
                asset.urlAsset.removeObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), context: nil)
            }
        }
        didSet {
            if asset != nil {
                asset.urlAsset.addObserver(self, forKeyPath: #keyPath(AVURLAsset.isPlayable), options: [.initial, .new], context: nil)
            }
            else {
                // Unload currentItem so that the state is updated globally.
                player.replaceCurrentItem(with: nil)
            }
            playerDelegate?.currentAssetDidChange(self)
        }
    }
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        #if os(iOS)
            // Add the notification observer needed to respond to audio interruptions.
            NotificationCenter.default.addObserver(self, selector: #selector(AssetPlaybackManager.handleAudioSessionInterruption(notification:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        #endif
        
        // Add the Key-Value Observers needed to keep internal state of `AssetPlaybackManager` and `MPNowPlayingInfoCenter` in sync.
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.initial, .new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: nil)
        
        // Add a periodic time observer to keep `percentProgress` and `playbackPosition` up to date.
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0 / 1.0, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] time in
            let timeElapsed = Float(CMTimeGetSeconds(time))
            guard let duration = self?.player.currentItem?.duration else { return }
            
            let durationInSecods = Float(CMTimeGetSeconds(duration))
            
            self?.playbackPosition = timeElapsed
            self?.percentProgress = timeElapsed / durationInSecods
            self?.playerDelegate?.playerCurrentTimeDidChange(self!)
        })
    }
    
    deinit {
        // Remove all KVO and notification observers.
        
        #if os(iOS)
            NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        #endif
        
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), context: nil)
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: nil)
        
        // Remove the periodic time observer.
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // MARK: Playback Control Methods.
    
    func play() {
        guard asset != nil else { return }
        
        if shouldResumePlaybackAfterInterruption == false {
            shouldResumePlaybackAfterInterruption = true
            
            return
        }
        
        player.play()
    }
    //@TODO: Set states
    func pause() {
        guard asset != nil else { return }
        
        if state == .interrupted {
            shouldResumePlaybackAfterInterruption = false
            
            return
        }
        
        player.pause()
    }
    
    func togglePlayPause() {
        guard asset != nil else { return }
        
        if player.rate == 1.0 {
            pause()
        }
        else {
            play()
        }
    }
    
    func stop() {
        guard asset != nil else { return }

        asset = nil
        playerItem = nil
        player.replaceCurrentItem(with: nil)
        
        self.state = .stopped
    }
    
    func nextTrack() {
        guard asset != nil else { return }
        
        NotificationCenter.default.post(name: AssetPlaybackManager.nextTrackNotification, object: nil, userInfo: [Asset.nameKey: asset.assetName])
    }
    
    func previousTrack() {
        guard asset != nil else { return }
        
        NotificationCenter.default.post(name: AssetPlaybackManager.previousTrackNotification, object: nil, userInfo: [Asset.nameKey: asset.assetName])
    }
    
    func skipForward(_ interval: TimeInterval) {
        guard asset != nil else { return }
        
        let currentTime = player.currentTime()
        let offset = CMTimeMakeWithSeconds(interval, 1)
        
        let newTime = CMTimeAdd(currentTime, offset)
        player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
            self.updatePlaybackRateMetadata()
        })
    }
    
    func skipBackward(_ interval: TimeInterval) {
        guard asset != nil else { return }
        
        let currentTime = player.currentTime()
        let offset = CMTimeMakeWithSeconds(interval, 1)
        
        let newTime = CMTimeSubtract(currentTime, offset)
        player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
            self.updatePlaybackRateMetadata()
        })
    }
    
    func seekTo(_ position: TimeInterval) {
        guard asset != nil else { return }
        
        let newPosition = CMTimeMakeWithSeconds(position, 1)
        player.seek(to: newPosition, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
            self.updatePlaybackRateMetadata()
        })
    }
    
    func beginRewind() {
        guard asset != nil else { return }
        
        player.rate = -2.0
    }
    
    func beginFastForward() {
        guard asset != nil else { return }
        
        player.rate = 2.0
    }
    
    func endRewindFastForward() {
        guard asset != nil else { return }
        
        player.rate = 1.0
    }
    
    // MARK: MPNowPlayingInforCenter Management Methods
    
    func updateGeneralMetadata() {
        guard player.currentItem != nil, let urlAsset = player.currentItem?.asset else {
            nowPlayingInfoCenter.nowPlayingInfo = nil
            
            #if os(macOS)
                nowPlayingInfoCenter.playbackState = .stopped
            #endif
            
            return
        }
        
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        let title = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataCommonKeyTitle, keySpace: AVMetadataKeySpaceCommon).first?.value as? String ?? asset.assetName
        let album = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataCommonKeyAlbumName, keySpace: AVMetadataKeySpaceCommon).first?.value as? String ?? ""
        let artworkData = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataCommonKeyArtwork, keySpace: AVMetadataKeySpaceCommon).first?.value as? Data ?? Data()
        
        
        #if os(macOS)
            let image = NSImage(data: artworkData) ?? NSImage()
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> NSImage in
                return image
            })
        #else
//            let image = UIImage(data: artworkData) ?? UIImage()
            let image = #imageLiteral(resourceName: "SEDaily_Logo")
            //@TODO: Fix this to accept custom artwork
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
                return image
            })
        #endif
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    // @TODO: Make a variable for custom image artwork
    
    func setCustomArtwork(image: UIImage?) {
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        let image = image ?? UIImage()
        let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
            return image
        })
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    func updatePlaybackRateMetadata() {
        guard player.currentItem != nil else {
            duration = 0
            nowPlayingInfoCenter.nowPlayingInfo = nil
            
            return
        }
        
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        duration = Float(CMTimeGetSeconds(player.currentItem!.duration))
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentItem!.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = player.rate
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo

        if player.rate == 0.0 {
            state = .paused
            
            #if os(macOS)
                nowPlayingInfoCenter.playbackState = .paused
            #endif
        }
        else {
            state = .playing
            
            #if os(macOS)
                nowPlayingInfoCenter.playbackState = .playing
            #endif
        }
        
    }
    
    // MARK: Notification Observing Methods
    
    func handleAVPlayerItemDidPlayToEndTimeNotification(notification: Notification) {
        player.replaceCurrentItem(with: nil)
    }
    
    #if os(iOS)
    
    func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let interruptionType = AVAudioSessionInterruptionType(rawValue: typeInt) else { return }
        
        switch interruptionType {
        case .began:
            state = .interrupted
        case .ended:
            do {
                try AVAudioSession.sharedInstance().setActive(true, with: [])
                
                if shouldResumePlaybackAfterInterruption == false {
                    shouldResumePlaybackAfterInterruption = true
                    
                    return
                }
                
                guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                
                let interruptionOptions = AVAudioSessionInterruptionOptions(rawValue: optionsInt)
                
                if interruptionOptions.contains(.shouldResume) {
                    play()
                }
            }
            catch {
                print("An Error occured activating the audio session while resuming from interruption: \(error)")
            }
        }
    }
    
    #endif
    
    // MARK: Key-Value Observing Method
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVURLAsset.isPlayable) {
            if asset.urlAsset.isPlayable {
                playerItem = AVPlayerItem(asset: asset.urlAsset)
                player.replaceCurrentItem(with: playerItem)
            }
        }
        else if keyPath == #keyPath(AVPlayerItem.status) {
            if playerItem.status == .readyToPlay {
                player.play()
            }
        }
        else if keyPath == #keyPath(AVPlayer.currentItem){
            
            // Cleanup if needed.
            if player.currentItem == nil {
                if asset != nil { asset = nil }
                if playerItem != nil { playerItem = nil }
            }
            
            updateGeneralMetadata()
        }
        else if keyPath == #keyPath(AVPlayer.rate) {
            updatePlaybackRateMetadata()

            self.playerDelegate?.playerCurrentTimeDidChange(self)
        }
            
        // All Buffer observer values
        else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
            // PlayerEmptyBufferKey
            if let item = self.playerItem {
                if item.isPlaybackBufferEmpty {
//                    self.bufferingState = .delayed
                    self.state = .buffering
                }
            }
            
            if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                switch (status.intValue as AVPlayerStatus.RawValue) {
                case AVPlayerStatus.readyToPlay.rawValue:
                    //                        self._playerView.playerLayer.player = self._avplayer
                    //                        self._playerView.playerLayer.isHidden = false
                    break
                case AVPlayerStatus.failed.rawValue:
                    self.state = .failed
                    break
                default:
                    break
                }
            }
        }
        else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
            // PlayerKeepUpKey
            if let item = self.playerItem {
                if item.isPlaybackLikelyToKeepUp {
                    if self.state == .buffering || self.state == .playing {
                        self.playerDelegate?.playerIsLikelyToKeepUp(self)
                        self.state = .playing
                        return
                    }
                }
            }
            
            if let status = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                switch (status.intValue as AVPlayerStatus.RawValue) {
                case AVPlayerStatus.readyToPlay.rawValue:
                    //                        self._playerView.playerLayer.player = self._avplayer
                    //                        self._playerView.playerLayer.isHidden = false
                    break
                case AVPlayerStatus.failed.rawValue:
                    self.state = .failed
                    break
                default:
                    break
                }
            }
        }
        else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            // PlayerLoadedTimeRangesKey
            
            if let item = self.playerItem {
//                    self.bufferingState = .ready
                
                let timeRanges = item.loadedTimeRanges
                if let timeRange = timeRanges.first?.timeRangeValue {
                    let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
//                        self.executeClosureOnMainQueueIfNecessary {
                    // AVPlayer waits till bufferedTime is 1000 before playing
                    // So we need to be in the buffered state for this time
                    switch bufferedTime <= 1000 {
                    case true:
                        if self.state != .buffering {
                            self.state = .buffering
                        }
                    case false:
                        if self.state != .playing {
                            self.state = .playing
                        }
                    }

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
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        log.debug(keyPath)
    }
}

