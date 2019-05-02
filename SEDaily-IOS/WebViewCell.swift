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

class WebViewCell: UITableViewCell, Reusable {
	
	var webView = WKWebView() 
	//webView.navigationDelegate = self
	
	var delegate: NewsTableViewCellDelegate?
	
	
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

extension WebViewCell {
	private func setupLayout() {
		webView.navigationDelegate = self
		self.contentView.addSubview(webView)
		webView.snp.makeConstraints { (make) in
			make.left.right.top.bottom.equalToSuperview()
		}
	}
}


extension WebViewCell: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
			if complete != nil {
				webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
					//let h: CGFloat = height as! CGFloat
					print(height)
					
				//	self.webView.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 1000.0)
			print(self.webView.frame)
					self.delegate?.newCell(self, didCalculateHeight: 10.0)
					//webView.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 1000.0)
					print(self.webView.frame)
//					let newsContentFrame: CGRect = self.newsContentViewContainer.frame
//					self.newsContentViewContainer.frame = CGRect(x: newsContentFrame.minX, y: newsContentFrame.minY, width: newsContentFrame.width, height: h)
//
//					let tableCellFrame: CGRect = self.frame
//					self.frame = CGRect(x: tableCellFrame.minX, y: tableCellFrame.minY, width: tableCellFrame.width, height: tableCellFrame.height + h)
				})
			}
		})
	}
}
