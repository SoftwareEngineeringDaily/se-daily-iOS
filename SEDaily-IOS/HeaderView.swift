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
    var model = PodcastViewModel()
    
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
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    override func performLayout() {
        let views = [
            titleLabel
            ,dateLabel
        ]
        
        self.addSubviews(views)
        
        self.backgroundColor = Stylesheet.Colors.base
        setupPlayView()
        
        titleLabel.snp.makeConstraints{ (make) in
            make.bottom.equalTo(playView.snp.top).offset(UIView.getValueScaledByScreenHeightFor(baseValue: -60))
            make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: 15))
        }
        
        dateLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIView.getValueScaledByScreenHeightFor(baseValue: 10))
            make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: 15))
        }
        
        setupLabels()
    }
    
    func setupLabels() {
        titleLabel.font = UIFont(font: .helveticaNeue, size: UIView.getValueScaledByScreenWidthFor(baseValue: 20))
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Stylesheet.Colors.white
        
        dateLabel.font = UIFont(font: .helveticaNeue, size: UIView.getValueScaledByScreenWidthFor(baseValue: 16))
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
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 65))
        }
        
        playView.addSubview(playButton)
        playButton.setTitle(L10n.play, for: .normal)
        playButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        playButton.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 4)
        
        playButton.snp.makeConstraints{ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 84))
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 42))
        }
        
        playView.addSubview(voteView)
        voteView.snp.makeConstraints{ (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: (35 * 3)))
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
        scoreLabel.font = UIFont(font: .helveticaNeue, size: UIView.getValueScaledByScreenWidthFor(baseValue: 24))

        let iconSize = UIView.getValueScaledByScreenHeightFor(baseValue: 35)
        downVoteButton.setIcon(icon: .fontAwesome(.thumbsODown), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .normal)
        downVoteButton.setIcon(icon: .fontAwesome(.thumbsDown), iconSize: iconSize, color: Stylesheet.Colors.base, forState: .selected)
        downVoteButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .selected)
        downVoteButton.addTarget(self, action: #selector(self.downVoteButtonPressed), for: .touchUpInside)
        
        upVoteButton.setIcon(icon: .fontAwesome(.thumbsOUp), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .normal)
        upVoteButton.setIcon(icon: .fontAwesome(.thumbsUp), iconSize: iconSize, color: Stylesheet.Colors.base, forState: .selected)
        upVoteButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .selected)
        upVoteButton.addTarget(self, action: #selector(self.upvoteButtonPressed), for: .touchUpInside)
    }
    
    func setupHeader(model: PodcastViewModel) {
        self.model = model
        self.titleLabel.text = model.podcastTitle
        self.dateLabel.text = model.getLastUpdatedAsDate()?.dateString() ?? ""
        self.scoreLabel.text = model.score.string
        
        upVoteButton.isSelected = self.model.isUpvoted
        downVoteButton.isSelected = self.model.isDownvoted
        self.scoreLabel.text = String(self.model.score)
    }
}

extension HeaderView {
    @objc func playButtonPressed() {
        //@TODO: Switch button and/or stop if playing

        // Podcast model checks here
        AudioViewManager.shared.setupManager(podcastModel: model)
    }
    
    @objc func upvoteButtonPressed() {
        guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
            return
        }
        
        // Immediately set UI to upvote
        self.setUpvoteTo(!self.upVoteButton.isSelected)
        self.setDownvoteTo(false)
        
        let podcastId = model._id
        API.sharedInstance.upvotePodcast(podcastId: podcastId, completion: { (success, active) in
            guard success != nil else { return }
            if success == true {
                guard let active = active else { return }
                self.addScore(active: active)
            }
        })
    }
    
    @objc func downVoteButtonPressed() {
        guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
            return
        }
        
        // Immediately set UI to downvote
        self.setUpvoteTo(false)
        self.setDownvoteTo(!self.downVoteButton.isSelected)
        
        let podcastId = model._id
        API.sharedInstance.downvotePodcast(podcastId: podcastId, completion: { (success, active) in
            guard success != nil else { return }
            if success == true {
                // Switch if active
                guard let active = active else { return }
                self.subtractScore(active: active)
            }
        })
    }
    
    func addScore(active: Bool) {
        self.setUpvoteTo(active)
        guard active != false else {
            self.setScoreTo(self.model.score - 1)
            return
        }
        self.setScoreTo(self.model.score + 1)
    }
    
    func subtractScore(active: Bool) {
        self.setDownvoteTo(active)
        guard active != false else {
            self.setScoreTo(self.model.score + 1)
            return
        }
        self.setScoreTo(self.model.score - 1)
    }
    
    func setUpvoteTo(_ bool: Bool) {
        self.model.isUpvoted = bool
        self.upVoteButton.isSelected = bool
    }
    
    func setDownvoteTo(_ bool: Bool) {
        self.model.isDownvoted = bool
        self.downVoteButton.isSelected = bool
    }
    
    func setScoreTo(_ score: Int) {
        guard self.model.score != score else { return }
        self.model.score = score
        self.scoreLabel.text = String(score)
    }
}
