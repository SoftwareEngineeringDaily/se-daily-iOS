//
//  ItemCollectionViewCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/18/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
import AVFoundation

import UIKit
import SnapKit
import KTResponsiveUI
import Skeleton
import Kingfisher

class ItemCollectionViewCell: UICollectionViewCell {
	var imageView: UIImageView!
	var imageOverlay: UIView!
	var titleLabel: UILabel!
	var miscDetailsLabel: UILabel!
	var descriptionLabel: UILabel!
	
	let actionStackView: UIStackView = UIStackView()
	let upvoteButton: UIButton = UIButton()
	let commentButton: UIButton = UIButton()
	let bookmarkButton: UIButton = UIButton()
	
	var commentShowCallback: (()-> Void) = {}
	
	let upvoteCountLabel: UILabel = UILabel()

	let upvoteStackView: UIStackView = UIStackView()
	
	let progressBar: UIProgressView = UIProgressView()
	
	// MARK: Skeleton
	var skeletonImageView: GradientContainerView!
	var skeletonTitleLabel: GradientContainerView!
	var skeletontimeDayLabel: GradientContainerView!
	var skeletonTitleLabelNextLine: GradientContainerView!
	var skeletontimeDayLabelNextLine: GradientContainerView!
	
	
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			updateUI()
		}
	}
	
	var upvoteService: UpvoteService?
	var bookmarkService: BookmarkService?

	var playProgress: PlayProgress?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayout()
		setupButtonsTargets()
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	//MARK: Button handlers
	
	private func setupButtonsTargets() {
		upvoteButton.addTarget(self, action: #selector(ItemCollectionViewCell.upvoteTapped), for: .touchUpInside)
		bookmarkButton.addTarget(self, action: #selector(ItemCollectionViewCell.bookmarkTapped), for: .touchUpInside)
		commentButton.addTarget(self, action: #selector(ItemCollectionViewCell.commentTapped), for: .touchUpInside)
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
		commentShowCallback()
	}
	
	func setupSkeletonCell() {
		self.setupSkeletonView()
		self.slide(to: .right)
	}
}

extension ItemCollectionViewCell: UpvoteServiceUIDelegate {
	func upvoteUIDidChange(isUpvoted: Bool, score: Int) {
		upvoteButton.isSelected = isUpvoted
		upvoteCountLabel.text = String(score)
		updateLabelStyle()
	}
	
	func upvoteUIImmediateUpdate() {
		guard let tempScore = Int(upvoteCountLabel.text ?? "0") else { return }
		upvoteCountLabel.text = upvoteButton.isSelected ? String(tempScore - 1) : String(tempScore + 1)
		upvoteButton.isSelected = !upvoteButton.isSelected
		updateLabelStyle()
	}
}

extension ItemCollectionViewCell {
	func updateLabelStyle() {
		upvoteCountLabel.textColor = upvoteButton.isSelected ? Stylesheet.Colors.base : Stylesheet.Colors.grey
		upvoteCountLabel.font = upvoteButton.isSelected ? UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13)) : UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
	}
}

extension ItemCollectionViewCell: BookmarkServiceUIDelegate {
	func bookmarkUIDidChange(isBookmarked: Bool) {
		bookmarkButton.isSelected = isBookmarked
	}
	func bookmarkUIImmediateUpdate() {
		bookmarkButton.isSelected = !bookmarkButton.isSelected
	}
}

