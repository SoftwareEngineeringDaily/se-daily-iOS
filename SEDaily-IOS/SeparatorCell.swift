//
//  SeparatorCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/7/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//


import UIKit
import Reusable

class SeparatorCell: UITableViewCell, Reusable {
	private var separator: UIView = UIView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(separator)
		setupLayout()
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
}

extension SeparatorCell {
	private func setupLayout() {
		
		separator.backgroundColor = Stylesheet.Colors.light
		
		separator.snp.makeConstraints { (make) -> Void in
			make.left.right.bottom.top.equalToSuperview()
			make.height.equalTo(5.0)
		}
	}
}
