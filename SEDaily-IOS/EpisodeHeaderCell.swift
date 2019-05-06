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
	
	var separator: UIView!
	
	var playButton: UIButton!
	var downloadButton: UIButton!
	var relatedLinksButton: UIButton!
	
	var actionView: ActionView!
	
	var upvoteService: UpvoteService?
	var bookmarkService: BookmarkService?
	var downloadService: DownloadService? { didSet { downloadService?.UIDelegate = self }}
	
	var downloadButtonCallBack: (()-> Void) = {}
	var relatedLinksButtonCallBack: (()-> Void) = {}
	var playButtonCallBack: ((_ isPlaying: Bool)-> Void) = {_ in }
	
	
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			updateUI()
		}
	}
	
	var isPlaying: Bool = false { didSet {
		playButton.isSelected = isPlaying
		}}
	
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
		playButton.addTarget(self, action: #selector(EpisodeHeaderCell.playTapped), for: .touchUpInside)
		relatedLinksButton.addTarget(self, action: #selector(EpisodeHeaderCell.relatedLinksTapped), for: .touchUpInside)
		downloadButton.addTarget(self, action: #selector(EpisodeHeaderCell.downloadTapped), for: .touchUpInside)
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
	@objc func downloadTapped() {
		let notification = UINotificationFeedbackGenerator()
		notification.notificationOccurred(.success)
//		downloadService?.UIDelegate = self
		switch viewModel.isDownloaded {
		case true:
			downloadService?.deletePodcast()
		default:
			downloadService?.savePodcast()
		}
	}
	
	@objc func playTapped() {
		let notification = UINotificationFeedbackGenerator()
		notification.notificationOccurred(.success)
		playButtonCallBack(isPlaying)
		
	}
	
	@objc func relatedLinksTapped() {
		let notification = UINotificationFeedbackGenerator()
		notification.notificationOccurred(.success)
		relatedLinksButtonCallBack()
	}
}

extension EpisodeHeaderCell {
	private func setupLayout() {
		func setupLabels() {
			titleLabel = UILabel()
			self.contentView.addSubview(titleLabel)
			titleLabel.textColor = Stylesheet.Colors.dark
			titleLabel.numberOfLines = 3
			titleLabel.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 24))
			
			miscDetailsLabel = UILabel()
			contentView.addSubview(miscDetailsLabel)
			miscDetailsLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 11))
			miscDetailsLabel.textColor = Stylesheet.Colors.dark
		}
		func setupGuestThumb() {
			guestThumb = UIImageView()
			contentView.addSubview(guestThumb)
			guestThumb.contentMode = .scaleAspectFill
			guestThumb.clipsToBounds = true
			guestThumb.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 25)
			guestThumb.kf.indicatorType = .activity
		}
		func setupPlayButton() {
			playButton = UIButton()
			contentView.addSubview(playButton)
			
			playButton.borderWidth = 1.0
			playButton.borderColor = Stylesheet.Colors.base
			
			playButton.setTitle("Play", for: .normal)
			playButton.setTitleColor(UIColor.white, for: .normal)
			playButton.setBackgroundColor(color: Stylesheet.Colors.base, forState: .normal)
			playButton.setImage(UIImage(named: "Triangle"), for: .normal)
			
			
			playButton.setTitle("Stop", for: .selected)
			playButton.setTitleColor(Stylesheet.Colors.base, for: .selected)
			playButton.setBackgroundColor(color: .white, forState: .selected)
			playButton.setImage(UIImage(named: "Square"), for: .selected)
			
			playButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)
			playButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -10.0)
			playButton.backgroundColor = Stylesheet.Colors.base
			playButton.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 25.0)
		}
		func setupDownloadButton() {
			downloadButton = UIButton()
			contentView.addSubview(downloadButton)
			downloadButton.setIcon(icon: .ionicons(.iosCloudDownloadOutline), iconSize: 25.0, color: Stylesheet.Colors.dark, forState: .normal)
			downloadButton.setIcon(icon: .ionicons(.iosCloudDownload), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .selected)
			downloadButton.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 25.0)
			downloadButton.backgroundColor = Stylesheet.Colors.light
			
		}
		func setupRelatedLinksButton() {
			relatedLinksButton = UIButton()
			contentView.addSubview(relatedLinksButton)
			relatedLinksButton.setIcon(icon: .linearIcons(.link), iconSize: 21.0, color: Stylesheet.Colors.dark, forState: .normal)
			relatedLinksButton.setIcon(icon: .linearIcons(.link), iconSize: 21.0, color: Stylesheet.Colors.base, forState: .selected)
		}
		func setupActionView() {
			actionView = ActionView()
			actionView.setupComponents(superview: contentView)
		}
		func setupSeparator() {
			separator = UIView()
			contentView.addSubview(separator)
			separator.backgroundColor = Stylesheet.Colors.light
		}
	
		func setupContraints() {
			titleLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			}
			miscDetailsLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalTo(guestThumb.snp_right).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10.0))
				make.rightMargin.equalTo(playButton.snp_left).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10.0))
				make.centerY.equalTo(guestThumb.snp_centerY)
			}
			guestThumb.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(titleLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 20.0))
				make.left.equalTo(titleLabel)
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0))
			}
			playButton.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(titleLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 20.0))
				make.right.equalTo(downloadButton.snp_left).inset(UIView.getValueScaledByScreenWidthFor(baseValue: -10.0))
				
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 120.0))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0))
			}
			downloadButton.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(titleLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 20.0))
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0))
				make.right.equalToSuperview().inset((UIView.getValueScaledByScreenWidthFor(baseValue: 15.0)))
			}
			relatedLinksButton.snp.makeConstraints { (make) -> Void in
				make.centerY.equalTo(actionView.actionStackView)
				make.centerX.equalTo(downloadButton)
			}
			actionView.setupContraints()
			actionView.actionStackView.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(playButton.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.left.equalTo(titleLabel)
				make.bottom.equalTo(separator.snp_top)
			}
			separator.snp.makeConstraints { (make) -> Void in
				make.left.right.bottom.equalToSuperview()
				make.height.equalTo(5.0)
			}
		}
		
		setupLabels()
		setupGuestThumb()
		setupPlayButton()
		setupDownloadButton()
		setupRelatedLinksButton()
		setupActionView()
		setupSeparator()
		setupContraints()
	}
}

