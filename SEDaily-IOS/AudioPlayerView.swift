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
  private let playbackSpeedButton = UIButton()
  private let playButton = UIButton()
  private let infoButton = UIButton()
  private let collapseButton = UIButton()
  private var currentImage = UIImage()
  
  private var bufferSlider = UISlider(frame: .zero)
  private var bufferBackgroundSlider = UISlider(frame: .zero)
  private var playbackSlider = UISlider(frame: .zero)
  private var currentTimeLabel = UILabel()
  private var timeLeftLabel = UILabel()
  private var previousSliderValue: Float = 0.0
  
  private let stackView = UIStackView()
  private let separator: UIView = UIView()
  private let label = UILabel()
  
  var currentImageURL: URL?
  
  var vm: PodcastViewModel = PodcastViewModel()
  
  var expanded: Bool = false {
    didSet {
      setupLayout()
    }
  }
  
  var currentSpeed: PlaybackSpeed = ._1x {
    willSet {
      guard currentSpeed != newValue else { return }
      self.playbackSpeedButton.setTitle(newValue.shortTitle, for: .normal)
      
      //self.audioViewDelegate?.audioRateChanged(newRate: newValue.rawValue)
    }
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.performLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  } 
  
  override func performLayout() {
    self.backgroundColor = Stylesheet.Colors.light
    
    stackView.addArrangedSubview(playbackSpeedButton)
    stackView.addArrangedSubview(skipBackwardButton)
    stackView.addArrangedSubview(playButton)
    stackView.addArrangedSubview(skipForwardButton)
    stackView.addArrangedSubview(infoButton)
    
    
    addSubview(stackView)
    addSubview(label)
    addSubview(imageView)
    addSubview(separator)
    addSubview(collapseButton)
    addPlaybackSlider(parentView: self)
    addBufferSlider(parentView: self)
    addLabels(parentView: self)
    
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .equalSpacing
    
    skipForwardButton.setImage(#imageLiteral(resourceName: "forward_audio"), for: .normal)
    skipBackwardButton.setImage(#imageLiteral(resourceName: "rewind_audio"), for: .normal)
    
    playButton.setImage(#imageLiteral(resourceName: "play_audio"), for: .normal)
    
    playbackSpeedButton.setTitle(PlaybackSpeed._1x.shortTitle, for: .normal)
    playbackSpeedButton.titleLabel?.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 20))
    playbackSpeedButton.setTitleColor(Stylesheet.Colors.base, for: .normal)
    
    infoButton.setImage(#imageLiteral(resourceName: "info"), for: .normal)
    infoButton.addTarget(self, action: #selector(OverlayViewController.infoTapped), for: .touchUpInside)
    
    
    collapseButton.setImage(#imageLiteral(resourceName: "Arrow-Down"), for: .normal)
    collapseButton.addTarget(self, action: #selector(OverlayViewController.collapseTapped), for: .touchUpInside)
    
    label.text = vm.podcastTitle
    
    separator.backgroundColor = .lightGray
  }
  
  
  func addPlaybackSlider(parentView: UIView) {
    addBufferSlider(parentView: parentView)
    
    playbackSlider.minimumValue = 0
    playbackSlider.isContinuous = true
    playbackSlider.minimumTrackTintColor = Stylesheet.Colors.base
    playbackSlider.maximumTrackTintColor = .clear
    playbackSlider.layer.cornerRadius = 0
    //playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
    playbackSlider.isUserInteractionEnabled = false
    
    parentView.addSubview(playbackSlider)
    self.bringSubview(toFront: playbackSlider)
    
    playbackSlider.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(label.snp.bottom).offset(UIView.getValueScaledByScreenHeightFor(baseValue: 30))
      make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
      make.left.right.equalToSuperview().inset(15).priority(999)
      
    }
    
    let smallCircle = #imageLiteral(resourceName: "SmallCircle").filled(withColor: Stylesheet.Colors.base)
    playbackSlider.setThumbImage(smallCircle, for: .normal)
    
    let bigCircle = #imageLiteral(resourceName: "BigCircle").filled(withColor: Stylesheet.Colors.base)
    playbackSlider.setThumbImage(bigCircle, for: .highlighted)
  }
  
  func addBufferSlider(parentView: UIView) {
    bufferBackgroundSlider.minimumValue = 0
    bufferBackgroundSlider.isContinuous = true
    bufferBackgroundSlider.tintColor = Stylesheet.Colors.bufferColor
    bufferBackgroundSlider.layer.cornerRadius = 0
    bufferBackgroundSlider.alpha = 0.5
    //bufferBackgroundSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
    bufferBackgroundSlider.isUserInteractionEnabled = false
    
    parentView.addSubview(bufferBackgroundSlider)
    
    bufferBackgroundSlider.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(label.snp.bottom).offset(UIView.getValueScaledByScreenHeightFor(baseValue: 30))
      make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
      make.left.right.equalToSuperview().inset(15).priority(999)
    }
    
    bufferBackgroundSlider.setThumbImage(UIImage(), for: .normal)
    
    bufferSlider.minimumValue = 0
    bufferSlider.isContinuous = true
    bufferSlider.minimumTrackTintColor = Stylesheet.Colors.bufferColor
    bufferSlider.maximumTrackTintColor = .clear
    bufferSlider.layer.cornerRadius = 0
   // bufferSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
    bufferSlider.isUserInteractionEnabled = false
    
    parentView.addSubview(bufferSlider)
    
    bufferSlider.snp.makeConstraints { (make) -> Void in
      make.top.equalTo(label.snp.bottom).offset(UIView.getValueScaledByScreenHeightFor(baseValue: 30))
      make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
      make.left.right.equalToSuperview().inset(15).priority(999)
    }
    
    bufferSlider.setThumbImage(UIImage(), for: .normal)
  }
  
  func addLabels(parentView: UIView) {
    let labelFontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 12)
    currentTimeLabel.text = "00:00"
    currentTimeLabel.textAlignment = .left
    currentTimeLabel.font = UIFont.systemFont(ofSize: labelFontSize)
    
    timeLeftLabel.text = "00:00"
    timeLeftLabel.textAlignment = .right
    timeLeftLabel.adjustsFontSizeToFitWidth = true
    timeLeftLabel.font = UIFont.systemFont(ofSize: labelFontSize)
    
    parentView.addSubview(currentTimeLabel)
    parentView.addSubview(timeLeftLabel)
    
    currentTimeLabel.snp.makeConstraints { (make) -> Void in
      make.left.equalTo(playbackSlider)
      make.top.equalTo(playbackSlider.snp.bottom).inset(UIView.getValueScaledByScreenHeightFor(baseValue: 5))
      make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
      make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
    }
    
    timeLeftLabel.snp.makeConstraints { (make) -> Void in
      make.right.equalTo(playbackSlider)
      make.top.equalTo(playbackSlider.snp.bottom).inset(UIView.getValueScaledByScreenHeightFor(baseValue: 5))
      make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
      make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
    }
  }
  
  
  
  
  
  
  
  private func prepareForCollapsed() {
    
    bufferSlider.isHidden = true
    bufferBackgroundSlider.isHidden = true
    playbackSlider.isHidden = true
    currentTimeLabel.isHidden = true
    timeLeftLabel.isHidden = true
    
    
    collapseButton.isHidden = true
    
    skipForwardButton.isHidden = true
    skipBackwardButton.isHidden = true
    
    infoButton.isHidden = true
    playbackSpeedButton.isHidden = true
    
    label.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
    label.textAlignment = .left
    label.numberOfLines = 2
    
    currentImage = #imageLiteral(resourceName: "download_panel")
    
    currentImageURL = vm.guestImageURL
    
    
    
//    imageView.kf.setImage(with: vm.guestImageURL, placeholder: UIImage(named: "Logo_BarButton"), options: [.transition(.fade(0.2))])
    
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
  private func prepareForExpanded() {
    
    // slider.isHidden = false
    
    bufferSlider.isHidden = false
    bufferBackgroundSlider.isHidden = false
    playbackSlider.isHidden = false
    currentTimeLabel.isHidden = false
    timeLeftLabel.isHidden = false
    
    collapseButton.isHidden = false
    
    label.numberOfLines = 3
    
    playButton.setImage(#imageLiteral(resourceName: "play_big"), for: .normal)
    
    label.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 24))
    label.textAlignment = .center
    
    skipForwardButton.isHidden = false
    skipBackwardButton.isHidden = false
    
    infoButton.isHidden = false
    playbackSpeedButton.isHidden = false
    
    currentImage = #imageLiteral(resourceName: "download")
    
    currentImageURL = vm.featuredImageURL
    
    imageView.layer.cornerRadius = 0.0
    imageView.contentMode = .scaleAspectFit
    
    stackView.snp.remakeConstraints { (make) -> Void in
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().inset(20)
      make.top.equalTo(playbackSlider.snp.bottom).offset(UIView.getValueScaledByScreenHeightFor(baseValue: 30))
      make.centerX.equalToSuperview()
    }
    collapseButton.snp.remakeConstraints { (make) -> Void in
      make.left.equalToSuperview().offset(5)
      if #available(iOS 11.0, *) {
        make.top.equalTo(safeAreaLayoutGuide).offset(10.0)
      } else {
        // Fallback on earlier versions
        make.top.equalToSuperview().offset(10.0)
      }
      make.size.equalTo(50)
    }
    playButton.snp.remakeConstraints { (make) -> Void in
      make.size.equalTo(80).priority(999)
    }

    imageView.snp.remakeConstraints { (make) -> Void in
      make.left.right.equalToSuperview()
      make.top.equalTo(collapseButton.snp.bottom).offset(20.0)
      make.height.equalTo(200)
    }
    label.snp.remakeConstraints { (make) -> Void in
      make.top.equalTo(imageView.snp.bottom).offset(30.0)
      make.rightMargin.leftMargin.equalToSuperview().inset(20.0)
    }
  }
  
  private func setupLayout() {
    
    self.expanded ? prepareForExpanded() : prepareForCollapsed()
    UIView.animate(withDuration: 0.2, animations: {
      self.layoutIfNeeded()
    })
    UIView.transition(with: imageView,
                      duration: 0.2,
                      options: .transitionCrossDissolve,
                      animations: { self.imageView.kf.setImage(with: self.currentImageURL, placeholder: UIImage(named: "Logo_BarButton"), options: [.transition(.fade(0.2))]) },
                      completion: nil)
  }
  
}
