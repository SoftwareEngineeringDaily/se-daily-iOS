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
			upvoteButton.setIcon(icon: .ionicons(.iosHeartOutline), iconSize: 25.0, color: Stylesheet.Colors.dark, forState: .normal)
			upvoteButton.setIcon(icon: .ionicons(.iosHeart), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .selected)
			
			bookmarkButton.setImage(UIImage(named: "ios-bookmark"), for: .normal)
			bookmarkButton.setImage(UIImage(named: "ios-bookmark-fill"), for: .selected)
			
			commentButton.setIcon(icon: .ionicons(.iosChatbubbleOutline), iconSize: 30.0, color: Stylesheet.Colors.dark, forState: .normal)
			commentButton.setIcon(icon: .ionicons(.iosChatbubble), iconSize: 30.0, color: Stylesheet.Colors.base, forState: .highlighted)
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
		}
	}
}
