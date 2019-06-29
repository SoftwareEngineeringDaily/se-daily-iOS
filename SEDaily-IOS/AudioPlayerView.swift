//
//  AudioPlayerView.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 29/06/2019.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation
import SwifterSwift
import KTResponsiveUI

//enum PlaybackSpeed: Float {
//    case _1x = 1.0
//    case _1_2x = 1.2
//    case _1_4x = 1.4
//    case _1_6x = 1.6
//    case _1_8x = 1.8
//    case _2x = 2.0
//    case _2_5x = 2.5
//    case _3x = 3.0
//    
//    var title: String {
//        switch self {
//        case ._1x:
//            return "1x (Normal Speed)"
//        case ._1_2x:
//            return "1.2x"
//        case ._1_4x:
//            return "1.4x"
//        case ._1_6x:
//            return "1.6x"
//        case ._1_8x:
//            return "1.8x"
//        case ._2x:
//            return "⏩ 2x ⏩"
//        case ._2_5x:
//            return "2.5x"
//        case ._3x:
//            return "🔥 3x 🔥"
//        }
//    }
//    
//    var shortTitle: String {
//        switch self {
//        case ._1x:
//            return "1x"
//        case ._1_2x:
//            return "1.2x"
//        case ._1_4x:
//            return "1.4x"
//        case ._1_6x:
//            return "1.6x"
//        case ._1_8x:
//            return "1.8x"
//        case ._2x:
//            return "2x"
//        case ._2_5x:
//            return "2.5x"
//        case ._3x:
//            return "3x"
//        }
//    }
//}

public protocol Audio1ViewDelegate: NSObjectProtocol {
  func playButtonPressed()
  func pauseButtonPressed()
  func skipForwardButtonPressed()
  func skipBackwardButtonPressed()
  func detailsButtonPressed()
  func audioRateChanged(newRate: Float)
  func playbackSliderValueChanged(value: Float)
}

class AudioPlayerView: UIView {
  
  private let imageView: UIImageView = UIImageView()
  private let skipForwardButton = UIButton()
  private let skipBackwardButton = UIButton()
  private let paceButton = UIButton()
  private let playButton = UIButton()
  private let infoButton = UIButton()
  private let collapseButton = UIButton()
  private var currentImage = UIImage()
  
  private let stackView = UIStackView()
  private let separator: UIView = UIView()
  private let label = UILabel()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.performLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  } 
  
  override func performLayout() {
    self.backgroundColor = .white
    
    stackView.addArrangedSubview(paceButton)
    stackView.addArrangedSubview(skipBackwardButton)
    stackView.addArrangedSubview(playButton)
    stackView.addArrangedSubview(skipForwardButton)
    stackView.addArrangedSubview(infoButton)
    
    addSubview(stackView)
    addSubview(label)
    addSubview(imageView)
    addSubview(separator)
    addSubview(collapseButton)
    
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .equalSpacing
    
    skipForwardButton.setImage(#imageLiteral(resourceName: "rewind_audio"), for: .normal)
    skipBackwardButton.setImage(#imageLiteral(resourceName: "forward_audio"), for: .normal)
    
    playButton.setImage(#imageLiteral(resourceName: "play_audio"), for: .normal)
    
    infoButton.setImage(#imageLiteral(resourceName: "play_audio"), for: .normal)
    infoButton.addTarget(self, action: #selector(OverlayViewController.infoTapped), for: .touchUpInside)
    
    paceButton.setImage(#imageLiteral(resourceName: "Square"), for: .normal)
    
    collapseButton.setImage(#imageLiteral(resourceName: "Arrow-Down"), for: .normal)
    collapseButton.addTarget(self, action: #selector(OverlayViewController.collapseTapped), for: .touchUpInside)
    
    label.text = "Service Mesh Interface with Lachlan Evenson"
    
    separator.backgroundColor = .lightGray
    
    collapseButton.isHidden = true
    
    skipForwardButton.isHidden = true
    skipBackwardButton.isHidden = true
    
    infoButton.isHidden = true
    paceButton.isHidden = true
    
    label.font = UIFont(name: "Avenir", size: 13.0)
    label.textAlignment = .left
    label.numberOfLines = 2
    
    currentImage = #imageLiteral(resourceName: "download_panel")
    imageView.image = currentImage // for initial state
    
    playButton.setImage(#imageLiteral(resourceName: "play_audio"), for: .normal)
    
    imageView.layer.cornerRadius = 20.0
    imageView.layer.masksToBounds = true
    
    playButton.snp.remakeConstraints { (make) -> Void in
      make.size.equalTo(55).priority(999)
    }
    stackView.snp.remakeConstraints { (make) -> Void in
      make.right.equalToSuperview().inset(25.0)
      make.centerY.equalToSuperview()
    }
    imageView.snp.remakeConstraints { (make) -> Void in
      make.left.equalToSuperview().offset(10.0)
      make.centerY.equalToSuperview()
      make.size.equalTo(40)
    }
    label.snp.remakeConstraints { (make) -> Void in
      make.left.equalTo(imageView.snp.right).offset(15.0).priority(999)
      make.right.lessThanOrEqualTo(stackView.snp.left)
      make.centerY.equalToSuperview()
    }
    separator.snp.remakeConstraints { (make) -> Void in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(0.3)
    }
    
    
  }
    
    
    
    
}
