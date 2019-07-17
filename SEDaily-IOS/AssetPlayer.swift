//
//  AssetPlayer.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 9/26/17.
//
import Foundation
import AVFoundation
import MediaPlayer

public protocol AssetPlayerDelegate: NSObjectProtocol {
  // Setuo
  func currentAssetDidChange(_ player: AssetPlayer)
  func playerIsSetup(_ player: AssetPlayer)
  
  // Playback
  func playerPlaybackStateDidChange(_ player: AssetPlayer)
  func playerCurrentTimeDidChange(_ player: AssetPlayer)
  func playerPlaybackDidEnd(_ player: AssetPlayer)
  
  // Buffering
  func playerIsLikelyToKeepUp(_ player: AssetPlayer)
  // This is the time in seconds that the video has been buffered.
  // If implementing a UIProgressView, user this value / player.maximumDuration to set progress.
  func playerBufferTimeDidChange(_ player: AssetPlayer)
}

public enum AssetPlayerPlaybackState: Equatable {
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// Equality is the inverse of inequality. For any values `a` and `b`,
  /// `a == b` implies that `a != b` is `false`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  public static func ==(lhs: AssetPlayerPlaybackState, rhs: AssetPlayerPlaybackState) -> Bool {
    switch (lhs, rhs) {
    case (.setup(let lKey), .setup(let rKey)):
      return lKey == rKey
    case (.playing, .playing):
      return true
    case (.paused, .paused):
      return true
    case (.interrupted, .interrupted):
      return true
    case (.failed, .failed):
      return true
    case (.buffering, .buffering):
      return true
    case (.stopped, .stopped):
      return true
    default:
      return false
    }
  }
  
  case setup(asset: Asset?)
  case playing, paused, interrupted, failed, buffering, stopped
}

/*
 KVO context used to differentiate KVO callbacks for this class versus other
 classes in its class hierarchy.
 */
private var AssetPlayerKVOContext = 0

public class AssetPlayer: NSObject {
  // MARK: Properties
  /// Player delegate.
  public weak var playerDelegate: AssetPlayerDelegate?
  
  // Attempt load and test these asset keys before playing.
  static let assetKeysRequiredToPlay = [
    "playable",
    "hasProtectedContent"
  ]
  
  @objc let player = AVPlayer()
  
  public var isPlayingLocalVideo = false
  public var startTimeForLoop: Double = 0
  
  // Mark: Time Properties
  public var currentTime: Double = 0 {
    didSet {
      //@TODO: may not need playback did end here
      guard currentTime < duration else {
        self.playerDelegate?.playerPlaybackDidEnd(self)
        return
      }
      self.playerDelegate?.playerCurrentTimeDidChange(self)
    }
  }
  public var bufferedTime: Float = 0 {
    didSet {
      self.playerDelegate?.playerBufferTimeDidChange(self)
    }
  }
  
  public var timeElapsedText: String = ""
  public var durationText: String = ""
  
  public var timeLeftText: String {
    get {
      let timeLeft = duration - currentTime
      return self.createTimeString(time: Float(timeLeft))
    }
  }
  
  public var maxSecondValue: Float = 0
  
  public var duration: Double {
    guard let currentItem = player.currentItem else { return 0.0 }
    
    return CMTimeGetSeconds(currentItem.duration)
  }
  
  public var rate: Float = 1.0 {
    willSet {
      guard newValue != self.rate else { return }
    }
    didSet {
      player.rate = rate
      self.checkAudioRateAndSetTimePitchAlgorithm()
    }
  }
  
  public var shouldLoop: Bool = false
  
  private var currentAVAudioTimePitchAlgorithm: AVAudioTimePitchAlgorithm = .timeDomain {
    willSet {
      guard newValue != self.currentAVAudioTimePitchAlgorithm else { return }
    }
    didSet {
      self.playerItem?.audioTimePitchAlgorithm = self.currentAVAudioTimePitchAlgorithm
    }
  }
  
  private func checkAudioRateAndSetTimePitchAlgorithm() {
    guard self.rate <= 2.0 else {
      self.currentAVAudioTimePitchAlgorithm = .spectral
      return
    }
    self.currentAVAudioTimePitchAlgorithm = .timeDomain
  }
  
  public var asset: Asset? {
    didSet {
      guard let newAsset = self.asset else { return }
      
      asynchronouslyLoadURLAsset(newAsset)
    }
  }
  
  private var playerLayer: AVPlayerLayer? {
    return playerView?.playerLayer
  }
  
  /*
   A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)`
   method.
   */
  private var timeObserverToken: Any?
  
