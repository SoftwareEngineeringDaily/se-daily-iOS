//
//  TagsCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/14/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit
import Reusable
import Tags

class TagsCell: UITableViewCell, Reusable {
	
	let tagsView = TagsView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
}

extension TagsCell {
	private func setupLayout() {
		contentView.addSubview(tagsView)
		// layer radius
		tagsView.tagLayerRadius = 6
		// layer width
		tagsView.tagLayerWidth = 1
		// layer color
		tagsView.tagLayerColor = .black
		// text color
		tagsView.tagTitleColor = .black
		// background color
		tagsView.tagBackgroundColor = .white
		// font
		tagsView.tagFont = .systemFont(ofSize: 15)
		// text longer ...
		tagsView.lineBreakMode = .byTruncatingMiddle
		// tag add
		tagsView.tags = "Hello,Swift,Kubernetes,Javascript,React Native, Hello,Swift,Kubernetes,Javascript,React Native, Hello,Swift,Kubernetes,Javascript,React Native"
		
		tagsView.lastTag = "+"
		
		
		
		tagsView.snp.makeConstraints { (make) in
			make.top.left.right.bottom.equalToSuperview()
		}
		
	}
}
