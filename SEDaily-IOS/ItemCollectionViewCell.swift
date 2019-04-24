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
			viewModel.getLastUpdatedAsDateWith { (date) in
				self.setupMiscDetailsLabel(timeLength: nil, date: date, isDownloaded: self.viewModel.isDownloaded)
			}
			self.loadImageView(imageURL: viewModel.featuredImageURL)
			// TODO: change into parsed html
			self.descriptionLabel.text = "Protein structure prediction is the process of predicting how a protein will fold by looking at genetic code. Protein structure prediction is a perfect field to approach through the application of deep learning, because"
			self.upvoteButton.isSelected = viewModel.isUpvoted
			print(viewModel.isUpvoted)
			self.upvoteCountLabel.text = String(viewModel.score)
		}
		
	}
	
	var upvoteService: UpvoteService?
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = .white
		setupImageView()
		setupLabels()
		setupUpvoteStackView()
		setupActionButtons()
		setupActionStackView()
		setupLayout()
		
	}
	
	
	private func setupImageView() {
		imageView = UIImageView()
		self.contentView.addSubview(imageView)
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 5)
		self.imageView.kf.indicatorType = .activity
		
	}
	
	private func setupLabels() {
		titleLabel = UILabel()
		self.contentView.addSubview(titleLabel)
		titleLabel.numberOfLines = 3
		titleLabel.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 17))
		
		miscDetailsLabel = UILabel()
		self.contentView.addSubview(miscDetailsLabel)
		miscDetailsLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 11))
		miscDetailsLabel.textColor = UIColor(hex: 0x8A8C8C)!
		
		descriptionLabel = UILabel()
		descriptionLabel.numberOfLines = 2
		descriptionLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
		self.contentView.addSubview(descriptionLabel)
	}
	
	func setupUpvoteStackView() {
		upvoteStackView.alignment = .center
		upvoteStackView.axis = .horizontal
		upvoteStackView.distribution = .fillEqually
		
		upvoteStackView.addArrangedSubview(upvoteButton)
		upvoteStackView.addArrangedSubview(upvoteCountLabel)
		print(self.viewModel.score)
		upvoteCountLabel.text = String(self.viewModel.score)
		upvoteButton.isSelected = self.viewModel.isUpvoted
		upvoteCountLabel.textColor = .lightGray
		upvoteCountLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
	}
	
	private func setupActionButtons() {
		upvoteButton.setIcon(icon: .ionicons(.iosHeartOutline), iconSize: 25.0, color: UIColor(hex: 0x979899)!, forState: .normal)
		upvoteButton.setIcon(icon: .ionicons(.iosHeart), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .selected)
		bookmarkButton.setImage(UIImage(named: "ios-bookmark"), for: .normal)
		downloadButton.setIcon(icon: .ionicons(.iosCloudDownloadOutline), iconSize: 25.0, color: UIColor(hex: 0x8A8C8C)!, forState: .normal)
		
		upvoteButton.addTarget(self, action:#selector(ItemCollectionViewCell.liked), for: .touchUpInside)
		bookmarkButton.addTarget(self, action:#selector(ItemCollectionViewCell.bookmarked), for: .touchUpInside)
		downloadButton.addTarget(self, action:#selector(ItemCollectionViewCell.downloaded), for: .touchUpInside)
	}
	
	private func setupActionStackView() {
		actionStackView.alignment = .center
		actionStackView.axis = .horizontal
		actionStackView.distribution = .fillEqually
		
		self.actionStackView.addArrangedSubview(upvoteStackView)
		self.actionStackView.addArrangedSubview(downloadButton)
		self.actionStackView.addArrangedSubview(bookmarkButton)
		
		self.contentView.addSubview(actionStackView)
	}

	private func setupLayout() {
		
		imageView.snp.makeConstraints { (make) -> Void in
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
	
	private func setupMiscDetailsLabel(timeLength: Int?, date: Date?, isDownloaded: Bool) {
		let dateString = date?.dateString() ?? ""
		if  isDownloaded {
			miscDetailsLabel.text = "\(dateString) (Downloaded)"
		} else {
			miscDetailsLabel.text = dateString
		}
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	private func loadImageView(imageURL: URL?) {
		self.imageView.kf.cancelDownloadTask()
		guard let imageURL = imageURL else {
			self.imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
			return
		}
		
		self.imageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
	}
	
	//MARK: Button handlers
	
	@objc func liked() {
		let impact = UIImpactFeedbackGenerator()
		impact.impactOccurred()
		upvoteService?.UIDelegate = self
		self?.upvoteService?.upvote()
	}
	
	@objc func bookmarked() {
		let selection = UISelectionFeedbackGenerator()
		selection.selectionChanged()
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
		skeletonTitleLabel = GradientContainerView(origin: imageView.bottomLeftPoint(), topInset: 15, width: 158, height: 14)
		self.contentView.addSubview(skeletonTitleLabel)
		skeletontimeDayLabel = GradientContainerView(origin: skeletonTitleLabel.bottomLeftPoint(), topInset: 15, width: 158, height: 14)
		self.contentView.addSubview(skeletontimeDayLabel)
		
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
	func UIDidChange(isUpvoted: Bool, score: Int) {
		upvoteButton.isSelected = isUpvoted
		upvoteCountLabel.text = String(score)
	}
}

