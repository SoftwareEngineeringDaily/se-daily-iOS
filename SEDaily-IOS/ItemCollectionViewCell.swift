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
	let likeButton: UIButton = UIButton()
	let commentButton: UIButton = UIButton()
	let bookmarkButton: UIButton = UIButton()
	let downloadButton: UIButton = UIButton()
	let relatedLinksButton: UIButton = UIButton()
	
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			self.titleLabel.text = viewModel.podcastTitle
			viewModel.getLastUpdatedAsDateWith { (date) in
				self.setupMiscDetailsLabel(timeLength: nil, date: date, isDownloaded: self.viewModel.isDownloaded)
			}
			self.setupImageView(imageURL: viewModel.featuredImageURL)
			// TODO: change into parsed html
			self.descriptionLabel.text = "Protein structure prediction is the process of predicting how a protein will fold by looking at genetic code. Protein structure prediction is a perfect field to approach through the application of deep learning, because"
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
//		let newContentView = UIView(width: superview?.width ?? 100, height: 150)
//		self.contentView.frame = newContentView.frame
		self.backgroundColor = .white
		imageView = UIImageView()
		self.contentView.addSubview(imageView)
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 5)
		
		
		self.imageView.kf.indicatorType = .activity
		
		titleLabel = UILabel()
		self.contentView.addSubview(titleLabel)
		titleLabel.numberOfLines = 3
		titleLabel.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 16))

		miscDetailsLabel = UILabel()
		self.contentView.addSubview(miscDetailsLabel)
		miscDetailsLabel.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 10))
		
		descriptionLabel = UILabel()
		descriptionLabel.numberOfLines = 2
		self.contentView.addSubview(descriptionLabel)

		self.contentView.addSubview(actionStackView)
		
//		let iconSize =
		
		likeButton.setIcon(icon: .ionicons(.iosHeartOutline), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .normal)
	
		bookmarkButton.setIcon(icon: .ionicons(.iosBookmarksOutline), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .normal)
		
		
		downloadButton.setIcon(icon: .ionicons(.iosCloudDownloadOutline), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .normal)
		setupLayout()
		
	}
	
	private func setupLayout() {
		
		imageView.snp.makeConstraints { (make) -> Void in
			make.left.equalToSuperview().inset(10)
			make.top.equalToSuperview().inset(10)
			make.width.equalTo(80)
			make.height.equalTo(80)
		}
		
		titleLabel.snp.makeConstraints { (make) ->Void in
			make.top.equalTo(imageView)
			make.rightMargin.equalTo(contentView).inset(10.0)
			make.left.equalTo(imageView.snp.right).offset(10.0)
		}
		
		miscDetailsLabel.snp.makeConstraints { (make) ->Void in
			make.top.equalTo(titleLabel.snp.bottom).offset(5.0)
			make.left.equalTo(titleLabel)
		}
		
		descriptionLabel.snp.makeConstraints { (make) ->Void in
			make.top.equalTo(imageView.snp.bottom).offset(10.0)
			make.rightMargin.equalTo(contentView).inset(10.0)
			make.left.equalTo(imageView)
		}
		
		actionStackView.snp.makeConstraints { (make) ->Void in
			make.bottom.equalTo(contentView).inset(0.0)
			make.left.equalTo(imageView)
		}
	setupStackView()
	}
	
	private func setupStackView() {
		actionStackView.alignment = .center
		actionStackView.axis = .horizontal
		actionStackView.distribution = .fillEqually
		actionStackView.spacing = 20.0.cgFloat
		
		
		self.actionStackView.addArrangedSubview(likeButton)
		self.actionStackView.addArrangedSubview(bookmarkButton)
		self.actionStackView.addArrangedSubview(downloadButton)
		

//		self.stackView.addArrangedSubview(emailTextField)
//		self.stackView.addArrangedSubview(usernameTextField)
//		self.stackView.addArrangedSubview(passwordTextField)
		
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	private func setupImageView(imageURL: URL?) {
		self.imageView.kf.cancelDownloadTask()
		guard let imageURL = imageURL else {
			self.imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
			return
		}
		
		self.imageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
	}
	
	private func setupMiscDetailsLabel(timeLength: Int?, date: Date?, isDownloaded: Bool) {
		let dateString = date?.dateString() ?? ""
		if  isDownloaded {
			miscDetailsLabel.text = "\(dateString) (Downloaded)"
		} else {
			miscDetailsLabel.text = dateString
		}
		
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

