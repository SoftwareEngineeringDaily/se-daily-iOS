//
//  EpisodeHeaderCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/30/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import UIKit
import Reusable

class EpisodeHeaderCell: UITableViewCell, Reusable {
	
	var titleLabel: UILabel!
	var guestThumb: UIImageView!
	var miscDetailsLabel: UILabel!
	
	var playButton: UIButton!
	var downloadButton: UIButton!
	
	var actionView: ActionView!
	
	var upvoteService: UpvoteService?
	var bookmarkService: BookmarkService?
	
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			updateUI()
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
		setupButtonsTargets()
	}
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	private func setupButtonsTargets() {
		actionView.upvoteButton.addTarget(self, action: #selector(EpisodeHeaderCell.upvoteTapped), for: .touchUpInside)
		actionView.bookmarkButton.addTarget(self, action: #selector(EpisodeHeaderCell.bookmarkTapped), for: .touchUpInside)
		actionView.commentButton.addTarget(self, action: #selector(EpisodeHeaderCell.commentTapped), for: .touchUpInside)
	}
	
	@objc func upvoteTapped() {
		let impact = UIImpactFeedbackGenerator()
		impact.impactOccurred()
		
		upvoteService?.UIDelegate = self
		upvoteService?.upvote()
	}
	
	@objc func bookmarkTapped() {
		let selection = UISelectionFeedbackGenerator()
		selection.selectionChanged()
		
		bookmarkService?.UIDelegate = self
		bookmarkService?.setBookmark()
	}
	@objc func commentTapped() {
		let notification = UINotificationFeedbackGenerator()
		notification.notificationOccurred(.success)
		actionView.commentShowCallback()
	}
}

extension EpisodeHeaderCell {
	private func setupLayout() {
		func setupTitleLabel() {
			titleLabel = UILabel()
			self.contentView.addSubview(titleLabel)
			titleLabel.numberOfLines = 3
			titleLabel.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 24))
		}
		func setupGuestThumb() {
			guestThumb = UIImageView()
			contentView.addSubview(guestThumb)
			guestThumb.contentMode = .scaleAspectFill
			guestThumb.clipsToBounds = true
			guestThumb.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 20)
			guestThumb.kf.indicatorType = .activity
		}
		func setupPlayButton() {
			playButton = UIButton()
			contentView.addSubview(playButton)
			
			playButton.setTitle("Play", for: .normal)
			playButton.setTitleColor(UIColor.white, for: .normal)
			playButton.setBackgroundColor(color: Stylesheet.Colors.base, forState: .normal)
			playButton.setImage(UIImage(named: "Triangle"), for: .normal)
			
			
			playButton.setTitle("Stop", for: .selected)
			playButton.setTitleColor(Stylesheet.Colors.base, for: .selected)
			playButton.setTitleColor(Stylesheet.Colors.base, for: .selected)
			playButton.setImage(UIImage(named: "Square"), for: .selected)
			
			playButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)
			playButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -10.0)
			playButton.backgroundColor = Stylesheet.Colors.base
			playButton.cornerRadius = 25.0
		}
		func setupDownloadButton() {
			downloadButton = UIButton()
			contentView.addSubview(downloadButton)
			downloadButton.setIcon(icon: .ionicons(.iosCloudDownloadOutline), iconSize: 25.0, color: Stylesheet.Colors.grey, forState: .normal)
			downloadButton.cornerRadius = 25.0
			downloadButton.backgroundColor = Stylesheet.Colors.light
			
		}
		func setupActionView() {
			actionView = ActionView()
			actionView.setupComponents(superview: contentView)
		}
	
		func setupContraints() {
			titleLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().offset(10)
				make.right.equalToSuperview().offset(10)
				make.top.equalToSuperview().offset(10)
			}
			guestThumb.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(titleLabel.snp_bottom)
				make.left.equalTo(titleLabel)
				make.width.equalTo(40.0)
				make.height.equalTo(40.0)
			}
			playButton.snp.makeConstraints { (make) -> Void in
				make.bottom.equalToSuperview().inset(130)
				make.top.equalTo(titleLabel.snp_bottom).offset(30.0)
				make.left.equalTo(titleLabel)
				make.width.equalTo(120.0)
				make.height.equalTo(50.0)
			}
			downloadButton.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(playButton.snp_bottom).offset(50.0)
				make.width.equalTo(50.0)
				make.height.equalTo(50.0)
			}
			actionView.setupContraints()
			actionView.actionStackView.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(playButton.snp_bottom)
				make.left.equalTo(titleLabel)
			}
		}
		
		setupTitleLabel()
		setupGuestThumb()
		setupPlayButton()
		setupDownloadButton()
		setupActionView()
		setupContraints()
	}
}

extension EpisodeHeaderCell {
	private func updateUI() {
		
		self.titleLabel.text = viewModel.podcastTitle
		
		func setupGuestThumb(imageURL: URL?) {
			guestThumb.kf.cancelDownloadTask()
			guard let imageURL = imageURL else {
				guestThumb.image = #imageLiteral(resourceName: "SEDaily_Logo")
				return
			}
			guestThumb.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
		}
		setupGuestThumb(imageURL: viewModel.guestImageURL)
	}
}


extension EpisodeHeaderCell: UpvoteServiceUIDelegate {
	func upvoteUIDidChange(isUpvoted: Bool, score: Int) {
		actionView.upvoteButton.isSelected = isUpvoted
		actionView.upvoteCountLabel.text = String(score)
		updateLabelStyle()
	}
	
	func upvoteUIImmediateUpdate() {
		guard let tempScore = Int(actionView.upvoteCountLabel.text ?? "0") else { return }
		actionView.upvoteCountLabel.text = actionView.upvoteButton.isSelected ? String(tempScore - 1) : String(tempScore + 1)
		actionView.upvoteButton.isSelected = !actionView.upvoteButton.isSelected
		updateLabelStyle()
	}
}

extension EpisodeHeaderCell {
	func updateLabelStyle() {
		actionView.upvoteCountLabel.textColor = actionView.upvoteButton.isSelected ? Stylesheet.Colors.base : Stylesheet.Colors.grey
		actionView.upvoteCountLabel.font = actionView.upvoteButton.isSelected ? UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13)) : UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
	}
}

extension EpisodeHeaderCell: BookmarkServiceUIDelegate {
	func bookmarkUIDidChange(isBookmarked: Bool) {
		actionView.bookmarkButton.isSelected = isBookmarked
	}
	func bookmarkUIImmediateUpdate() {
		actionView.bookmarkButton.isSelected = !actionView.bookmarkButton.isSelected
	}
}