extension ItemCollectionViewCell {
	private func setupLayout() {
		
		backgroundColor = .white
		
		func setupImageView() {
			imageView = UIImageView()
			contentView.addSubview(imageView)
			imageView.contentMode = .scaleAspectFill
			imageView.clipsToBounds = true
			imageView.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 5)
			imageView.kf.indicatorType = .activity
			
			imageOverlay = UIView()
			contentView.addSubview(imageOverlay)
			imageOverlay.clipsToBounds = true
			imageOverlay.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 5)
			imageOverlay.backgroundColor = Stylesheet.Colors.lightTransparent
		}
		
		func setupLabels() {
			titleLabel = UILabel()
			contentView.addSubview(titleLabel)
			titleLabel.numberOfLines = 3
			titleLabel.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 17))
			titleLabel.textColor = Stylesheet.Colors.dark
			
			miscDetailsLabel = UILabel()
			contentView.addSubview(miscDetailsLabel)
			miscDetailsLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 11))
			miscDetailsLabel.textColor = Stylesheet.Colors.dark
			
			descriptionLabel = UILabel()
			descriptionLabel.numberOfLines = 2
			descriptionLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
			descriptionLabel.textColor = Stylesheet.Colors.dark
			contentView.addSubview(descriptionLabel)
		}
		
		func setupActionButtons() {
			upvoteButton.setIcon(icon: .ionicons(.iosHeartOutline), iconSize: 25.0, color: Stylesheet.Colors.grey, forState: .normal)
			upvoteButton.setIcon(icon: .ionicons(.iosHeart), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .selected)
			
			bookmarkButton.setImage(UIImage(named: "ios-bookmark"), for: .normal)
			bookmarkButton.setImage(UIImage(named: "ios-bookmark-fill"), for: .selected)
			
			commentButton.setIcon(icon: .ionicons(.iosChatbubbleOutline), iconSize: 30.0, color: Stylesheet.Colors.grey, forState: .normal)
			commentButton.setIcon(icon: .ionicons(.iosChatbubble), iconSize: 30.0, color: Stylesheet.Colors.base, forState: .selected)
			

		}
		
		func setupProgressBar() {
			progressBar.progressTintColor = Stylesheet.Colors.base
			progressBar.trackTintColor = Stylesheet.Colors.gray
			progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 1)
			progressBar.isHidden = true
			contentView.addSubview(progressBar)
		}
		
		func setupUpvoteStackView() {
			upvoteStackView.alignment = .center
			upvoteStackView.axis = .horizontal
			upvoteStackView.distribution = .fillEqually
			
			upvoteStackView.addArrangedSubview(upvoteButton)
			upvoteStackView.addArrangedSubview(upvoteCountLabel)
		}
		
		func setupActionStackView() {
			actionStackView.alignment = .center
			actionStackView.axis = .horizontal
			actionStackView.distribution = .fillEqually
			
			actionStackView.addArrangedSubview(upvoteStackView)
			actionStackView.addArrangedSubview(commentButton)
			actionStackView.addArrangedSubview(bookmarkButton)
			
			contentView.addSubview(actionStackView)
		}
		
		
		func setupConstraints() {
			imageView.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:10))
				make.top.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:10))
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 80))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 80))
			}
			
			
			imageOverlay.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:10))
				make.top.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:10))
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue:80))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue:80))
			}
			
			titleLabel.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(imageView)
				make.rightMargin.equalTo(contentView).inset(UIView.getValueScaledByScreenWidthFor(baseValue:10.0))
				make.left.equalTo(imageView.snp.right).offset(UIView.getValueScaledByScreenWidthFor(baseValue:10.0))
			}
			
			miscDetailsLabel.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(titleLabel.snp.bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue:5.0))
				make.left.equalTo(titleLabel)
			}
			
			descriptionLabel.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(imageView.snp.bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue:10.0))
				make.rightMargin.equalTo(contentView).inset(UIView.getValueScaledByScreenWidthFor(baseValue:10.0))
				make.left.equalTo(imageView)
			}
			
			actionStackView.snp.makeConstraints { (make) -> Void in
				make.bottom.equalTo(contentView).inset(UIView.getValueScaledByScreenWidthFor(baseValue:5.0))
				make.left.equalTo(imageView)
			}
			
			upvoteButton.snp.makeConstraints { (make) -> Void in
				make.right.equalTo(upvoteCountLabel.snp.left)
			}
			
			progressBar.snp.makeConstraints { (make) -> Void in
				make.width.equalTo(contentView)
				make.rightMargin.equalTo(contentView)
				make.leftMargin.equalTo(contentView)
				make.bottom.equalTo(contentView)
			}
		}
		
		setupImageView()
		setupLabels()
		setupActionButtons()
		setupProgressBar()
		setupUpvoteStackView()
		setupActionStackView()
		setupConstraints()
	}
}

