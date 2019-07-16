//
//  PlayerView.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 8/4/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//
import UIKit
import AVFoundation

import UIKit
import AVFoundation

/// A simple `UIView` subclass that is backed by an `AVPlayerLayer` layer.
public class PlayerView: UIView {
  public var player: AVPlayer? {
    get {
      return playerLayer.player
    }
    
    set {
      playerLayer.player = newValue
    }
  }
  
  var playerLayer: AVPlayerLayer {
    // swiftlint:disable force_cast
    return layer as! AVPlayerLayer
    // swiftlint:enable force_cast
  }
  
  override public class var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
}
