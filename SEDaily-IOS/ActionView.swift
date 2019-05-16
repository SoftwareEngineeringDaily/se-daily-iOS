//
//  ActionView.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/1/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation
import UIKit

class ActionView {
	let actionStackView: UIStackView = UIStackView()
	let upvoteButton: UIButton = UIButton()
	let commentButton: UIButton = UIButton()
	let bookmarkButton: UIButton = UIButton()
	
	var commentShowCallback: ( ()-> Void) = {}
	
	let upvoteCountLabel: UILabel = UILabel()
	
	let upvoteStackView: UIStackView = UIStackView()
	
	func setupComponents(superview: UIView) {
		func setupButtons() {
			upvoteButton.setImage(UIImage(named: "like_outline"), for: .normal)
			upvoteButton.setImage(UIImage(named: "like"), for: .selected)
			
			bookmarkButton.setImage(UIImage(named: "bookmark_outline"), for: .normal)
			bookmarkButton.setImage(UIImage(named: "bookmark"), for: .selected)
			
			commentButton.setImage(UIImage(named: "comment"), for: .normal)
			commentButton.setImage(UIImage(named: "comment"), for: .normal)
		}
		func setupUpvoteStackView() {
			upvoteStackView.alignment = .center
			upvoteStackView.axis = .horizontal
			upvoteStackView.distribution = .fillEqually
			
			upvoteStackView.addArrangedSubview(upvoteButton)
			upvoteStackView.addArrangedSubview(upvoteCountLabel)
		}
		
		func setupActionStackView() {
			actionStackView.alignment = .center
			actionStackView.axis = .horizontal
			actionStackView.distribution = .fillEqually
			
			actionStackView.addArrangedSubview(upvoteStackView)
			actionStackView.addArrangedSubview(commentButton)
			actionStackView.addArrangedSubview(bookmarkButton)
			superview.addSubview(actionStackView)
		}
		setupButtons()
		setupUpvoteStackView()
		setupActionStackView()
		
	}


	func setupContraints() {
			upvoteButton.snp.makeConstraints { (make) -> Void in
				make.right.equalTo(upvoteCountLabel.snp.left)
				make.height.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0)).priority(999)
		}
		bookmarkButton.snp.makeConstraints { (make) -> Void in
			
			make.height.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0)).priority(999)
		}
		commentButton.snp.makeConstraints { (make) -> Void in
			
			make.height.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 50.0)).priority(999)
		}
	}
}
