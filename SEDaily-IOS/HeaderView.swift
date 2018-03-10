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
}

class HeaderView: UIView {
    weak var delegate: HeaderViewDelegate?
    
    var podcastViewModel = PodcastViewModel()

    let titleLabel = UILabel()
    let dateLabel = UILabel()

    let playView = UIView()
    let playButton = UIButton()

    let voteView = UIView()
    let stackView = UIStackView()
    let upVoteButton = UIButton()
    let downVoteButton = UIButton()
    let scoreLabel = UILabel()

    private var downloadButton = UIButton()

    let downloadManager = OfflineDownloadsManager()
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

        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(playView.snp.top).offset(UIView.getValueScaledByScreenHeightFor(baseValue: -60))
            make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: 15))
        }

        dateLabel.snp.makeConstraints {  (make) in
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
        self.podcastViewModel = model
        self.titleLabel.text = model.podcastTitle
        self.dateLabel.text = model.getLastUpdatedAsDate()?.dateString() ?? ""
        self.scoreLabel.text = model.score.string

        upVoteButton.isSelected = self.podcastViewModel.isUpvoted
        downVoteButton.isSelected = self.podcastViewModel.isDownvoted
        self.scoreLabel.text = String(self.podcastViewModel.score)

        self.setupDownloadButton()
    }
}

extension HeaderView {
    @objc func playButtonPressed() {
        //@TODO: Switch button and/or stop if playing

        // Podcast model checks here
        AudioViewManager.shared.setupManager(podcastModel: podcastViewModel)

        AskForReview.triggerEvent()
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

/* @TODO:
 - delete podcast
 - progress view on play button
 - stop podcast downloading
*/
extension HeaderView {
    @objc private func downloadButtonPressed() {
        switch self.downloadButton.isSelected {
        case true:
            self.deletePodcast()
        case false:
            self.savePodcast()
        }

    }

    private func savePodcast() {
        guard !self.downloadButton.isSelected else { return }
        self.downloadButton.isSelected = true

        self.playButton.isUserInteractionEnabled = false

        self.downloadManager.save(podcast: self.podcastViewModel, onProgress: { (progress) in
            // Show progress
            print(progress)
            let progressAsInt = Int((progress * 100).rounded())
            self.playButton.setTitle(String(progressAsInt) + "%", for: .normal)
        }, onSucces: { () in
            // Show success by changing download
            print("success")

            self.delegate?.modelDidChange(viewModel: self.podcastViewModel)

            AudioViewManager.shared.setupManager(podcastModel: self.podcastViewModel)

            self.playButton.setTitle("Play", for: .normal)
            self.playButton.isUserInteractionEnabled = true
        }) { (error) in
            guard let error = error else { return }
            // Alert Error
            print(error.localizedDescription)
            self.playButton.setTitle("Play", for: .normal)
            self.playButton.isUserInteractionEnabled = true
        }
    }

    private func deletePodcast() {
        guard self.downloadButton.isSelected else { return }

        let alert = UIAlertController(title: "Are you sure you want to delete this podcast?", message: nil, preferredStyle: .alert)

        alert.addAction(title: "YEP! Delete it please/", style: .destructive, isEnabled: true) { _ in
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
        let iconSize = UIView.getValueScaledByScreenHeightFor(baseValue: 35)

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
        
        print(self.podcastViewModel)
        print(self.podcastViewModel.dictionary)

        self.playView.addSubview(self.downloadButton)

        let rightInset = UIView.getValueScaledByScreenWidthFor(baseValue: 20)
        downloadButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.playButton.snp.left).inset(-rightInset)
            make.centerY.equalTo(self.playButton.snp.centerY)
        }
    }
}
