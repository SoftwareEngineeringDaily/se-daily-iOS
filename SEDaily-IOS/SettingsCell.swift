//
//  NotificationTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Keith Holliday on 4/2/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import Reusable

class SettingsCell: UITableViewCell, Reusable {
	public var cellLabel: UILabel!
	var separator: UIView!
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		cellLabel = UILabel()
		cellLabel.baselineAdjustment = .alignCenters
		cellLabel.numberOfLines = 0
		cellLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
		cellLabel.textColor = Stylesheet.Colors.dark

		
		self.contentView.addSubview(cellLabel)
		setupSeparator()
		
		cellLabel.snp.makeConstraints { (make) in
			make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			make.centerY.equalToSuperview()
			make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
		}
		
		separator.snp.makeConstraints { (make) -> Void in
			make.left.right.bottom.equalToSuperview()
			make.height.equalTo(2.0)
		}
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	func setupSeparator() {
		separator = UIView()
		contentView.addSubview(separator)
		separator.backgroundColor = Stylesheet.Colors.light
	}
}