extension ItemCollectionViewCell {
	private func updateUI() {
		
		self.titleLabel.text = viewModel.podcastTitle
		
		func loadImageView(imageURL: URL?) {
			imageView.kf.cancelDownloadTask()
			guard let imageURL = imageURL else {
				imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
				return
			}
			imageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
		}
		
		func setupMiscDetailsLabel(timeLength: Int?, date: Date?, isDownloaded: Bool) {
			let dateString = date?.dateString() ?? ""
			let timeLeftString = isProgressSet() ? createTimeLeftString() : ""
			miscDetailsLabel.text = dateString + timeLeftString
		}
		
		func createTimeLeftString()->String {
			return " · " + Helpers.createTimeString(time: playProgress?.timeLeft ?? 0.0, units: [.minute]) + " " + L10n.timeLeft
		}
		
		func setupDescriptionLabel() {
			var str: String!
			// Due to asynchronuous nature of decoding html content, this is a better way to do it
			DispatchQueue.global(qos: .background).async { [weak self] in
				str = self?.viewModel.podcastDescription
				DispatchQueue.main.async {
					
					self?.descriptionLabel.text = str
				}
			}
			
		}
		
		func updateUpvote() {
			upvoteCountLabel.text = String(viewModel.score)
			upvoteButton.isSelected = viewModel.isUpvoted
			upvoteCountLabel.textColor = upvoteButton.isSelected ? Stylesheet.Colors.base : Stylesheet.Colors.grey
			upvoteCountLabel.font = upvoteButton.isSelected ? UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13)) : UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
		}
		
		func updateBookmark() {
			bookmarkButton.isSelected = viewModel.isBookmarked
		}
		
		func updateProgressBar() {
			guard let playProgress = playProgress else { return }
			if isProgressSet() {
			progressBar.progress = playProgress.progressFraction
			progressBar.isHidden = false
			} else {
				progressBar.isHidden = true
			}
		}
		
		func isProgressSet()->Bool {
			guard let playProgress = playProgress else { return false }
			return playProgress.progressFraction > Float(0.005)
		}
		
		loadImageView(imageURL: viewModel.featuredImageURL)
		viewModel.getLastUpdatedAsDateWith { [weak self] (date) in
			guard let strongSelf = self else { return }
			setupMiscDetailsLabel(timeLength: nil, date: date, isDownloaded: strongSelf.viewModel.isDownloaded)
		}
		updateProgressBar()
		setupDescriptionLabel()
		updateUpvote()
		updateBookmark()
	}
}

extension ItemCollectionViewCell {
	func setupSkeletonView() {
		
		func scale(_ value: CGFloat)-> CGFloat {
			return UIView.getValueScaledByScreenWidthFor(baseValue: value)
		}
		
		skeletonImageView = GradientContainerView(frame: CGRect(x: scale(10.0), y: scale(10.0), width: scale(80.0), height: scale(80.0)))
		skeletonImageView.cornerRadius = self.imageView.cornerRadius
		skeletonImageView.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
		contentView.addSubview(skeletonImageView)
		skeletonTitleLabel = GradientContainerView(frame: CGRect(x: scale(100.0), y: scale(10.0), width: scale(200.0), height: scale(15.0)))
		skeletonTitleLabelNextLine = GradientContainerView(frame: CGRect(x: scale(100.0), y: scale(40.0), width: scale(200.0), height: scale(15.0)))
		contentView.addSubview(skeletonTitleLabel)
		contentView.addSubview(skeletonTitleLabelNextLine)
		skeletontimeDayLabel = GradientContainerView(origin: skeletonImageView.bottomLeftPoint(), topInset: scale(10), width: scale(350), height: scale(10))
		skeletontimeDayLabelNextLine = GradientContainerView(origin: skeletonImageView.bottomLeftPoint(), topInset: scale(25), width: scale(350), height: scale(10))
		contentView.addSubview(skeletontimeDayLabel)
		contentView.addSubview(skeletontimeDayLabelNextLine)
		
		let baseColor = skeletonImageView.backgroundColor!
		let gradients = baseColor.getGradientColors(brightenedBy: 1.07)
		skeletonImageView.gradientLayer.colors = gradients
		skeletonTitleLabel.gradientLayer.colors = gradients
		skeletonTitleLabelNextLine.gradientLayer.colors = gradients
		skeletontimeDayLabel.gradientLayer.colors = gradients
		skeletontimeDayLabelNextLine.gradientLayer.colors = gradients
	}
}

extension ItemCollectionViewCell: GradientsOwner {
	var gradientLayers: [CAGradientLayer] {
		return [skeletonImageView.gradientLayer,
						skeletonTitleLabel.gradientLayer,
						skeletonTitleLabelNextLine.gradientLayer,
						skeletontimeDayLabel.gradientLayer,
						skeletontimeDayLabelNextLine.gradientLayer
		]
	}
}
