//
//  AudioPlayerView.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 29/06/2019.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public protocol AudioPlayerViewDelegate: NSObjectProtocol {
  func playButtonPressed()
  func pauseButtonPressed()
  func skipForwardButtonPressed()
  func skipBackwardButtonPressed()
  func detailsButtonPressed()
  func collapseButtonPressed()
  func audioRateChanged(newRate: Float)
  func playbackSliderValueChanged(value: Float)
}

class AudioPlayerView: UIView {
  
  private let imageView: UIImageView = UIImageView()
  private let skipForwardButton = UIButton()
  private let skipBackwardButton = UIButton()
  private let playbackSpeedButton = UIButton()
  
  private let infoButton = UIButton()
  private let collapseButton = UIButton()
  private var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  private var bufferSlider = UISlider(frame: .zero)
  private var bufferBackgroundSlider = UISlider(frame: .zero)
  private var playbackSlider = UISlider(frame: .zero)
  private var currentTimeLabel = UILabel()
  private var timeLeftLabel = UILabel()
  private var previousSliderValue: Float = 0.0
  
  private let stackView = UIStackView()
  private let separator: UIView = UIView()
  private let label = UILabel()
  
  let playButton = UIButton()
  let pauseButton = UIButton()
  
  var viewModel: PodcastViewModel = PodcastViewModel()
  
  weak var audioViewDelegate: AudioPlayerViewDelegate?
  
  var expanded: Bool = false {
    didSet {
      adjustLayout()
    }
  }
  
  var currentSpeed: PlaybackSpeed = ._1x {
    willSet {
      guard currentSpeed != newValue else { return }
      self.playbackSpeedButton.setTitle(newValue.shortTitle, for: .normal)
      self.audioViewDelegate?.audioRateChanged(newRate: newValue.rawValue)
    }
  }
  
  var alertController: UIAlertController! {
    let alert = UIAlertController(title: "Change Playback Speed", message: "Current Speed: \(self.currentSpeed.shortTitle)", preferredStyle: .actionSheet)
    let times: [PlaybackSpeed] = [._1x, ._1_2x, ._1_4x, ._1_6x, ._1_8x, ._2x, ._2_5x, ._3x]
    
    times.forEach({ (time) in
      let title = time.title
      alert.addAction(UIAlertAction(title: title, style: .default) { _ in
        self.currentSpeed = time
      })
    })
    alert.addAction(title: "Cancel", style: .cancel, isEnabled: true) {_ in
      self.alertController.dismiss(animated: true, completion: nil)
    }
    return alert
  }
  
