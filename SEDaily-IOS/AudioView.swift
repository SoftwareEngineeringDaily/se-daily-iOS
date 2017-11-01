//
//  AudioView.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/30/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import AVFoundation
import SwifterSwift
import KTResponsiveUI

enum PlaybackSpeed: Float {
    case _1x = 1.0
    case _1_2x = 1.2
    case _1_4x = 1.4
    case _1_6x = 1.6
    case _1_8x = 1.8
    case _2x = 2.0
    case _2_5x = 2.5
    case _3x = 3.0
    
    var title: String {
        switch self {
        case ._1x:
            return "1x (Normal Speed)"
        case ._1_2x:
            return "1.2x"
        case ._1_4x:
            return "1.4x"
        case ._1_6x:
            return "1.6x"
        case ._1_8x:
            return "1.8x"
        case ._2x:
            return "⏩ 2x ⏩"
        case ._2_5x:
            return "2.5x"
        case ._3x:
            return "🔥 3x 🔥"
        }
    }
    
    var shortTitle: String {
        switch self {
        case ._1x:
            return "1x"
        case ._1_2x:
            return "1.2x"
        case ._1_4x:
            return "1.4x"
        case ._1_6x:
            return "1.6x"
        case ._1_8x:
            return "1.8x"
        case ._2x:
            return "2x"
        case ._2_5x:
            return "2.5x"
        case ._3x:
            return "3x"
        }
    }
}

// MARK: - PlayerDelegate

/// Player delegate protocol
public protocol AudioViewDelegate: NSObjectProtocol {
    func playButtonPressed()
    func pauseButtonPressed()
    func stopButtonPressed()
    func skipForwardButtonPressed()
    func skipBackwardButtonPressed()
    func audioRateChanged(newRate: Float)
    func playbackSliderValueChanged(value: Float)
}

class AudioView: UIView {
    open weak var delegate: AudioViewDelegate?
    
    var activityView: UIActivityIndicatorView!
    
    var podcastLabel = UILabel()
    fileprivate var containerView = UIView()
    fileprivate var stackView = UIStackView()
    var skipForwardButton = UIButton()
    var skipBackwardbutton = UIButton()
    var playButton = UIButton()
    var pauseButton = UIButton()
    var stopButton = UIButton()
    
    var bufferSlider = UISlider(frame: .zero)
    var bufferBackgroundSlider = UISlider(frame: .zero)
    var playbackSlider = UISlider(frame: .zero)
    
    var currentTimeLabel = UILabel()
    var timeLeftLabel = UILabel()
    
    var previousSliderValue: Float = 0.0
    var isFirstLoad = true
    var playbackSpeedButton = UIButton()
    
    var currentSpeed: PlaybackSpeed = ._1x {
        willSet {
            guard currentSpeed != newValue else { return }
            self.playbackSpeedButton.setTitle(newValue.shortTitle, for: .normal)
            self.delegate?.audioRateChanged(newRate: newValue.rawValue)
        }
    }
    
