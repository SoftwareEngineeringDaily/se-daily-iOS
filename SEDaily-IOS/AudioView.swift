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

public protocol AudioViewDelegate: NSObjectProtocol {
    func playButtonPressed()
    func pauseButtonPressed()
    func stopButtonPressed()
    func skipForwardButtonPressed()
    func skipBackwardButtonPressed()
    func expandButtonPressed()
    func collapseButtonPressed()
    func audioRateChanged(newRate: Float)
    func playbackSliderValueChanged(value: Float)
}

class AudioView: UIView {
    private var isCollapsed = true
    private weak var audioViewDelegate: AudioViewDelegate?
    private var activityView: UIActivityIndicatorView!
    private var podcastLabel = UILabel()
    private var expandCollapseButton = UIButton()
    private var skipForwardButton = UIButton()
    private var skipBackwardbutton = UIButton()
    private var bufferSlider = UISlider(frame: .zero)
    private var bufferBackgroundSlider = UISlider(frame: .zero)
    private var playbackSlider = UISlider(frame: .zero)
    private var currentTimeLabel = UILabel()
    private var timeLeftLabel = UILabel()
    private var previousSliderValue: Float = 0.0
    private var playbackSpeedButton = UIButton()
    private var originalFrame: CGRect
    private var viewModel: PodcastViewModel?

    var isFirstLoad = true
    var playButton = UIButton()
    var pauseButton = UIButton()
    var stopButton = UIButton()

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

    init(frame: CGRect, audioViewDelegate: AudioViewDelegate) {
        self.audioViewDelegate = audioViewDelegate
        self.originalFrame = frame
        super.init(frame: frame)

        self.performLayout()
        self.disableButtons()

        self.hideSliders()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }

