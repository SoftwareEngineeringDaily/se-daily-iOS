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
		//setupButtonsTargets()
	}
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
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
			guestThumb.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 20)
			guestThumb.kf.indicatorType = .activity
		}
		func setupPlayButton() {
			playButton = UIButton()
			contentView.addSubview(playButton)
			playButton.setTitle("Play", for: .normal)
			playButton.setTitleColor(UIColor.white, for: .normal)
			playButton.setImage(UIImage(named: "Triangle"), for: .normal)
			playButton.backgroundColor = Stylesheet.Colors.base
			playButton.cornerRadius = 10.0
			//playButton.clipsToBounds = true
		}
		
		
		func setupContraints() {
			titleLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().offset(10)
				make.rightMargin.equalToSuperview().offset(-10)
				make.top.equalToSuperview().offset(10)
				//make.bottom.equalToSuperview().inset(10)
			}
			guestThumb.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(titleLabel.snp_bottom)
				make.left.equalTo(titleLabel)
				make.width.equalTo(30.0)
				make.height.equalTo(30.0)
			}
			playButton.snp.makeConstraints { (make) -> Void in
				make.bottom.equalToSuperview().inset(10)
				make.top.equalTo(titleLabel.snp_bottom).offset(30.0)
				make.left.equalTo(titleLabel)
				make.width.equalTo(114.0)
				make.height.equalTo(47.0)
			}
		}
		setupTitleLabel()
		setupGuestThumb()
		setupPlayButton()
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
