//
//  CommentCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/6/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//


import UIKit
import Reusable

protocol CommentReplyTableViewCellDelegate: class {
	func replyToCommentPressed(comment: Comment)
}
class CommentCell: UITableViewCell, Reusable {
	
	var avatarImage: UIImageView!
	var authorLabel: UILabel!
	var contentLabel: UILabel!
	var dateLabel: UILabel!
	var verticalLine: UIView!
	var replyButton: UIButton!
	// Update for reply cell
	var isReplyCell: Bool = false {
		didSet {
			replyButton.isHidden = isReplyCell
			avatarImage.snp.updateConstraints { (make) -> Void in
				let leftPadding: CGFloat = isReplyCell ? 55.0 : 15.0
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: leftPadding))
			}
		}
	}
	weak var delegate: CommentReplyTableViewCellDelegate?
	
	
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
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		setupLayout()
		replyButton.addTarget(self, action: #selector(CommentCell.replyTapped), for: .touchUpInside)
	}
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
	@objc func replyTapped(sender: UIButton) {
		if let comment = comment {
			delegate?.replyToCommentPressed(comment: comment)
		}
	}
	
}

extension CommentCell {
	
	
	
	private func setupLayout() {
		func setupLabels() {
			
			verticalLine = UIView()
			verticalLine.backgroundColor = .clear
			contentView.addSubview(verticalLine)
			
			authorLabel = UILabel()
			self.contentView.addSubview(authorLabel)
			authorLabel.textColor = Stylesheet.Colors.dark
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
			
			replyButton = UIButton()
			contentView.addSubview(replyButton)
			replyButton.setTitleColor(Stylesheet.Colors.base, for: .normal)
			replyButton.setTitle("Reply", for: .normal)
			replyButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
			
			
		}
		func setupAvatarImage() {
			avatarImage = UIImageView()
			contentView.addSubview(avatarImage)
			avatarImage.contentMode = .scaleAspectFill
			avatarImage.clipsToBounds = true
			avatarImage.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 15)
			avatarImage.kf.indicatorType = .activity
		}
		
		func setupConstraints() {
			avatarImage.snp.makeConstraints { (make) -> Void in
				make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 5.0))
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 30.0))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 30.0))
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
				
			}
			
			replyButton.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(contentLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 5.0))
				make.left.equalTo(authorLabel)
				make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 5.0))
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
