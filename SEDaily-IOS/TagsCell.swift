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

class TagsCell: UITableViewCell, Reusable, UIScrollViewDelegate {
	
	let tagsView = TagsView()
	let scrollView = UIScrollView()
	
	var topics:[String] = [] { willSet {
	guard newValue != self.topics else { return }
		}
	didSet {
		tagsView.set(contentsOf: topics)
		tagsView.lastTag = "+"
		print(tagsView.frame.width)
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		scrollView.delegate = self
		
	}
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	override func layoutSubviews() {
		setupLayout()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
			scrollView.contentOffset.y = 0
		}
	}
	
}

extension TagsCell {
	private func setupLayout() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		tagsView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsHorizontalScrollIndicator = true
		scrollView.backgroundColor = .white
		scrollView.contentSize = tagsView.frame.size
		let label: UILabel = UILabel()
		label.text = "sdsdasdsadasd"
		contentView.addSubview(scrollView)
		scrollView.addSubview(tagsView)
		scrollView.addSubview(label)
		// layer radius
		tagsView.tagLayerRadius = 6
		// layer width
		tagsView.tagLayerWidth = 1
		// layer color
		tagsView.tagLayerColor = Stylesheet.Colors.base
		// text color
		tagsView.tagTitleColor = Stylesheet.Colors.base
		// background color
		tagsView.tagBackgroundColor = .white
		// font
		tagsView.tagFont = .systemFont(ofSize: 15)
		// text longer ...
		tagsView.lineBreakMode = .byTruncatingMiddle
		
		scrollView.snp.makeConstraints { (make) in
			make.top.left.right.bottom.equalToSuperview()
		}
		
		tagsView.snp.makeConstraints { (make) in
			make.top.left.right.bottom.equalToSuperview()
			make.height.equalTo(50.0)
			make.width.equalTo(5000.0)
		}
		
		if #available(iOS 11, *) {
			scrollView.contentInsetAdjustmentBehavior = .never
		}
		scrollView.contentSize.height = 1.0
		//scrollView.contentSize = tagsView.frame.size
		
		
	}
}