extension EpisodeHeaderCell {
	private func updateUI() {
		
		viewModel.getLastUpdatedAsDateWith { [weak self] (date) in
			guard let strongSelf = self else { return }
			setupMiscDetailsLabel(timeLength: nil, date: date, isDownloaded: strongSelf.viewModel.isDownloaded)
		}
		
		self.titleLabel.text = viewModel.podcastTitle
		func setupMiscDetailsLabel(timeLength: Int?, date: Date?, isDownloaded: Bool) {
			let dateString = date?.dateString() ?? ""
			miscDetailsLabel.text = dateString
		}
		
		func setupGuestThumb(imageURL: URL?) {
			guestThumb.kf.cancelDownloadTask()
			guard let imageURL = imageURL else {
				guestThumb.image = #imageLiteral(resourceName: "SEDaily_Logo")
				return
			}
			guestThumb.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
		}
		func updateUpvote() {
			actionView.upvoteCountLabel.text = String(viewModel.score)
			actionView.upvoteButton.isSelected = viewModel.isUpvoted
			actionView.upvoteCountLabel.textColor = actionView.upvoteButton.isSelected ? Stylesheet.Colors.base : Stylesheet.Colors.grey
			actionView.upvoteCountLabel.font = actionView.upvoteButton.isSelected ? UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13)) : UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
		}
		
		func updateBookmark() {
			actionView.bookmarkButton.isSelected = viewModel.isBookmarked
		}
		
		func updateDownloadButton() {
			downloadButton.isSelected = viewModel.isDownloaded
		}
		
		updateUpvote()
		updateBookmark()
		updateDownloadButton()
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

extension EpisodeHeaderCell: DownloadServiceUIDelegate {
	func downloadUIDidChange(progress: Int?, success: Bool?) {
		
		guard let progress = progress else {
			guard let success = success else { return }
			downloadButton.isUserInteractionEnabled = true
			downloadButton.isSelected = success
			downloadButton.setTitle("", for: .normal)
			downloadButton.setIcon(icon: .ionicons(.iosCloudDownload), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .selected)
			downloadButton.setIcon(icon: .ionicons(.iosCloudDownloadOutline), iconSize: 25.0, color: Stylesheet.Colors.dark, forState: .normal)
			downloadButton.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 25.0)
			downloadButton.backgroundColor = Stylesheet.Colors.light
			return
		}
		downloadButton.isUserInteractionEnabled = false
		let progressString: String = String(progress) + "%"
		downloadButton.titleLabel?.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 12))
		downloadButton.setTitle(String(progressString), for: .normal)
	}
}
