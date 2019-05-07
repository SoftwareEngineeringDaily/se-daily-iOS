//
//  ProfileCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/7/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit
import Reusable

class ProfileCell: UITableViewCell, Reusable {
	
	var avatarImage: UIImageView!
	var nameLabel: UILabel!
	var bioLabel: UILabel!
	var linkLabel: UILabel!
	var usernameOrEmailLabel: UILabel!
	var separator: UIView!
	
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
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
	
	func setupAvatar(imageURL: URL?) {
		avatarImage.kf.cancelDownloadTask()
		guard let imageURL = imageURL else {
			avatarImage.image = #imageLiteral(resourceName: "SEDaily_Logo")
			return
		}
		avatarImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
	}
	
}

extension ProfileCell {
	private func setupLayout() {
		func setupAvatarImage(){
			avatarImage = UIImageView()
			contentView.addSubview(avatarImage)
			avatarImage.contentMode = .scaleAspectFill
			avatarImage.clipsToBounds = true
			avatarImage.borderWidth = UIView.getValueScaledByScreenWidthFor(baseValue: 1)
			avatarImage.borderColor = Stylesheet.Colors.base
			avatarImage.cornerRadius = UIView.getValueScaledByScreenWidthFor(baseValue: 50)
			avatarImage.kf.indicatorType = .activity
		}
		func setupLabels(){
			nameLabel = UILabel()
			contentView.addSubview(nameLabel)
			nameLabel.textColor = Stylesheet.Colors.dark
			nameLabel.numberOfLines = 3
			nameLabel.font = UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 30))
			
			usernameOrEmailLabel = UILabel()
			contentView.addSubview(usernameOrEmailLabel)
			usernameOrEmailLabel.textColor = Stylesheet.Colors.grey
			usernameOrEmailLabel.numberOfLines = 0
			usernameOrEmailLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 11))
			
			
			bioLabel = UILabel()
			contentView.addSubview(bioLabel)
			bioLabel.textColor = Stylesheet.Colors.dark
			bioLabel.numberOfLines = 0
			bioLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
			
			linkLabel = UILabel()
			contentView.addSubview(linkLabel)
			linkLabel.textColor = Stylesheet.Colors.base
			linkLabel.numberOfLines = 0
			linkLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
		}
		func setupSeparator() {
			separator = UIView()
			contentView.addSubview(separator)
			separator.backgroundColor = Stylesheet.Colors.light
		}
		
		func setupConstraints() {
			avatarImage.snp.makeConstraints { (make) -> Void in
				make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 100.0))
				make.height.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 100.0))
				make.centerX.equalToSuperview()
			}
			nameLabel.snp.makeConstraints { (make) -> Void in
				make.top.equalTo(avatarImage.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.centerX.equalTo(avatarImage.snp_centerX)
			}
			usernameOrEmailLabel.snp.makeConstraints { (make) -> Void in
				make.centerX.equalTo(avatarImage.snp_centerX)
				make.top.equalTo(nameLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 5.0))
				
			}
			bioLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.top.equalTo(usernameOrEmailLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				
			}
			linkLabel.snp.makeConstraints { (make) -> Void in
				make.left.equalTo(bioLabel)
				make.top.equalTo(bioLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
				make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			}
			separator.snp.makeConstraints { (make) -> Void in
				make.left.right.bottom.equalToSuperview()
				make.height.equalTo(5.0)
			}
		}
		setupAvatarImage()
		setupLabels()
		setupSeparator()
		setupConstraints()
		
	}
}