  init(frame: CGRect, audioViewDelegate: AudioPlayerViewDelegate) {
    self.audioViewDelegate = audioViewDelegate
    super.init(frame: frame)
    self.performLayout()
    setupActivityIndicator()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startActivityAnimating() {
    self.activityView.startAnimating()
  }
  
  func stopActivityAnimating() {
    self.activityView.stopAnimating()
  }
  
  func enableButtons() {
    log.warning("enabling buttons")
    self.playButton.isEnabled = true
    self.pauseButton.isEnabled = true
    self.skipForwardButton.isEnabled = true
    self.skipBackwardButton.isEnabled = true
  }
  
  func disableButtons() {
    log.warning("disabling buttons")
    self.playButton.isEnabled = false
    self.pauseButton.isEnabled = false
    self.skipForwardButton.isEnabled = false
    self.skipBackwardButton.isEnabled = false
  }

}

extension AudioPlayerView {
  override func performLayout() {
    
    func addPlaybackSlider(parentView: UIView) {
      
      addBufferSlider(parentView: parentView)
      
      playbackSlider.minimumValue = 0
      playbackSlider.isContinuous = true
      playbackSlider.minimumTrackTintColor = Stylesheet.Colors.base
      playbackSlider.maximumTrackTintColor = .clear
      playbackSlider.layer.cornerRadius = 0
      playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
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
      bufferBackgroundSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
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
      bufferSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
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
    
    self.backgroundColor = Stylesheet.Colors.dark
    
    stackView.addArrangedSubview(playbackSpeedButton)
    stackView.addArrangedSubview(skipBackwardButton)
    stackView.addArrangedSubview(playButton)
    stackView.addArrangedSubview(pauseButton)
    stackView.addArrangedSubview(skipForwardButton)
    stackView.addArrangedSubview(infoButton)
    
    
    addSubview(stackView)
    addSubview(label)
    addSubview(imageView)
    addSubview(separator)
    addSubview(collapseButton)
    addPlaybackSlider(parentView: self)
    addLabels(parentView: self)
    
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .equalSpacing
    
    skipForwardButton.setImage(#imageLiteral(resourceName: "forward_audio"), for: .normal)
    skipForwardButton.addTarget(self, action: #selector(self.skipForwardButtonPressed), for: .touchUpInside)
    
    
    skipBackwardButton.setImage(#imageLiteral(resourceName: "rewind_audio"), for: .normal)
    skipBackwardButton.addTarget(self, action: #selector(self.skipBackwardButtonPressed), for: .touchUpInside)
    
    playButton.setImage(#imageLiteral(resourceName: "play_white"), for: .normal)
    playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
    
    pauseButton.setImage(#imageLiteral(resourceName: "pause_white"), for: .normal)
    pauseButton.addTarget(self, action: #selector(self.pauseButtonPressed), for: .touchUpInside)
    pauseButton.isHidden = true
    
    playbackSpeedButton.setTitle(PlaybackSpeed._1x.shortTitle, for: .normal)
    playbackSpeedButton.titleLabel?.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 20))
    playbackSpeedButton.setTitleColor(Stylesheet.Colors.base, for: .normal)
    playbackSpeedButton.addTarget(self, action: #selector(self.settingsButtonPressed), for: .touchUpInside)
    
    infoButton.setImage(#imageLiteral(resourceName: "info"), for: .normal)
    infoButton.addTarget(self, action: #selector(AudioPlayerView.infoTapped), for: .touchUpInside)
    
    
    collapseButton.setImage(#imageLiteral(resourceName: "Arrow-Down"), for: .normal)
    collapseButton.addTarget(self, action: #selector(AudioPlayerView.collapseTapped), for: .touchUpInside)
    
    label.text = viewModel.podcastTitle
    
    separator.backgroundColor = .lightGray
  }
  
  @objc func playbackSliderValueChanged(_ slider: UISlider) {
    let timeInSeconds = slider.value
    if (playbackSlider.isTracking) && (timeInSeconds != previousSliderValue) {
      playbackSlider.value = timeInSeconds
      let duration = playbackSlider.maximumValue
      let timeLeft = Float(duration - timeInSeconds)
      
      let currentTimeString = Helpers.createTimeString(time: timeInSeconds, units: [.minute, .second])
      let timeLeftString = Helpers.createTimeString(time: timeLeft, units: [.minute, .second])
      self.currentTimeLabel.text = currentTimeString
      self.timeLeftLabel.text = timeLeftString
    } else {
      self.audioViewDelegate?.playbackSliderValueChanged(value: timeInSeconds)
      let duration = playbackSlider.maximumValue
      let timeLeft = Float(duration - timeInSeconds)
      let currentTimeString = Helpers.createTimeString(time: timeInSeconds, units: [.minute, .second])
      let timeLeftString = Helpers.createTimeString(time: timeLeft, units: [.minute, .second])
      self.currentTimeLabel.text = currentTimeString
      self.timeLeftLabel.text = timeLeftString
    }
    previousSliderValue = timeInSeconds
  }
  
  @objc func settingsButtonPressed() {
    self.parentViewController?.present(alertController, animated: true, completion: nil)
  }
  
  @objc func collapseTapped() {
    audioViewDelegate?.collapseButtonPressed()
  }
  
  @objc func infoTapped() {
    audioViewDelegate?.detailsButtonPressed()
  }
  
  
  func updateSlider(maxValue: Float) {
    guard playbackSlider.maximumValue >= 0.0 else { return }
    
    if playbackSlider.isUserInteractionEnabled == false {
      playbackSlider.isUserInteractionEnabled = true
    }
    
    playbackSlider.maximumValue = maxValue
    bufferSlider.maximumValue = maxValue
  }
  
  func updateSlider(currentValue: Float) {
    guard !playbackSlider.isTracking else { return }
    playbackSlider.value = currentValue
  }
  
  func updateBufferSlider(bufferValue: Float) {
    bufferSlider.value = bufferValue
  }
  
  func updateTimeLabels(currentTimeText: String, timeLeftText: String) {
    guard !playbackSlider.isTracking else { return }
    self.currentTimeLabel.text = currentTimeText
    self.timeLeftLabel.text = timeLeftText
  }
  
  func setText(text: String?) {
    label.text = text ?? ""
  }
  
  func setupActivityIndicator() {
    addSubview(activityView)
    activityView.snp.makeConstraints { (make) -> Void in
      make.centerX.equalToSuperview()
      make.top.equalTo(playButton.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
    }
  }
  
}

extension AudioPlayerView {
  @objc func playButtonPressed() {
    self.audioViewDelegate?.playButtonPressed()
  }
  
  @objc func pauseButtonPressed() {
    self.audioViewDelegate?.pauseButtonPressed()
  }
  
  @objc func skipForwardButtonPressed() {
    self.audioViewDelegate?.skipForwardButtonPressed()
  }
  
  @objc func skipBackwardButtonPressed() {
    self.audioViewDelegate?.skipBackwardButtonPressed()
  }
}

extension AudioPlayerView {
  
  private func prepareForCollapsed() {
    
    self.backgroundColor = Stylesheet.Colors.white
    
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
    
    label.font = UIFont(name: "OpenSans-SemiBold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
    label.textColor = .white
    label.textAlignment = .left
    label.numberOfLines = 2
    
    playButton.setImage(#imageLiteral(resourceName: "play_white"), for: .normal)
    pauseButton.setImage(#imageLiteral(resourceName: "pause_white"), for: .normal)
    
    imageView.layer.cornerRadius = 20.0
    imageView.layer.masksToBounds = true
    
    playButton.snp.remakeConstraints { (make) -> Void in
      make.size.equalTo(40).priority(999)
    }
    pauseButton.snp.remakeConstraints { (make) -> Void in
      make.size.equalTo(40).priority(999)
    }
    stackView.snp.remakeConstraints { (make) -> Void in
      make.right.equalToSuperview().inset(15.0)
      make.centerY.equalToSuperview()
    }
    imageView.snp.remakeConstraints { (make) -> Void in
      make.left.equalToSuperview().offset(10.0)
      make.centerY.equalToSuperview()
      make.size.equalTo(40)
    }
    label.snp.remakeConstraints { (make) -> Void in
      make.left.equalTo(imageView.snp.right).offset(15.0).priority(999)
      make.right.equalToSuperview().inset(60)
      make.centerY.equalToSuperview()
    }
    separator.snp.remakeConstraints { (make) -> Void in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(0.3)
    }
  }
  
  private func prepareForExpanded() {
    
    self.backgroundColor = Stylesheet.Colors.white
    
    bufferSlider.isHidden = false
    bufferBackgroundSlider.isHidden = false
    playbackSlider.isHidden = false
    currentTimeLabel.isHidden = false
    timeLeftLabel.isHidden = false
    
    collapseButton.isHidden = false
    
    label.numberOfLines = 3
   
    
    playButton.setImage(#imageLiteral(resourceName: "play-big"), for: .normal)
    pauseButton.setImage(#imageLiteral(resourceName: "pause-big"), for: .normal)
    
    label.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 20))
    label.textAlignment = .center
    label.textColor = Stylesheet.Colors.dark
    
    skipForwardButton.isHidden = false
    skipBackwardButton.isHidden = false
    
    infoButton.isHidden = false
    playbackSpeedButton.isHidden = false
    
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
    pauseButton.snp.remakeConstraints { (make) -> Void in
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
  
  private func adjustLayout() {
    self.expanded ? prepareForExpanded() : prepareForCollapsed()
    UIView.animate(withDuration: 0.2, animations: {
      self.layoutIfNeeded()
    })
    UIView.transition(with: imageView,
                      duration: 0.2,
                      options: .transitionCrossDissolve,
                      animations: { self.imageView.kf.setImage(with: self.expanded ?  self.viewModel.featuredImageURL : self.viewModel.guestImageURL , placeholder: UIImage(named: "Logo_BarButton"), options: [.transition(.fade(0.2))])
                        self.backgroundColor = self.expanded ? .white : Stylesheet.Colors.dark
    },
                      completion: nil)
  }
}

