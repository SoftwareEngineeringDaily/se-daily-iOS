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

// MARK: - PlayerDelegate

/// Player delegate protocol
public protocol AudioViewDelegate: NSObjectProtocol {
    func playButtonPressed()
    func pauseButtonPressed()
    func stopButtonPressed()
    func skipForwardButtonPressed()
    func skipBackwardButtonPressed()
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

    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.performLayout()
        self.disableButtons()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    fileprivate func performLayout() {
        containerView.backgroundColor = .white
        self.addSubview(containerView)
        
        containerView.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(podcastLabel)
        
        podcastLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().inset(60.calculateWidth())
            make.right.equalToSuperview().inset(60.calculateWidth())
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-30.calculateHeight())
        }
        
        podcastLabel.font = UIFont.systemFont(ofSize: 16.calculateWidth())
        podcastLabel.numberOfLines = 0
        podcastLabel.textAlignment = .center
        
        containerView.addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        stackView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(70.calculateHeight())
            make.width.equalTo((50 * 5).calculateHeight())
            make.top.equalTo(podcastLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(skipBackwardbutton)
        stackView.addArrangedSubview(stopButton)
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(pauseButton)
        stackView.addArrangedSubview(skipForwardButton)
        
        let iconHeight = (70 / 2).calculateHeight()
        
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
            make.height.equalTo(20.calculateHeight())
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
            make.height.equalTo(20.calculateHeight())
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
            make.height.equalTo(20.calculateHeight())
            make.left.right.equalToSuperview()
        }
        
        bufferSlider.setThumbImage(UIImage(), for: .normal)
    }
    
    func addLabels() {
        currentTimeLabel.text = "00.00.00"
        currentTimeLabel.textAlignment = .left
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        
        timeLeftLabel.text = "00.00.00"
        timeLeftLabel.textAlignment = .right
        timeLeftLabel.adjustsFontSizeToFitWidth = true
        timeLeftLabel.font = UIFont.systemFont(ofSize: 12)

        self.containerView.addSubview(currentTimeLabel)
        self.containerView.addSubview(timeLeftLabel)
        
        currentTimeLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(playbackSlider).inset(5.calculateWidth())
            make.top.equalTo(playbackSlider.snp.bottom).inset(5.calculateHeight())
            make.height.equalTo(20.calculateHeight())
            make.width.equalTo(55.calculateWidth())
        }
        
        timeLeftLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(playbackSlider).inset(5.calculateWidth())
            make.top.equalTo(playbackSlider.snp.bottom).inset(5.calculateHeight())
            make.height.equalTo(20.calculateHeight())
            make.width.equalTo(55.calculateWidth())
        }
    }
    
    func playbackSliderValueChanged(_ slider: UISlider) {
        let timeInSeconds = slider.value
        
        if (playbackSlider.isTracking) && (timeInSeconds != previousSliderValue) {
            // Update Labels
            log.debug("value is tracking and changing")
        } else {
            log.debug("drag did end")
            self.delegate?.playbackSliderValueChanged(value: timeInSeconds)
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
        if isFirstLoad {
            playbackSlider.value = currentValue
            isFirstLoad = false
            return
        }
        
        let min = playbackSlider.value - 60.0
        let max = playbackSlider.value + 60.0
        
        // Check if current value is within a close enough range to slider value
        // This fixes sliders skipping around
        if min...max ~= currentValue && !playbackSlider.isTracking {
            playbackSlider.value = currentValue
        }
    }
    
    func updateBufferSlider(bufferValue: Float) {
        bufferSlider.value = bufferValue
    }
    
    func updateTimeLabels(currentTime: Float, timeLeft: Float) {
        updateCurrentTimeLabel(currentTime: currentTime)
        updateTimeLeftLabel(timeLeft: timeLeft)
    }

    func updateCurrentTimeLabel(currentTime: Float) {
        var currentTimeString = ""
        Helpers.hmsFrom(seconds: Int(currentTime), completion: { hours, minutes, seconds in
            let hoursString = Helpers.getStringFrom(seconds: hours)
            let minutesString = Helpers.getStringFrom(seconds: minutes)
            let secondsString = Helpers.getStringFrom(seconds: seconds)
            
            if hoursString == "00" {
                currentTimeString = "\(minutesString):\(secondsString)"
                return
            }
            currentTimeString = "\(hoursString):\(minutesString):\(secondsString)"
        })

        self.currentTimeLabel.text = currentTimeString
    }
    
    func updateTimeLeftLabel(timeLeft: Float) {
        var timeLeftString = ""
        Helpers.hmsFrom(seconds: Int(timeLeft), completion: { hours, minutes, seconds in
            let hoursString = Helpers.getStringFrom(seconds: hours)
            let minutesString = Helpers.getStringFrom(seconds: minutes)
            let secondsString = Helpers.getStringFrom(seconds: seconds)
            
            if hoursString == "00" {
                timeLeftString = "-" + "\(minutesString):\(secondsString)"
                return
            }
            timeLeftString = "-" + "\(hoursString):\(minutesString):\(secondsString)"
        })

        self.timeLeftLabel.text = timeLeftString
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
            make.right.equalToSuperview().inset(10.calculateWidth())
        }
    }
    
    func enableButtons() {
        self.playButton.isEnabled = true
        self.pauseButton.isEnabled = true
        self.stopButton.isEnabled = true
        self.skipForwardButton.isEnabled = true
        self.skipBackwardbutton.isEnabled = true
    }
    
    func disableButtons() {
        self.playButton.isEnabled = false
        self.pauseButton.isEnabled = false
        self.stopButton.isEnabled = false
        self.skipForwardButton.isEnabled = false
        self.skipBackwardbutton.isEnabled = false
    }
}


extension AudioView {
    // MARK: Function
    func playButtonPressed() {
        delegate?.playButtonPressed()
    }
    
    func pauseButtonPressed() {
        delegate?.pauseButtonPressed()
    }
    
    func stopButtonPressed() {
        delegate?.stopButtonPressed()
    }
    
    func skipForwardButtonPressed() {
        delegate?.skipForwardButtonPressed()
    }
    
    func skipBackwardButtonPressed() {
        delegate?.skipBackwardButtonPressed()
    }
}

class MySlider: UISlider {
//    override func trackRect(forBounds bounds: CGRect) -> CGRect {
//        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: 5))
//    }
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        return true
//    }
}

