//
//  SummaryCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/5/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
import Reusable
import UIKit

class SummaryCell: UITableViewCell, Reusable {
	
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
	}
	
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
}


extension SummaryCell {
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
	}
}

// MARK: - ViewModel
extension SummaryCell {
	struct ViewModel {
		struct Style {
			var marginX: CGFloat = 0
			var marginY: CGFloat = 0
			var font: UIFont = UIFont(font: .helveticaNeue, size: 10.0)!
			var color = UIColor.clear
			var alignment = NSTextAlignment.left
		}
		var text = ""
		var style = Style()
	}
}
