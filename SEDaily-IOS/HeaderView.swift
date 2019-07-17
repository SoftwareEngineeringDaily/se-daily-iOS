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
    func updateBookmarked(active: Bool)
    func commentsButtonPressed()
}

class HeaderView: UIView {
    var iconSize = UIView.getValueScaledByScreenWidthFor(baseValue: 34)

    weak var delegate: HeaderViewDelegate?
    weak var bookmarkDelegate:BookmarksDelegate?
    weak var audioOverlayDelegate: AudioOverlayDelegate?

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

    private var downloadButton = UIButton()


    let downloadManager = OfflineDownloadsManager.sharedInstance
    let networkService = API()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.performLayout()
    }

    override func didMoveToSuperview() {
        // This will "hide" the Play button, to make it clear it won't work if pressed.
        if self.audioOverlayDelegate == nil {
            playButton.alpha = 0.2
        } else {
            playButton.alpha = 1.0
        }
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
            make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
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
//        stackView.addArrangedSubview(commentsButton)

        stackView.addArrangedSubview(downVoteButton)
        stackView.addArrangedSubview(scoreLabel)
        stackView.addArrangedSubview(upVoteButton)

        scoreLabel.textAlignment = .center
        scoreLabel.baselineAdjustment = .alignCenters
        scoreLabel.font = UIFont(font: .helveticaNeue, size: UIView.getValueScaledByScreenWidthFor(baseValue: 24))

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
        if self.podcastViewModel.thread != nil {
            commentsButton.isHidden = false
        } else {
            commentsButton.isHidden = true
        }
        self.titleLabel.text = model.podcastTitle
        self.dateLabel.text = model.getLastUpdatedAsDate()?.dateString() ?? ""
        self.scoreLabel.text = model.score.string

        commentsButton.isSelected = false
        upVoteButton.isSelected = self.podcastViewModel.isUpvoted
        downVoteButton.isSelected = self.podcastViewModel.isDownvoted
        self.scoreLabel.text = String(self.podcastViewModel.score)

        self.setupDownloadButton()
        self.setupCommentsButton()
    }
}

extension HeaderView {
    @objc func playButtonPressed() {
        //@TODO: Switch button and/or stop if playing

        self.audioOverlayDelegate?.animateOverlayIn()
        self.audioOverlayDelegate?.playAudio(podcastViewModel: self.podcastViewModel)

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

extension HeaderView {
    @objc private func downloadButtonPressed() {
        switch self.downloadButton.isSelected {
        case true:
            self.deletePodcast()
        case false:
            self.savePodcast()
            if UserManager.sharedInstance.isCurrentUserLoggedIn() == true {
                self.bookmarkDelegate?.bookmarkPodcast()
            }
        }
    }

    private func savePodcast() {
        guard !self.downloadButton.isSelected else { return }
        self.downloadButton.isSelected = true

        self.playButton.isUserInteractionEnabled = false
        
        let podcastId = self.podcastViewModel._id            
        
        self.downloadManager.save(
            podcast: self.podcastViewModel,
            onProgress: { progress in
                // Show progress
                let progressAsInt = Int((progress * 100).rounded())
                self.playButton.setTitle(String(progressAsInt) + "%", for: .normal)},
            onSuccess: {
                // Show success by changing download
                self.delegate?.modelDidChange(viewModel: self.podcastViewModel)
//                self.audioOverlayDelegate?.animateOverlayIn()
//                self.audioOverlayDelegate?.playAudio(podcastViewModel: self.podcastViewModel)
//                self.audioOverlayDelegate?.pauseAudio()
                self.playButton.setTitle("Play", for: .normal)
                self.playButton.isUserInteractionEnabled = true},
            onFailure: { error in
                self.playButton.setTitle("Play", for: .normal)
                self.playButton.isUserInteractionEnabled = true

                guard let error = error else { return }
                // Alert Error
                Helpers.alertWithMessage(title: error.localizedDescription.capitalized, message: "")})
    }

    private func deletePodcast() {
        guard self.downloadButton.isSelected else { return }

        let alert = UIAlertController(title: "Are you sure you want to delete this podcast?", message: nil, preferredStyle: .alert)

        alert.addAction(title: "YEP! Delete it please.", style: .destructive, isEnabled: true) { _ in
            self.downloadManager.deletePodcast(podcast: self.podcastViewModel) {
                print("Successfully deleted")
            }

            self.downloadButton.isSelected = false
            self.playButton.setTitle("Play", for: .normal)
            self.playButton.isUserInteractionEnabled = true
        }

        let noAction = UIAlertAction(title: "Oh no actually...", style: .cancel, handler: nil)
        alert.addAction(noAction)

        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            guard !(topController is UIAlertController) else {
                // There's already a alert preseneted
                return
            }

            topController.present(alert, animated: true, completion: nil)
        }
    }

    private func setupDownloadButton() {

        self.downloadButton.addTarget(self, action: #selector(self.downloadButtonPressed), for: .touchUpInside)
        self.downloadButton.setIcon(
            icon: .fontAwesome(.cloudDownload),
            iconSize: iconSize,
            color: Stylesheet.Colors.secondaryColor,
            forState: .normal)
        self.downloadButton.setIcon(
            icon: .fontAwesome(.timesCircle),
            iconSize: iconSize,
            color: .red,
            forState: .selected)
        self.downloadButton.isSelected = self.podcastViewModel.isDownloaded

        self.playView.addSubview(self.downloadButton)

        let rightInset = UIView.getValueScaledByScreenWidthFor(baseValue: 20)
        downloadButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.playButton.snp.left).inset(-rightInset)
            make.centerY.equalTo(self.playButton.snp.centerY)
        }
    }

    private func setupCommentsButton() {
        commentsButton.setIcon(icon: .fontAwesome(.commentO), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .normal)
        commentsButton.addTarget(self, action: #selector(self.commentsButtonPressed), for: .touchUpInside)

        self.playView.addSubview(self.commentsButton)

        let rightInset = UIView.getValueScaledByScreenWidthFor(baseValue: 20)
        commentsButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.downloadButton.snp.left).inset(-rightInset)
            make.centerY.equalTo(self.downloadButton.snp.centerY)
        }
    }
}
