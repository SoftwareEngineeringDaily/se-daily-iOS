//
//  AudioView.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/30/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

class AudioView: UIView {
    
    var activityView: UIActivityIndicatorView!
    
    var podcastLabel = UILabel()
    fileprivate var containerView = UIView()
    fileprivate var stackView = UIStackView()
    var playButton = UIButton()
    var pauseButton = UIButton()
    var stopButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.performLayout()
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
            make.left.right.equalToSuperview().inset(15.calculateWidth())
            make.centerY.equalToSuperview().inset(-30.calculateHeight())
            make.centerX.equalToSuperview()
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
            make.width.equalTo(150.calculateHeight())
            make.top.equalTo(podcastLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        stackView.addArrangedSubview(stopButton)
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(pauseButton)
        
        playButton.setIcon(icon: .fontAwesome(.play), iconSize: (70 / 2).calculateHeight(), color: Stylesheet.Colors.secondaryColor, forState: .normal)
        pauseButton.setIcon(icon: .fontAwesome(.pause), iconSize: (70 / 2).calculateHeight(), color: Stylesheet.Colors.secondaryColor, forState: .normal)
        stopButton.setIcon(icon: .fontAwesome(.stop), iconSize: (70 / 2).calculateHeight(), color: Stylesheet.Colors.secondaryColor, forState: .normal)
        
        
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(self.pauseButtonPressed), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(self.stopButtonPressed), for: .touchUpInside)
        
        playButton.isHidden = true
        
        setupActivityIndicator()
    }
    
    public func animateIn() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
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
}


extension AudioView {
    // MARK: Function
    func playButtonPressed() {
        AudioManager.shared.audio.state = .playing(AudioManager.shared.playbackState)
    }
    
    func pauseButtonPressed() {
        AudioManager.shared.audio.state = .paused
    }
    
    func stopButtonPressed() {
        AudioManager.shared.audio.state = .stopped
    }
}