  // @TODO: Do we need to remove observers
  public var playerItem: AVPlayerItem? = nil {
    willSet {
      if playerItem != nil {
        self.removePlayerItemObservers()
      }
    }
    didSet {
      if playerItem != nil {
        self.addPlayerItemObservers()
      }
      /*
       If needed, configure player item here before associating it with a player.
       (example: adding outputs, setting text style rules, selecting media options)
       */
      player.replaceCurrentItem(with: self.playerItem)
    }
  }
  
  public var playerView: PlayerView? = PlayerView(frame: .zero)
  
  /// The instance of `MPNowPlayingInfoCenter` that is used for updating metadata for the currently playing `Asset`.
  fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
  
  /// A Bool for tracking if playback should be resumed after an interruption.  See README.md for more information.
  fileprivate var shouldResumePlaybackAfterInterruption = true
  
  // The state that the internal `AVPlayer` is in.
  public var state: AssetPlayerPlaybackState? = nil {
    didSet {
      if state != oldValue {
        self.playerDelegate?.playerPlaybackStateDidChange(self)
        self.handleStateChange()
      }
    }
  }
  
  func handleStateChange() {
    guard let state = self.state else { return }
    switch state {
    case .setup(let asset):
      self.setupAVAudioSession()
      self.asset = asset
      break
    case .playing:
      guard self.asset != nil else { return }
      
      //            if shouldResumePlaybackAfterInterruption == false {
      //                shouldResumePlaybackAfterInterruption = true
      //                return
      //            }
      //
      //@TODO: Check if there are any issues with "playImmediately"
      if #available(iOS 10.0, *) {
        player.playImmediately(atRate: self.rate)
      } else {
        // Fallback on earlier versions
        player.play()
        player.rate = self.rate
      }
      //            self.player.play()
      break
    case .paused:
      guard asset != nil else { return }
      
      if state == .interrupted {
        //                shouldResumePlaybackAfterInterruption = false
        return
      }
      
      self.player.pause()
      break
    case .interrupted:
      break
    case .failed:
      break
    case .buffering:
      guard asset != nil else { return }
      self.player.pause()
      break
    case .stopped:
      guard asset != nil else { return }
      
      if shouldLoop {
        self.seekTo(interval: startTimeForLoop)
        self.play()
        return
      }
      
      asset = nil
      playerItem = nil
      self.player.replaceCurrentItem(with: nil)
      // @TODO: just deinit?
      break
    }
  }
  
  // Method to set state so this can be called in init
  public func setState(to state: AssetPlayerPlaybackState) {
    self.state = state
  }
  
  // MARK: - Life Cycle
  public init(asset: Asset?) {
    super.init()
    
    /*
     Update the UI when these player properties change.
     Use the context parameter to distinguish KVO for our particular observers
     and not those destined for a subclass that also happens to be observing
     these properties.
     */
    addObserver(self, forKeyPath: #keyPath(AssetPlayer.player.currentItem.duration), options: [.new, .initial], context: &AssetPlayerKVOContext)
    addObserver(self, forKeyPath: #keyPath(AssetPlayer.player.rate), options: [.new, .initial], context: &AssetPlayerKVOContext)
    addObserver(self, forKeyPath: #keyPath(AssetPlayer.player.currentItem.status), options: [.new, .initial], context: &AssetPlayerKVOContext)
    
    playerView?.playerLayer.player = player
    
    self.setState(to: .setup(asset: asset))
    
    // Make sure we don't have a strong reference cycle by only capturing self as weak.
    let interval = CMTimeMake(1, 1)
    timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
      let timeElapsed = Float(CMTimeGetSeconds(time))
      
      self.currentTime = Double(timeElapsed)
      self.timeElapsedText = self.createTimeString(time: timeElapsed)
    }
  }
  
  deinit {
    print("DEINITING")
    if let timeObserverToken = timeObserverToken {
      player.removeTimeObserver(timeObserverToken)
      self.timeObserverToken = nil
    }
    
    player.pause()
    
    removeObserver(self, forKeyPath: #keyPath(AssetPlayer.player.currentItem.duration), context: &AssetPlayerKVOContext)
    removeObserver(self, forKeyPath: #keyPath(AssetPlayer.player.rate), context: &AssetPlayerKVOContext)
    removeObserver(self, forKeyPath: #keyPath(AssetPlayer.player.currentItem.status), context: &AssetPlayerKVOContext)
    
    self.removeAVAudioSessionObservers()
    //@TODO: Simplify removing observers
    if playerItem != nil {
      self.removePlayerItemObservers()
    }
  }
  
  // MARK: - Asset Loading
  func asynchronouslyLoadURLAsset(_ newAsset: Asset) {
    /*
     Using AVAsset now runs the risk of blocking the current thread (the
     main UI thread) whilst I/O happens to populate the properties. It's
     prudent to defer our work until the properties we need have been loaded.
     */
    newAsset.urlAsset.loadValuesAsynchronously(forKeys: AssetPlayer.assetKeysRequiredToPlay) {
      /*
       The asset invokes its completion handler on an arbitrary queue.
       To avoid multiple threads using our internal state at the same time
       we'll elect to use the main thread at all times, let's dispatch
       our handler to the main queue.
       */
      DispatchQueue.main.async {
        /*
         `self.asset` has already changed! No point continuing because
         another `newAsset` will come along in a moment.
         */
        guard newAsset == self.asset else { return }
        
        /*
         Test whether the values of each of the keys we need have been
         successfully loaded.
         */
        for key in AssetPlayer.assetKeysRequiredToPlay {
          var error: NSError?
          
          if newAsset.urlAsset.statusOfValue(forKey: key, error: &error) == .failed {
            let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
            
            let message = String.localizedStringWithFormat(stringFormat, key)
            
            self.handleErrorWithMessage(message, error: error)
            
            return
          }
        }
        
        // We can't play this asset.
        if !newAsset.urlAsset.isPlayable || newAsset.urlAsset.hasProtectedContent {
          let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
          
          self.handleErrorWithMessage(message)
          
          return
        }
        
        /*
         We can play this asset. Create a new `AVPlayerItem` and make
         it our player's current item.
         */
        self.playerItem = AVPlayerItem(asset: newAsset.urlAsset)
        // Set time pitch algorithm to spectral allows the audio to speed up to 3.0
        if newAsset.savedTime != 0 {
          self.seekTo(newAsset.savedCMTime)
        }
        
        self.playerDelegate?.currentAssetDidChange(self)
      }
    }
  }
  
  // MARK: - KVO Observation
  // Update our UI when player or `player.currentItem` changes.
  override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    // Make sure the this KVO callback was intended for this view controller.
    guard context == &AssetPlayerKVOContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }
    
    if keyPath == #keyPath(AssetPlayer.player.currentItem.duration) {
      // Update timeSlider and enable/disable controls when duration > 0.0
      /*
       Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
       `player.currentItem` is nil.
       */
      let newDuration: CMTime
      if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
        newDuration = newDurationAsValue.timeValue
      }
      else {
        newDuration = kCMTimeZero
      }
      
      let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
      let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
      let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
      
      self.maxSecondValue = Float(newDurationSeconds)
      self.timeElapsedText = createTimeString(time: currentTime)
      self.durationText = createTimeString(time: Float(newDurationSeconds))
      
      self.playerDelegate?.playerIsSetup(self)
      self.updateGeneralMetadata()
    }
    else if keyPath == #keyPath(AssetPlayer.player.rate) {
      // Update `playPauseButton` image.
      //            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
      //
      //            let buttonImageName = newRate == 1.0 ? "PauseButton" : "PlayButton"
      //
      //            let buttonImage = UIImage(named: buttonImageName)
      //
      //            playPauseButton.setImage(buttonImage, for: UIControlState())
      // @TODO: What to do with player rate?
      // Update Metadata
      // @TODO: How many times here?
      self.updatePlaybackRateMetadata()
    }
    else if keyPath == #keyPath(AssetPlayer.player.currentItem.status) {
      // Display an error if status becomes `.Failed`.
      /*
       Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
       `player.currentItem` is nil.
       */
      let newStatus: AVPlayerItemStatus
      
      if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
        newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
      }
      else {
        newStatus = .unknown
      }
      
      if newStatus == .failed {
        handleErrorWithMessage(player.currentItem?.error?.localizedDescription, error:player.currentItem?.error)
      }
    }
      // All Buffer observer values
    else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
      // PlayerEmptyBufferKey
      if let item = self.playerItem {
        if item.isPlaybackBufferEmpty {
          guard state != .paused else { return }
          
          // No need to set buffering if we're playing locally
          guard !isPlayingLocalVideo else { return }
          self.state = .buffering
        }
      }
    }
    else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
      // PlayerKeepUpKey
      if let item = self.playerItem {
        if item.isPlaybackLikelyToKeepUp {
          if self.state == .buffering || self.state == .playing {
            //@TODO: Check if this guard is breaking the rest of this section
            guard state != .paused else { return }
            self.playerDelegate?.playerIsLikelyToKeepUp(self)
            self.state = .playing
            return
          }
        }
      }
    }
    else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
      //@TODO: This gets checked a lot
      // PlayerLoadedTimeRangesKey
      if let item = self.playerItem {
        let timeRanges = item.loadedTimeRanges
        if let timeRange = timeRanges.first?.timeRangeValue {
          let bufferedTime: Float = Float(CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)))
          // Smart Value check for buffered time to switch to playing state
          // or switch to buffering state
          let smartValue = (bufferedTime - Float(self.currentTime)) > 5 || bufferedTime.rounded() == Float(self.currentTime.rounded())
          //@TODO: Clean this up
          switch smartValue {
          case true:
            if self.state != .buffering, self.state != .paused, self.state != .playing {
              self.state = .playing
            }
            break
          case false:
            if self.state != .buffering && self.state != .paused {
              // No need to set buffering if we're playing locally
              guard !isPlayingLocalVideo else { return }
              self.state = .buffering
            }
            break
          }
          self.bufferedTime = Float(bufferedTime)
        } else {
          //                        self.playFromCurrentTime()
        }
      }
    }
  }
  
  // Trigger KVO for anyone observing our properties affected by player and player.currentItem
  override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
    let affectedKeyPathsMappingByKey: [String: Set<String>] = [
      "duration":     [#keyPath(AssetPlayer.player.currentItem.duration)],
      "rate":         [#keyPath(AssetPlayer.player.rate)]
    ]
    
    return affectedKeyPathsMappingByKey[key] ?? super.keyPathsForValuesAffectingValue(forKey: key)
  }
  
  // MARK: Notification Observing Methods
  @objc func handleAVPlayerItemDidPlayToEndTimeNotification(notification: Notification) {
    self.playerDelegate?.playerPlaybackDidEnd(self)
    self.state = .stopped
  }
  
  // MARK: - Error Handling
  func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
    NSLog("Error occured with message: \(String(describing: message)), error: \(String(describing: error)).")
    
    let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
    let defaultAlertMessage = NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")
    
    let alert = UIAlertController(title: alertTitle, message: message == nil ? defaultAlertMessage : message, preferredStyle: UIAlertControllerStyle.alert)
    
    let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")
    
    let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
    
    alert.addAction(alertAction)
    
    //        present(alert, animated: true, completion: nil)
  }
  
  // MARK: Convenience
  /*
   A formatter for individual date components used to provide an appropriate
   value for the `startTimeLabel` and `durationLabel`.
   */
  let timeRemainingFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.minute, .second]
    
    return formatter
  }()
  
  func createTimeString(time: Float) -> String {
    let components = NSDateComponents()
    components.second = Int(max(0.0, time))
    
    return timeRemainingFormatter.string(from: components as DateComponents)!
  }
}

