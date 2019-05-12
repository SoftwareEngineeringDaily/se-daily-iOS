//
//  WebViewCell.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/2/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit
import Reusable
import WebKit

class DescriptionCell: UITableViewCell, Reusable {
	
	var descriptionLabel: UILabel!
	//webView.navigationDelegate = self
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			//updateUI()
			var str: String!
			// Due to asynchronuous nature of decoding html content, this is a better way to do it
			DispatchQueue.global(qos: .background).async { [weak self] in
				str = self?.viewModel.podcastDescription
				DispatchQueue.main.async {
					print(str)
					self?.descriptionLabel.text = str
					self?.layoutIfNeeded()
				}
			}
		}
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
		
	}
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
}

extension DescriptionCell {
	private func setupLayout() {
		descriptionLabel = UILabel()
		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
		descriptionLabel.textColor = Stylesheet.Colors.dark
		self.contentView.addSubview(descriptionLabel)
		descriptionLabel.snp.makeConstraints { (make) in
			make.left.right.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
			make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
		}
	}
}



