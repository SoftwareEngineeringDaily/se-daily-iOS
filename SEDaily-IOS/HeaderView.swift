//
//  HeaderView.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/28/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwiftIcons

class HeaderView: UIView {
    var model: PodcastModel!
    
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    
    let playView = UIView()
    let playButton = UIButton()
    
    let voteView = UIView()
    let stackView = UIStackView()
    let upVoteButton = UIButton()
    let downVoteButton = UIButton()
    let scoreLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.performLayout()
//        Stylesheet.applyOn(self)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    func performLayout() {
        let views = [
            titleLabel
            ,dateLabel
        ]
        
        self.addSubviews(views)
        
        self.backgroundColor = Stylesheet.Colors.base
        setupPlayView()
        
        titleLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(playView.snp.top).offset(-60.calculateHeight())
            make.left.equalToSuperview().offset(15.calculateHeight())
            make.right.equalToSuperview().inset(15.calculateHeight())
        }
        
        dateLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.calculateHeight())
            make.left.equalToSuperview().offset(15.calculateHeight())
            make.right.equalToSuperview().inset(15.calculateHeight())
        }
        
        setupLabels()
    }
    
    func setupLabels() {
        titleLabel.font = UIFont(font: .helveticaNeue, size: 20.calculateHeight())
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Stylesheet.Colors.white
        
        dateLabel.font = UIFont(font: .helveticaNeue, size: 16.calculateHeight())
        dateLabel.adjustsFontSizeToFitWidth = false
        dateLabel.minimumScaleFactor = 0.25
        dateLabel.numberOfLines = 1
        dateLabel.textColor = Stylesheet.Colors.white
    }
    
    func setupPlayView() {
        self.addSubview(playView)
        playView.backgroundColor = Stylesheet.Colors.white
        
        playView.snp.makeConstraints{ (make) in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(65.calculateHeight())
        }
        
        playView.addSubview(playButton)
        playButton.setTitle("Play", for: .normal)
        playButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        playButton.cornerRadius = 4.calculateWidth()
        
        playButton.snp.makeConstraints{ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15.calculateWidth())
            make.width.equalTo(84.calculateWidth())
            make.height.equalTo(42.calculateHeight())
        }
        
        playView.addSubview(voteView)
        voteView.snp.makeConstraints{ (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(15.calculateWidth())
            make.width.equalTo((35 * 3).calculateWidth())
            make.height.equalToSuperview()
        }
        
        voteView.addSubview(stackView)
        stackView.snp.makeConstraints{ (make) in
            make.edges.equalToSuperview()
        }
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        stackView.addArrangedSubview(downVoteButton)
        stackView.addArrangedSubview(scoreLabel)
        stackView.addArrangedSubview(upVoteButton)
        
        scoreLabel.textAlignment = .center
        scoreLabel.baselineAdjustment = .alignCenters
        scoreLabel.font = UIFont(font: .helveticaNeue, size: 24.calculateWidth())

        downVoteButton.setIcon(icon: .fontAwesome(.arrowCircleODown), iconSize: 35.calculateHeight(), color: Stylesheet.Colors.offBlack, forState: .normal)
        downVoteButton.setIcon(icon: .fontAwesome(.arrowCircleOUp), iconSize: 35.calculateHeight(), color: Stylesheet.Colors.base, forState: .selected)
        downVoteButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .selected)
        downVoteButton.addTarget(self, action: #selector(self.downVoteButtonPressed), for: .touchUpInside)
        
        upVoteButton.setIcon(icon: .fontAwesome(.arrowCircleOUp), iconSize: 35.calculateHeight(), color: Stylesheet.Colors.offBlack, forState: .normal)
        upVoteButton.setIcon(icon: .fontAwesome(.arrowCircleOUp), iconSize: 35.calculateHeight(), color: Stylesheet.Colors.base, forState: .selected)
        upVoteButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .selected)
        upVoteButton.addTarget(self, action: #selector(self.upvoteButtonPressed), for: .touchUpInside)
    }
    
    func setupHeader(model: PodcastModel) {
        self.model = model
        self.titleLabel.text = model.podcastName!
        self.dateLabel.text = Helpers.formatDate(dateString: model.uploadDate!)
        self.scoreLabel.text = model.score!
    }
}

extension HeaderView {
    func playButtonPressed() {
        //@TODO: Switch button and/or stop if playing
//        AudioViewManager.shared.presentAudioView()
        let string = "http://traffic.libsyn.com/rtpodcast/podcast_update.mp3"

        // Podcast model checks here
        AudioViewManager.shared.setupManager(podcastModel: model)
    }
    
    func upvoteButtonPressed() {
        guard User.checkAndAlert() else { return }
        guard let podcastId = model.podcastId else { return }
        API.sharedInstance.upvotePodcast(podcastId: podcastId, completion: { (success) in
            guard success != nil else { return }
            switch success! {
            case true:
                guard let score = self.model.score else { return }
                guard var int = Int(score) else { return }
                int += 1
                self.scoreLabel.text = String(int)
                
                self.upVoteButton.isSelected = true
            case false:
                self.upVoteButton.isSelected = false
            }
        })
    }
    
    func downVoteButtonPressed() {
        guard User.checkAndAlert() else { return }
        guard let podcastId = model.podcastId else { return }
        API.sharedInstance.downvotePodcast(podcastId: podcastId, completion: { (success) in
            guard success != nil else { return }
            switch success! {
            case true:
                guard let score = self.model.score else { return }
                guard var int = Int(score) else { return }
                int -= 1
                self.scoreLabel.text = String(int)
                
                self.downVoteButton.isSelected = true
            case false:
                self.downVoteButton.isSelected = false
            }
        })
    }
}
