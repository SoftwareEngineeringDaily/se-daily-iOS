//
//  SwitchCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/6/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation
import UIKit
import Reusable


class SwitchCell: UITableViewCell, Reusable {
	private var label: UILabel = UILabel()
	var toggle: UISwitch = UISwitch()
	var separator: UIView = UIView()
	
	var viewModel: ViewModel = ViewModel() {
		didSet {
			label.text = viewModel.text
			setupLayout()
			//toggle.
			//setupLayout(style: viewModel.style)
		}
	}
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(label)
		contentView.addSubview(toggle)
		contentView.addSubview(separator)
		self.selectionStyle = .none
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
}




extension SwitchCell {
	private func setupLayout() {
		
		label.textColor = Stylesheet.Colors.dark
		label.baselineAdjustment = .alignCenters
		label.numberOfLines = 0
		label.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
		
		toggle.tintColor = Stylesheet.Colors.light
		toggle.onTintColor = Stylesheet.Colors.base
		
		separator.backgroundColor = Stylesheet.Colors.light
		
		label.snp.makeConstraints { (make) in
			make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			make.centerY.equalToSuperview()
			make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
		}
		
		toggle.snp.makeConstraints { (make) in
			make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15.0))
			make.centerY.equalToSuperview()
		}
		separator.snp.makeConstraints { (make) -> Void in
			make.left.right.bottom.equalToSuperview()
			make.height.equalTo(2.0)
		}
	}
}

// MARK: - ViewModel
extension SwitchCell {
	struct ViewModel {
		var text = ""
		var callback: ((_ isOn: Bool)-> Void) = {_ in }
	}
}
