//
//  CommentReplyTableViewCell.swift
//  SEDaily-IOS
//
//  Created by jason on 2/2/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class CommentReplyTableViewCell: UITableViewCell {
	
	@IBOutlet weak var avatarImage: UIImageView!
	@IBOutlet weak var contentLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	var comment: Comment? {
		didSet {
			contentLabel.attributedText = comment?.commentBody()
			let prettyDate = comment?.getDatedCreatedPretty()
			dateLabel.text = prettyDate
			usernameLabel.text = comment?.author.displayName()
			
			if let imageString = comment?.author.avatarUrl {
				let url = URL(string: imageString)
				avatarImage.kf.setImage(with: url)
			} else {
				avatarImage.image = UIImage(named: "profile-icon-9")
			}
			
			if comment?.deleted == true {
				contentLabel.textColor = UIColor.lightGray
			} else {
				contentLabel.textColor = UIColor.black
			}
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupLayout()
		
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}

extension CommentReplyTableViewCell {
	private func setupLayout() {
		func setupAvatarImage() {
			avatarImage.contentMode = .scaleAspectFill
			avatarImage.cornerRadius = avatarImage.frame.height / 2.0
			avatarImage.clipsToBounds = true
		}
		setupAvatarImage()
	}
}