    internal override func performLayout() {
        let containerView = UIView()
        self.addSubview(containerView)
        self.createAudioControlView(parentView: containerView)

        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    func startActivityAnimating() {
        self.activityView.startAnimating()
    }

    func stopActivityAnimating() {
        self.activityView.stopAnimating()
    }

    func createAudioControlView(parentView: UIView) {
        let containerView = UIView()
        containerView.backgroundColor = .white
        parentView.addSubview(containerView)

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
        podcastLabel.numberOfLines = 2
        podcastLabel.lineBreakMode = .byTruncatingTail
        podcastLabel.textAlignment = .center

        let stackView = UIStackView()
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
        
        stackView.addArrangedSubview(stopButton)
        stackView.addArrangedSubview(skipBackwardbutton)
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(pauseButton)
        stackView.addArrangedSubview(skipForwardButton)

        let iconHeight = UIView.getValueScaledByScreenHeightFor(baseValue: (70 / 2))

        expandCollapseButton.setIcon(icon: .fontAwesome(.angleUp), iconSize: iconHeight, color: Stylesheet.Colors.secondaryColor, forState: .normal)

        skipBackwardbutton.setImage(#imageLiteral(resourceName: "Backward"), for: .normal)
        skipBackwardbutton.height = iconHeight
        skipBackwardbutton.tintColor = Stylesheet.Colors.secondaryColor

        playButton.setIcon(icon: .fontAwesome(.play), iconSize: iconHeight, color: Stylesheet.Colors.secondaryColor, forState: .normal)
        pauseButton.setIcon(icon: .fontAwesome(.pause), iconSize: iconHeight, color: Stylesheet.Colors.secondaryColor, forState: .normal)
        stopButton.setIcon(icon: .fontAwesome(.close), iconSize: iconHeight, color: Stylesheet.Colors.secondaryColor, forState: .normal)

        skipForwardButton.setImage(#imageLiteral(resourceName: "Forward"), for: .normal)
        skipForwardButton.height = iconHeight
        skipForwardButton.tintColor = Stylesheet.Colors.secondaryColor

        expandCollapseButton.addTarget(self, action: #selector(self.expandButtonPressed), for: .touchUpInside)
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
        parentView.addSubview(playbackSpeedButton)

        let width = UIView.getValueScaledByScreenWidthFor(baseValue: 40)
        let height = UIView.getValueScaledByScreenHeightFor(baseValue: 40)
        playbackSpeedButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(width)
            make.height.equalTo(height)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 2))
        }

        setupActivityIndicator(parentView: containerView)
        addPlaybackSlider(parentView: parentView)
        addLabels(parentView: containerView)

        parentView.addSubview(self.expandCollapseButton)

        self.expandCollapseButton.snp.makeConstraints { (make) in
            make.bottom.left.equalToSuperview()
            make.width.height.equalTo(iconHeight)
        }
    }

    func addPlaybackSlider(parentView: UIView) {
        addBufferSlider(parentView: parentView)

        playbackSlider.minimumValue = 0
        playbackSlider.isContinuous = true
        playbackSlider.minimumTrackTintColor = Stylesheet.Colors.secondaryColor
        playbackSlider.maximumTrackTintColor = .clear
        playbackSlider.layer.cornerRadius = 0
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        playbackSlider.isUserInteractionEnabled = false

        parentView.addSubview(playbackSlider)
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

        parentView.addSubview(bufferSlider)

        bufferSlider.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().inset(-10)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.left.right.equalToSuperview()
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
            playbackSlider.value = timeInSeconds
            let duration = playbackSlider.maximumValue
            let timeLeft = Float(duration - timeInSeconds)

            let currentTimeString = Helpers.createTimeString(time: timeInSeconds)
            let timeLeftString = Helpers.createTimeString(time: timeLeft)
            self.currentTimeLabel.text = currentTimeString
            self.timeLeftLabel.text = timeLeftString
        } else {
            self.audioViewDelegate?.playbackSliderValueChanged(value: timeInSeconds)
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
        guard playbackSlider.maximumValue <= 1.0 else { return }

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
        podcastLabel.text = text ?? ""
    }

    func setupActivityIndicator(parentView: UIView) {
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        parentView.addSubview(activityView)

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

    private func toggleExpandCollapse() {
        self.isCollapsed = !self.isCollapsed
        let rotationAngle: CGFloat = self.isCollapsed ? -179 : 180
        self.expandCollapseButton.rotate(
            byAngle: rotationAngle,
            ofType: .degrees,
            animated: true,
            duration: 0.25,
            completion: { isFinished in
                if isFinished && self.isCollapsed {
                    self.expandCollapseButton.transform = .identity
                }
        })
    }

    func hideSliders() {
        self.bufferSlider.isHidden = true
        self.playbackSlider.isHidden = true
        self.bufferBackgroundSlider.isHidden = true
    }

    func showSliders() {
        self.bufferSlider.isHidden = false
        self.playbackSlider.isHidden = false
        self.bufferBackgroundSlider.isHidden = false
    }

    func showExpandCollapseButton() {
        self.expandCollapseButton.isHidden = false
    }

    func hideExpandCollapseButton() {
        self.expandCollapseButton.isHidden = true
    }
}

extension AudioView {
    @objc func playButtonPressed() {
        self.audioViewDelegate?.playButtonPressed()
    }

    @objc func pauseButtonPressed() {
        self.audioViewDelegate?.pauseButtonPressed()
    }

    @objc func stopButtonPressed() {
        self.audioViewDelegate?.stopButtonPressed()
    }

    @objc func skipForwardButtonPressed() {
        self.audioViewDelegate?.skipForwardButtonPressed()
    }

    @objc func skipBackwardButtonPressed() {
        self.audioViewDelegate?.skipBackwardButtonPressed()
    }

    @objc func expandButtonPressed() {
        self.toggleExpandCollapse()

        if self.isCollapsed {
            self.audioViewDelegate?.collapseButtonPressed()
        } else {
            self.audioViewDelegate?.expandButtonPressed()
        }
    }

    @objc func settingsButtonPressed() {
        self.parentViewController?.present(alertController, animated: true, completion: nil)
    }
}