// MARK: Playback Control Methods.
extension AssetPlayer {
  public func play() {
    self.state = .playing
  }
  
  public func pause() {
    self.state = .paused
  }
  
  public func togglePlayPause() {
    guard asset != nil else { return }
    
    if self.player.rate != 1.0 {
      // Not playing forward, so play.
      self.state = .playing
    }
    else {
      // Playing, so pause.
      self.state = .paused
    }
  }
  
  public func stop() {
    self.state = .stopped
  }
  
  //@TODO: Do we need other notifications for RemoteCommand
  /// Notification that is posted when the `nextTrack()` is called.
  fileprivate static let nextTrackNotification = Notification.Name("nextTrackNotification")
  
  /// Notification that is posted when the `previousTrack()` is called.
  fileprivate static let previousTrackNotification = Notification.Name("previousTrackNotification")
  
  func nextTrack() {
    guard asset != nil else { return }
    
    NotificationCenter.default.post(name: AssetPlayer.nextTrackNotification, object: nil, userInfo: [Asset.nameKey: asset?.assetName ?? ""])
  }
  
  func previousTrack() {
    guard asset != nil else { return }
    
    NotificationCenter.default.post(name: AssetPlayer.previousTrackNotification, object: nil, userInfo: [Asset.nameKey: asset?.assetName ?? ""])
  }
  
