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

protocol SwitchCellDelegate: class {
	func switchCell(_ cell: SwitchCell, didToggle value: Bool)
}

class SwitchCell: UITableViewCell, Reusable {
	private var label: UILabel = UILabel()
	var toggle: UISwitch = UISwitch()
	private var separator: UIView = UIView()
	
	weak var delegate: SwitchCellDelegate?
	
	var viewModel: ViewModel = ViewModel() {
		didSet {
			label.text = viewModel.text
			setupLayout()
			setupTargets()
		}
	}
	
	
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(label)
		contentView.addSubview(toggle)
		contentView.addSubview(separator)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
}


extension SwitchCell {
	private func setupTargets() {
		toggle.addTarget(self, action: #selector(SwitchCell.switchValueDidChange), for: .touchUpInside)
	}
	
	@objc private func switchValueDidChange(sender: UISwitch) {
		delegate?.switchCell(self, didToggle: sender.isOn)
	}
}
extension SwitchCell {
	private func setupLayout() {
		
		selectionStyle = .none
		
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
	}
}
