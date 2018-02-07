//
//  HeaderView.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/28/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwiftIcons

protocol HeaderViewDelegate: class {
    func modelDidChange(viewModel: PodcastViewModel)
    func relatedLinksButtonPressed()
    func commentsButtonPressed()
}

class HeaderView: UIView {
    weak var delegate: HeaderViewDelegate?
    
    var podcastViewModel = PodcastViewModel()

    let titleLabel = UILabel()
    let dateLabel = UILabel()

    let playView = UIView()
    let playButton = UIButton()
    
    let secondaryView = UIView()
    let relatedLinksButton = UIButton()
    
    let voteView = UIView()
    let stackView = UIStackView()
    let commentsButton = UIButton()
    let upVoteButton = UIButton()
    let downVoteButton = UIButton()
    let scoreLabel = UILabel()
    
    let networkService = API()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.performLayout()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }

    override func performLayout() {
        let views = [
            titleLabel,
            dateLabel
        ]

        self.addSubviews(views)

        self.backgroundColor = Stylesheet.Colors.base
        setupPlayView()
        setupSecondaryView()
        
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(playView.snp.top).offset(UIView.getValueScaledByScreenHeightFor(baseValue: -60))
            make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: 15))
        }

        dateLabel.snp.makeConstraints {  (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIView.getValueScaledByScreenHeightFor(baseValue: 15))
            make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: 15))
        }

        setupLabels()
    }

    func setupLabels() {
        // This makes the post title and date pretty and large:
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
    
    func setupSecondaryView() {
        self.addSubview(secondaryView)
        
        secondaryView.backgroundColor = UIColor.clear
        
        secondaryView.snp.makeConstraints { (make) in
            make.bottom.equalTo(playView.snp.top)
            make.right.left.equalToSuperview()
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 65))
        }
        
        // Add relatedLinksButton
        secondaryView.addSubview(relatedLinksButton)
        relatedLinksButton.setTitle(L10n.relatedLinks, for: .normal)
        relatedLinksButton.setBackgroundColor(color: Stylesheet.Colors.baseLight, forState: .normal)
        relatedLinksButton.addTarget(self, action: #selector(self.relatedLinksButtonPressed), for: .touchUpInside)
        relatedLinksButton.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 4)
        
        relatedLinksButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 180))
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 35))
        }
        
    }
    
    func setupPlayView() {
        self.addSubview(playView)
        
        // The playView is the row with the Up / Down and Pink Playbutton
        playView.backgroundColor = Stylesheet.Colors.white

        playView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 65))
        }

        playView.addSubview(playButton)
        playButton.setTitle(L10n.play, for: .normal)
        playButton.setBackgroundColor(color: Stylesheet.Colors.secondaryColor, forState: .normal)
        playButton.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside)
        playButton.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 4)

        playButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 84))
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 42))
        }

        playView.addSubview(voteView)
        voteView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: (35 * 4)))
            make.height.equalToSuperview()
        }

        voteView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        stackView.addArrangedSubview(commentsButton)
        stackView.addArrangedSubview(downVoteButton)
        stackView.addArrangedSubview(scoreLabel)
        stackView.addArrangedSubview(upVoteButton)

        scoreLabel.textAlignment = .center
        scoreLabel.baselineAdjustment = .alignCenters
        scoreLabel.font = UIFont(font: .helveticaNeue, size: UIView.getValueScaledByScreenWidthFor(baseValue: 24))

        let iconSize = UIView.getValueScaledByScreenHeightFor(baseValue: 35)
        commentsButton.setIcon(icon: .fontAwesome(.comments), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .normal)
        commentsButton.setIcon(icon: .fontAwesome(.comments), iconSize: iconSize, color: Stylesheet.Colors.base, forState: .selected)
        commentsButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .selected)
        commentsButton.addTarget(self, action: #selector(self.commentsButtonPressed), for: .touchUpInside)
        
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
        self.podcastViewModel = model
        self.titleLabel.text = model.podcastTitle
        self.dateLabel.text = model.getLastUpdatedAsDate()?.dateString() ?? ""
        self.scoreLabel.text = model.score.string

        commentsButton.isSelected = false
        upVoteButton.isSelected = self.podcastViewModel.isUpvoted
        downVoteButton.isSelected = self.podcastViewModel.isDownvoted
        self.scoreLabel.text = String(self.podcastViewModel.score)
    }
}

extension HeaderView {
    @objc func playButtonPressed() {
        //@TODO: Switch button and/or stop if playing

        // Podcast model checks here
        AudioViewManager.shared.setupManager(podcastModel: podcastViewModel)

        AskForReview.triggerEvent()
    }
    @objc func relatedLinksButtonPressed() {
        self.delegate?.relatedLinksButtonPressed()
    }

    @objc func commentsButtonPressed() {
        self.delegate?.commentsButtonPressed()
    }
    
    @objc func upvoteButtonPressed() {
        guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
            return
        }

        // Immediately set UI to upvote
        self.setUpvoteTo(!self.upVoteButton.isSelected)
        self.setDownvoteTo(false)

        let podcastId = podcastViewModel._id
        
        networkService.upvotePodcast(podcastId: podcastId, completion: { (success, active) in
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

        let podcastId = podcastViewModel._id
        networkService.downvotePodcast(podcastId: podcastId, completion: { (success, active) in
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
            self.setScoreTo(self.podcastViewModel.score - 1)
            self.delegate?.modelDidChange(viewModel: self.podcastViewModel)
            return
        }
        self.setScoreTo(self.podcastViewModel.score + 1)
        self.delegate?.modelDidChange(viewModel: self.podcastViewModel)
    }

    func subtractScore(active: Bool) {
        self.setDownvoteTo(active)
        guard active != false else {
            self.setScoreTo(self.podcastViewModel.score + 1)
            self.delegate?.modelDidChange(viewModel: self.podcastViewModel)
            return
        }
        self.setScoreTo(self.podcastViewModel.score - 1)
        self.delegate?.modelDidChange(viewModel: self.podcastViewModel)
    }

    func setUpvoteTo(_ bool: Bool) {
        self.podcastViewModel.isUpvoted = bool
        self.upVoteButton.isSelected = bool
    }

    func setDownvoteTo(_ bool: Bool) {
        self.podcastViewModel.isDownvoted = bool
        self.downVoteButton.isSelected = bool
    }

    func setScoreTo(_ score: Int) {
        guard self.podcastViewModel.score != score else { return }
        self.podcastViewModel.score = score
        self.scoreLabel.text = String(score)
    }
}