  public func skipForward(_ interval: TimeInterval) {
    guard asset != nil else { return }
    
    let currentTime = self.player.currentTime()
    let offset = CMTimeMakeWithSeconds(interval, 1)
    
    let newTime = CMTimeAdd(currentTime, offset)
    self.seekTo(newTime)
  }
  
  public func skipBackward(_ interval: TimeInterval) {
    guard asset != nil else { return }
    
    let currentTime = self.player.currentTime()
    let offset = CMTimeMakeWithSeconds(interval, 1)
    
    let newTime = CMTimeSubtract(currentTime, offset)
    self.seekTo(newTime)
  }
  
  public func seekTo(_ newPosition: CMTime) {
    guard asset != nil else { return }
    self.player.seek(to: newPosition, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
      self.updatePlaybackRateMetadata()
      //            self.checkPaused()
    })
  }
  
  public func seekTo(interval: TimeInterval) {
    guard asset != nil else { return }
    let newPosition = CMTimeMakeWithSeconds(interval, 600)
    self.player.seek(to: newPosition, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (_) in
      self.updatePlaybackRateMetadata()
      //            self.checkPaused()
    })
  }
  
  public func changePlayerPlaybackRate(to newRate: Float) {
    guard asset != nil else { return }
    
    DispatchQueue.main.async {
      self.rate = newRate
    }
  }
  
  public func beginRewind() {
    guard asset != nil else { return }
    
    rate = max(player.rate - 2.0, -2.0)
  }
  
  public func beginFastForward() {
    guard asset != nil else { return }
    
    rate = min(player.rate + 2.0, 2.0)
  }
  
  public func endRewindFastForward() {
    guard asset != nil else { return }
    
    rate = 1.0
  }
}

