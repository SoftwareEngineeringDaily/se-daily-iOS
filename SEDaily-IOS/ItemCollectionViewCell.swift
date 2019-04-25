//
//  ItemCollectionViewCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/18/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation

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
	let downloadButton: UIButton = UIButton()
	let relatedLinksButton: UIButton = UIButton()
	
	let upvoteCountLabel: UILabel = UILabel()
	let upvoteStackView: UIStackView = UIStackView()
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			self.titleLabel.text = viewModel.podcastTitle
			updateUI()
		}
	}
	
	var upvoteService: UpvoteService?
	var bookmarkService: BookmarkService?
	
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
		upvoteButton.addTarget(self, action:#selector(ItemCollectionViewCell.liked), for: .touchUpInside)
		bookmarkButton.addTarget(self, action:#selector(ItemCollectionViewCell.bookmarked), for: .touchUpInside)
		downloadButton.addTarget(self, action:#selector(ItemCollectionViewCell.downloaded), for: .touchUpInside)
	}
	
	@objc func liked() {
		let impact = UIImpactFeedbackGenerator()
		impact.impactOccurred()
		upvoteService?.UIDelegate = self
		upvoteService?.upvote()
	}
	
	@objc func bookmarked() {
		let selection = UISelectionFeedbackGenerator()
		selection.selectionChanged()
		bookmarkService?.UIDelegate = self
		bookmarkService?.setBookmark()
	}
	
	@objc func downloaded() {
		let notification = UINotificationFeedbackGenerator()
		notification.notificationOccurred(.success)
	}
	
	// MARK: Skeleton
	var skeletonImageView: GradientContainerView!
	var skeletonTitleLabel: GradientContainerView!
	var skeletontimeDayLabel: GradientContainerView!
	
	private func setupSkeletonView() {
		self.skeletonImageView = GradientContainerView(frame: self.imageView.frame)
		self.skeletonImageView.cornerRadius = self.imageView.cornerRadius
		self.skeletonImageView.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
		self.contentView.addSubview(skeletonImageView)
		skeletonTitleLabel = GradientContainerView(frame: self.titleLabel.frame)
		self.contentView.addSubview(skeletonTitleLabel)
		skeletontimeDayLabel = GradientContainerView(frame: self.descriptionLabel.frame)
		print(skeletontimeDayLabel.frame)
		skeletontimeDayLabel.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
		self.contentView.addSubview(skeletontimeDayLabel)
		
		skeletontimeDayLabel.snp.makeConstraints { (make) -> Void in
			make.top.equalTo(imageView.snp.bottom).offset(10.0)
			make.rightMargin.equalTo(contentView).inset(10.0)
			make.left.equalTo(imageView)
		}
		
		print(skeletontimeDayLabel.frame)
		print(skeletonImageView)
		
		let baseColor = self.skeletonImageView.backgroundColor!
		let gradients = baseColor.getGradientColors(brightenedBy: 1.07)
		self.skeletonImageView.gradientLayer.colors = gradients
		self.skeletonTitleLabel.gradientLayer.colors = gradients
		self.skeletontimeDayLabel.gradientLayer.colors = gradients
	}
	
	func setupSkeletonCell() {
		self.setupSkeletonView()
		self.slide(to: .right)
	}
}

extension ItemCollectionViewCell: GradientsOwner {
	var gradientLayers: [CAGradientLayer] {
		return [skeletonImageView.gradientLayer,
						skeletonTitleLabel.gradientLayer,
						skeletontimeDayLabel.gradientLayer
		]
	}
}


extension ItemCollectionViewCell: UpvoteServiceUIDelegate {
	func upvoteUIDidChange(isUpvoted: Bool, score: Int) {
		upvoteButton.isSelected = isUpvoted
		upvoteCountLabel.text = String(score)
		upvoteCountLabel.textColor = upvoteButton.isSelected ? Stylesheet.Colors.base : Stylesheet.Colors.grey
		upvoteCountLabel.font = upvoteButton.isSelected ? UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13)) : UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
	}
}

extension ItemCollectionViewCell: BookmarkServiceUIDelegate {
	func bookmarkUIDidChange(isBookmarked: Bool) {
		self.bookmarkButton.isSelected = isBookmarked
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
			imageOverlay.backgroundColor = UIColor(hexString: "0x000000", transparency: 0.03)
		}
		
		func setupLabels() {
			titleLabel = UILabel()
			contentView.addSubview(titleLabel)
			titleLabel.numberOfLines = 3
			titleLabel.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 17))
			
			miscDetailsLabel = UILabel()
			contentView.addSubview(miscDetailsLabel)
			miscDetailsLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 11))
			miscDetailsLabel.textColor = UIColor(hex: 0x8A8C8C)!
			
			descriptionLabel = UILabel()
			descriptionLabel.numberOfLines = 2
			descriptionLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
			contentView.addSubview(descriptionLabel)
		}
		
		func setupActionButtons() {
			upvoteButton.setIcon(icon: .ionicons(.iosHeartOutline), iconSize: 25.0, color: Stylesheet.Colors.grey, forState: .normal)
			upvoteButton.setIcon(icon: .ionicons(.iosHeart), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .selected)
			bookmarkButton.setImage(UIImage(named: "ios-bookmark"), for: .normal)
			bookmarkButton.setImage(UIImage(named: "ios-bookmark-fill"), for: .selected)
			
			downloadButton.setIcon(icon: .ionicons(.iosCloudDownloadOutline), iconSize: 25.0, color: Stylesheet.Colors.grey, forState: .normal)
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
			actionStackView.addArrangedSubview(downloadButton)
			actionStackView.addArrangedSubview(bookmarkButton)
			
			contentView.addSubview(actionStackView)
		}
		
		func setupConstraints() {
			imageView.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().inset(10)
				make.top.equalToSuperview().inset(10)
				make.width.equalTo(80)
				make.height.equalTo(80)
			}
			
			imageOverlay.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().inset(10)
				make.top.equalToSuperview().inset(10)
				make.width.equalTo(80)
				make.height.equalTo(80)
			}
			
			titleLabel.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(imageView)
				make.rightMargin.equalTo(contentView).inset(10.0)
				make.left.equalTo(imageView.snp.right).offset(10.0)
			}
			
			miscDetailsLabel.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(titleLabel.snp.bottom).offset(5.0)
				make.left.equalTo(titleLabel)
			}
			
			descriptionLabel.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(imageView.snp.bottom).offset(10.0)
				make.rightMargin.equalTo(contentView).inset(10.0)
				make.left.equalTo(imageView)
			}
			
			actionStackView.snp.makeConstraints { (make) -> Void in
				make.bottom.equalTo(contentView).inset(0.0)
				make.left.equalTo(imageView)
			}
			
			upvoteButton.snp.makeConstraints { (make) -> Void in
				make.right.equalTo(upvoteCountLabel.snp.left)
			}
		}
		
		setupImageView()
		setupLabels()
		setupActionButtons()
		setupUpvoteStackView()
		setupActionStackView()
		setupConstraints()
	}
}


extension ItemCollectionViewCell {
	private func updateUI() {
		
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
			miscDetailsLabel.text = dateString
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
		
		loadImageView(imageURL: viewModel.featuredImageURL)
		viewModel.getLastUpdatedAsDateWith { (date) in
			setupMiscDetailsLabel(timeLength: nil, date: date, isDownloaded: self.viewModel.isDownloaded)
		}
		setupDescriptionLabel()
		updateUpvote()
		updateBookmark()
		
	}
}
