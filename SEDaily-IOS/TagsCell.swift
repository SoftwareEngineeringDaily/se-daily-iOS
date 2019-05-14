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
	
	var topics:[String] = [] { willSet {
	guard newValue != self.topics else { return }
		}
	didSet {
		tagsView.set(contentsOf: topics)
		tagsView.lastTag = "+"
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
		
		
		tagsView.snp.makeConstraints { (make) in
			make.top.left.right.bottom.equalToSuperview()
		}
		
	}
}


