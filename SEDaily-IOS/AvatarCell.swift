//
//  AvatarCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/5/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//


import UIKit
import Reusable

class AvatarCell: UITableViewCell, Reusable {
	private var avatarImageView: UIImageView!
	
	var avatarURL: URL? = nil {
		didSet {
			setupLayout()
			setupAvatar(imageURL: avatarURL)
		}
	}
}

extension AvatarCell {
	private func setupLayout() {
		self.selectionStyle = .none
		
		avatarImageView = UIImageView()
		contentView.addSubview(avatarImageView)
		avatarImageView.contentMode = .scaleAspectFill
		avatarImageView.clipsToBounds = true
		avatarImageView.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 50)
		avatarImageView.kf.indicatorType = .activity
		
		avatarImageView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 100.0))
			make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 100.0))
			make.centerX.equalToSuperview()
		}
	}
	private func setupAvatar(imageURL: URL?) {
		avatarImageView.kf.cancelDownloadTask()
		avatarImageView.image = nil
		guard let imageURL = imageURL else {
			avatarImageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
			return
		}
		avatarImageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
	}
}
