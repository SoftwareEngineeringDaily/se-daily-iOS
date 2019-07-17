/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 `Asset` is a wrapper struct around an `AVURLAsset` and its asset name.
 */

import Foundation
import AVFoundation

public class Asset {
  // MARK: Types
  static let nameKey = "AssetName"
  
  // MARK: Properties
  
  /// The name of the asset to present in the application.
  public var assetName: String = ""
  
  // Custom artwork
  public var artworkURL: URL? = nil
  
  /// The `AVURLAsset` corresponding to an asset in either the application bundle or on the Internet.
  public var urlAsset: AVURLAsset
  
  public var savedTime: Float = 0 // This is in seconds
  
  // @TODO: Idk if CMTime is the right thing to use
  public var savedCMTime: CMTime {
    get {
      return CMTimeMake(Int64(savedTime), 1)
    }
  }
  
  public init(assetName: String, url: URL, artworkURL: URL? = nil, savedTime: Float = 0) {
    self.assetName = assetName
    let avURLAsset = AVURLAsset(url: url)
    self.urlAsset = avURLAsset
    self.artworkURL = artworkURL
    self.savedTime = savedTime
  }
}

extension Asset: Equatable {
  public static func == (lhs: Asset, rhs: Asset) -> Bool {
    return lhs.assetName == rhs.assetName && lhs.urlAsset == lhs.urlAsset
  }
}