extension AssetPlayer {
  // Player buffer observers
  internal func addPlayerItemObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleAVPlayerItemDidPlayToEndTimeNotification(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: ([.new, .old]), context: &AssetPlayerKVOContext)
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: ([.new, .old]), context: &AssetPlayerKVOContext)
    playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: ([.new, .old]), context: &AssetPlayerKVOContext)
  }
  
  internal func removePlayerItemObservers() {
    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    
    playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), context: &AssetPlayerKVOContext)
    playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), context: &AssetPlayerKVOContext)
    playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: &AssetPlayerKVOContext)
  }
}

// MARK: MPNowPlayingInforCenter Management Methods
extension AssetPlayer {
  func updateGeneralMetadata() {
    guard self.player.currentItem != nil, let urlAsset = self.player.currentItem?.asset else {
      nowPlayingInfoCenter.nowPlayingInfo = nil
      
      return
    }
    
    var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
    
    let title = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: AVMetadataKeySpace.common).first?.value as? String ?? asset?.assetName
    let album = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataKey.commonKeyAlbumName, keySpace: AVMetadataKeySpace.common).first?.value as? String ?? ""
    var artworkData = AVMetadataItem.metadataItems(from: urlAsset.commonMetadata, withKey: AVMetadataKey.commonKeyArtwork, keySpace: AVMetadataKeySpace.common).first?.value as? Data ?? Data()
    if let url = asset?.artworkURL {
      if let data = try? Data(contentsOf: url) {
        artworkData = data
      }
    }
    
    let image = UIImage(data: artworkData) ?? UIImage()
    var artwork = MPMediaItemArtwork(image: image)
    if #available(iOS 10.0, *) {
      artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
        return image
      })
    }
    
    nowPlayingInfo[MPMediaItemPropertyTitle] = title
    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
    
    nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
  }
  
  func updatePlaybackRateMetadata() {
    guard self.player.currentItem != nil else {
      nowPlayingInfoCenter.nowPlayingInfo = nil
      
      return
    }
    
    var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentItem!.currentTime())
    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
    nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = self.player.rate
    
    nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
  }
}

// MARK: - AudioSession
extension AssetPlayer {
  @objc func handleAudioSessionInterruption(notification: Notification) {
    guard let userInfo = notification.userInfo, let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
      let interruptionType = AVAudioSessionInterruptionType(rawValue: typeInt) else { return }
    
    switch interruptionType {
    case .began:
      self.state = .interrupted
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
  
  func setupAVAudioSession() {
    // Setup AVAudioSession to indicate to the system you how intend to play audio.
    let audioSession = AVAudioSession.sharedInstance()
    
    self.addAVAudioSessionObservers()
    
    do {
      if #available(iOS 10.0, *) {
        try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
      } else {
        // Fallback on earlier versions
        try audioSession.setCategory(AVAudioSessionCategoryPlayback)
      }
    }
    catch {
      print("An error occured setting the audio session category: \(error)")
    }
    
    // Set the AVAudioSession as active.  This is required so that your application becomes the "Now Playing" app.
    do {
      try audioSession.setActive(true)
    }
    catch {
      print("An Error occured activating the audio session: \(error)")
    }
  }
  
  func addAVAudioSessionObservers() {
    // Add the notification observer needed to respond to audio interruptions.
    NotificationCenter.default.addObserver(self, selector: #selector(self.handleAudioSessionInterruption(notification:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
  }
  
  func removeAVAudioSessionObservers() {
    // Remove audio session interruption observer
    NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
  }
}
