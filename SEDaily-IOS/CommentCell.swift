//
//  CommentCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/6/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit
import Reusable

class CommentCell: UITableViewCell, Reusable {
	
	var avatarImage: UIImageView!
	var authorLabel: UILabel!
	var contentLabel: UILabel!
	var dateLabel: UILabel!
	var verticalLine: UIView!
	
	var comment: Comment? {
		didSet {
			let prettyDate = comment?.getDatedCreatedPretty()
			dateLabel.text = prettyDate
			//contentLabel.attributedText = comment?.commentBody()
			contentLabel.text = comment?.content
			authorLabel.text = comment?.author.displayName()
			
			if let imageString = comment?.author.avatarUrl {
				let url = URL(string: imageString)
				avatarImage.kf.setImage(with: url)
			} else {
				avatarImage.image = UIImage(named: "profile-icon-9")
			}
			if comment?.deleted == true {
				contentLabel.textColor = UIColor.lightGray
			} else {
				//contentLabel.textColor = UIColor.black
			}
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}

extension CommentCell {
	private func setupLayout() {
		func setupLabels() {
			
			verticalLine = UIView()
			verticalLine.backgroundColor = Stylesheet.Colors.light
			contentView.addSubview(verticalLine)
			
			authorLabel = UILabel()
			self.contentView.addSubview(authorLabel)
			authorLabel.textColor = Stylesheet.Colors.base
			authorLabel.numberOfLines = 1
			authorLabel.font = UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
			
			contentLabel = UILabel()
			contentView.addSubview(contentLabel)
			contentLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 12))
			contentLabel.numberOfLines = 0
			contentLabel.textColor = Stylesheet.Colors.dark
			
			dateLabel = UILabel()
			contentView.addSubview(dateLabel)
			dateLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 12))
			dateLabel.textColor = Stylesheet.Colors.grey
			
		}
		func setupAvatarImage() {
			avatarImage = UIImageView()
			contentView.addSubview(avatarImage)
			avatarImage.contentMode = .scaleAspectFill
			avatarImage.clipsToBounds = true
			avatarImage.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 20)
			avatarImage.kf.indicatorType = .activity
		}
		func setupConstraints() {
			avatarImage.snp.makeConstraints { (make) -> Void in
				make.top.equalToSuperview()
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 40.0))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 40.0))
			}
			authorLabel.snp.makeConstraints { (make) -> Void in
				make.centerY.equalTo(avatarImage.snp_centerY)
				make.left.equalTo(avatarImage.snp_right).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10.0))
				make.rightMargin.equalTo(dateLabel.snp_left)
			}
			dateLabel.snp.makeConstraints { (make) -> Void in
				make.centerY.equalTo(avatarImage.snp_centerY)
				make.rightMargin.equalToSuperview()
			}
			contentLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalTo(authorLabel)
				make.top.equalTo(authorLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10.0))
				make.rightMargin.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 10.0))
			}
			
			verticalLine.snp.makeConstraints { (make) -> Void in
				make.width.equalTo(2.0)
				make.top.equalTo(avatarImage.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10.0))
				make.centerX.equalTo(avatarImage.snp_centerX)
				make.bottom.equalTo(contentLabel.snp_bottom)
			}
			
		}
		
		setupLabels()
		setupAvatarImage()
		setupConstraints()
	}
}
