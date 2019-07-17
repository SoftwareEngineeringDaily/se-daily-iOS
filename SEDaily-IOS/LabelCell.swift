//
//  LabelCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/10/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation

import Foundation
import Reusable
import UIKit

class LabelCell: UITableViewCell, Reusable {
	
	private var label: UILabel = UILabel()
	
	var viewModel: ViewModel = ViewModel() {
		didSet {
			label.text = viewModel.text
			setupLayout(style: viewModel.style)
			
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(label)
		self.selectionStyle = .none
		self.isUserInteractionEnabled = true
	}
	
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
}


extension LabelCell {
	private func setupLayout(style: ViewModel.Style) {
		
		label.snp.makeConstraints { (make) in
			make.left.right.equalToSuperview().offset(style.marginX)
			make.right.equalToSuperview().inset(style.marginX)
			make.top.equalToSuperview().offset(style.marginY)
			make.bottom.equalToSuperview().inset(style.marginY)
		}
		label.textAlignment = style.alignment
		label.font = style.font
		label.textColor = style.color
		
		self.accessoryType = style.accessory
	}
}

// MARK: - ViewModel
extension LabelCell {
	struct ViewModel {
		struct Style {
			var marginX: CGFloat = 0
			var marginY: CGFloat = 0
      var font: UIFont = UIFont(name: "Roboto", size: 10.0)! //arbitrary
			var color = UIColor.clear
			var alignment = NSTextAlignment.left
			var accessory: UITableViewCell.AccessoryType = .disclosureIndicator
		}
		var text = ""
		var style = Style()
	}
}