    var alertController: UIAlertController! {
        get {
            let alert = UIAlertController(title: "Change Playback Speed", message: "Current Speed: \(self.currentSpeed.shortTitle)", preferredStyle: .actionSheet)
            let times: [PlaybackSpeed] = [._1x,._1_2x,._1_4x,._1_6x,._1_8x,._2x,._2_5x,._3x]
            
            times.forEach({ (time) in
                let title = time.title
                alert.addAction(UIAlertAction(title: title, style: .default) { action in
                    self.currentSpeed = time
                })
            })
            alert.addAction(title: "Cancel", style: .cancel, isEnabled: true) { (action) in
                self.alertController.dismiss(animated: true, completion: nil)
            }
            return alert
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.performLayout()
        self.disableButtons()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    internal override func performLayout() {
        containerView.backgroundColor = .white
        self.addSubview(containerView)
        
        containerView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(podcastLabel)
        
        podcastLabel.snp.makeConstraints { (make) -> Void in
            make.left.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 60))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: -30))
        }
        
        podcastLabel.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 16))
        podcastLabel.numberOfLines = 0
        podcastLabel.textAlignment = .center
        
        containerView.addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        stackView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 70))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: (50 * 5)))
            make.top.equalTo(podcastLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(skipBackwardbutton)
        stackView.addArrangedSubview(stopButton)
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(pauseButton)
        stackView.addArrangedSubview(skipForwardButton)
        
        let iconHeight = UIView.getValueScaledByScreenHeightFor(baseValue: (70 / 2))
        
        skipBackwardbutton.setImage(#imageLiteral(resourceName: "Backward"), for: .normal)
        skipBackwardbutton.height = iconHeight
        skipBackwardbutton.tintColor = Stylesheet.Colors.secondaryColor
        
        playButton.setIcon(icon: .fontAwesome(.play), iconSize: iconHeight, color: Stylesheet.Colors.secondaryColor, forState: .normal)
        pauseButton.setIcon(icon: .fontAwesome(.pause), iconSize: iconHeight, color: Stylesheet.Colors.secondaryColor, forState: .normal)
        stopButton.setIcon(icon: .fontAwesome(.stop), iconSize: iconHeight, color: Stylesheet.Colors.secondaryColor, forState: .normal)
        
        skipForwardButton.setImage(#imageLiteral(resourceName: "Forward"), for: .normal)
        skipForwardButton.height = iconHeight
        skipForwardButton.tintColor = Stylesheet.Colors.secondaryColor
        
        skipBackwardbutton.addTarget(self, action: #selector(self.skipBackwardButtonPressed), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(self.pauseButtonPressed), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(self.stopButtonPressed), for: .touchUpInside)
        skipForwardButton.addTarget(self, action: #selector(self.skipForwardButtonPressed), for: .touchUpInside)
        
        playButton.isHidden = true
        
        playbackSpeedButton.titleLabel?.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 20))
        playbackSpeedButton.setTitle(PlaybackSpeed._1x.shortTitle, for: .normal)
        playbackSpeedButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .normal)
        playbackSpeedButton.addTarget(self, action: #selector(self.settingsButtonPressed), for: .touchUpInside)
        self.addSubview(playbackSpeedButton)
        
        let width = UIView.getValueScaledByScreenWidthFor(baseValue: 40)
        let height = UIView.getValueScaledByScreenHeightFor(baseValue: 40)
        playbackSpeedButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 2))
        }

        setupActivityIndicator()
        addPlaybackSlider()
        addLabels()
    }
    
    func addPlaybackSlider() {
        addBufferSlider()
        
        playbackSlider.minimumValue = 0
        playbackSlider.isContinuous = true
        playbackSlider.minimumTrackTintColor = Stylesheet.Colors.secondaryColor
        playbackSlider.maximumTrackTintColor = .clear
        playbackSlider.layer.cornerRadius = 0
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        playbackSlider.isUserInteractionEnabled = false
        
        self.addSubview(playbackSlider)
        self.bringSubview(toFront: playbackSlider)
        
        playbackSlider.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().inset(-10)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.left.right.equalToSuperview()
        }
        
        let smallCircle = #imageLiteral(resourceName: "SmallCircle").filled(withColor: Stylesheet.Colors.secondaryColor)
        playbackSlider.setThumbImage(smallCircle, for: .normal)
        
        let bigCircle = #imageLiteral(resourceName: "BigCircle").filled(withColor: Stylesheet.Colors.secondaryColor)
        playbackSlider.setThumbImage(bigCircle, for: .highlighted)
    }
    
    func addBufferSlider() {
        // Background Buffer Slider
        bufferBackgroundSlider.minimumValue = 0
        bufferBackgroundSlider.isContinuous = true
        bufferBackgroundSlider.tintColor = Stylesheet.Colors.bufferColor
        bufferBackgroundSlider.layer.cornerRadius = 0
        bufferBackgroundSlider.alpha = 0.5
        bufferBackgroundSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        bufferBackgroundSlider.isUserInteractionEnabled = false
        
        self.addSubview(bufferBackgroundSlider)
        
        bufferBackgroundSlider.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().inset(-10)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.left.right.equalToSuperview()
        }
        
        bufferBackgroundSlider.setThumbImage(UIImage(), for: .normal)
        
        bufferSlider.minimumValue = 0
        bufferSlider.isContinuous = true
        bufferSlider.minimumTrackTintColor = Stylesheet.Colors.bufferColor
        bufferSlider.maximumTrackTintColor = .clear
        bufferSlider.layer.cornerRadius = 0
        bufferSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        bufferSlider.isUserInteractionEnabled = false
        
        self.addSubview(bufferSlider)
        
        bufferSlider.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().inset(-10)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.left.right.equalToSuperview()
        }
        
        bufferSlider.setThumbImage(UIImage(), for: .normal)
    }
    
    func addLabels() {
        let labelFontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 12)
        currentTimeLabel.text = "00:00"
        currentTimeLabel.textAlignment = .left
        currentTimeLabel.font = UIFont.systemFont(ofSize: labelFontSize)
        
        timeLeftLabel.text = "00:00"
        timeLeftLabel.textAlignment = .right
        timeLeftLabel.adjustsFontSizeToFitWidth = true
        timeLeftLabel.font = UIFont.systemFont(ofSize: labelFontSize)

        self.containerView.addSubview(currentTimeLabel)
        self.containerView.addSubview(timeLeftLabel)
        
        currentTimeLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(playbackSlider).inset(UIView.getValueScaledByScreenWidthFor(baseValue: 5))
            make.top.equalTo(playbackSlider.snp.bottom).inset(UIView.getValueScaledByScreenHeightFor(baseValue: 5))
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
        
        timeLeftLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(playbackSlider).inset(UIView.getValueScaledByScreenWidthFor(baseValue: 5))
            make.top.equalTo(playbackSlider.snp.bottom).inset(UIView.getValueScaledByScreenHeightFor(baseValue: 5))
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
    }
    
    @objc func playbackSliderValueChanged(_ slider: UISlider) {
        let timeInSeconds = slider.value
        
        if (playbackSlider.isTracking) && (timeInSeconds != previousSliderValue) {
            // Update Labels
            // Do this without using functions because this views controller use the functions and they have a !isTracking guard
            //@TODO: Figure out how to fix not being able to use functions
//            self.updateSlider(currentValue: timeInSeconds)
            playbackSlider.value = timeInSeconds
            let duration = playbackSlider.maximumValue
            let timeLeft = Float(duration - timeInSeconds)
            
            let currentTimeString = Helpers.createTimeString(time: timeInSeconds)
            let timeLeftString = Helpers.createTimeString(time: timeLeft)
//            self.updateTimeLabels(currentTimeText: currentTimeString, timeLeftText: timeLeftString)
            self.currentTimeLabel.text = currentTimeString
            self.timeLeftLabel.text = timeLeftString
        } else {
            self.delegate?.playbackSliderValueChanged(value: timeInSeconds)
            let duration = playbackSlider.maximumValue
            let timeLeft = Float(duration - timeInSeconds)
            let currentTimeString = Helpers.createTimeString(time: timeInSeconds)
            let timeLeftString = Helpers.createTimeString(time: timeLeft)
            self.currentTimeLabel.text = currentTimeString
            self.timeLeftLabel.text = timeLeftString
        }
        previousSliderValue = timeInSeconds
    }

    func updateSlider(maxValue: Float) {
        // Update max only once
        guard playbackSlider.maximumValue <= 1.0 else { return }

        if playbackSlider.isUserInteractionEnabled == false {
            playbackSlider.isUserInteractionEnabled = true
        }

        playbackSlider.maximumValue = maxValue
        bufferSlider.maximumValue = maxValue
    }
    
    func updateSlider(currentValue: Float) {
        // Have to check is first load because current value may be far from 0.0
        //@TODO: Fix this logic to fix jumping of playbackslider
        guard !playbackSlider.isTracking else { return }
//        if isFirstLoad {
//            playbackSlider.value = currentValue
//            isFirstLoad = false
//            return
//        }
//        
//        let min = playbackSlider.value - 60.0
//        let max = playbackSlider.value + 60.0
        
        // Check if current value is within a close enough range to slider value
        // This fixes sliders skipping around
//        if min...max ~= currentValue && !playbackSlider.isTracking {
            playbackSlider.value = currentValue
//        }
    }
    
    func updateBufferSlider(bufferValue: Float) {
        bufferSlider.value = bufferValue
    }
    
    func updateTimeLabels(currentTimeText: String, timeLeftText: String) {
        guard !playbackSlider.isTracking else { return }
        self.currentTimeLabel.text = currentTimeText
        self.timeLeftLabel.text = timeLeftText
    }
    
    public func animateIn() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y -= self.height
            self.frame = self.frame
        })
    }
    
    public func animateOut() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y += self.height
            self.frame = self.frame
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    public func setText(text: String?) {
        podcastLabel.text = text ?? ""
    }
    
    func setupActivityIndicator() {
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.containerView.addSubview(activityView)
        
        activityView.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
        }
    }
    
    func enableButtons() {
        log.warning("enabling buttons")
        self.playButton.isEnabled = true
        self.pauseButton.isEnabled = true
        self.stopButton.isEnabled = true
        self.skipForwardButton.isEnabled = true
        self.skipBackwardbutton.isEnabled = true
    }
    
    func disableButtons() {
        log.warning("disabling buttons")
        self.playButton.isEnabled = false
        self.pauseButton.isEnabled = false
        self.stopButton.isEnabled = false
        self.skipForwardButton.isEnabled = false
        self.skipBackwardbutton.isEnabled = false
    }
}


extension AudioView {
    // MARK: Function
    @objc func playButtonPressed() {
        delegate?.playButtonPressed()
    }
    
    @objc func pauseButtonPressed() {
        delegate?.pauseButtonPressed()
    }
    
    @objc func stopButtonPressed() {
        delegate?.stopButtonPressed()
    }
    
    @objc func skipForwardButtonPressed() {
        delegate?.skipForwardButtonPressed()
    }
    
    @objc func skipBackwardButtonPressed() {
        delegate?.skipBackwardButtonPressed()
    }
    
    @objc func settingsButtonPressed() {
        // Present alert view
        self.parentViewController?.present(alertController, animated: true, completion: nil)
    }
}
