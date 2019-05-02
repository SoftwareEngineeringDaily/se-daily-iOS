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
import SnapKit


class WebViewCell: UITableViewCell, Reusable {
	
	var webView: WKWebView!
	
	var webViewHeight: CGFloat = 0.0 { didSet {
		snp.removeConstraints()
		webView.snp.remakeConstraints { (make) in
			make.left.right.top.bottom.equalToSuperview()
			make.height.equalTo(webViewHeight).priority(999)
			make.width.equalToSuperview()
		}
		}
	}
	
	var delegate: WebViewCellDelegate?
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		//let G = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 4000.0))
		webView = WKWebView()
		self.contentView.addSubview(webView)
		
		print(self.contentView)
		print("frame")
		//print(webView.frame)
		
		
		
		
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
		//webView.navigationDelegate = self
		
	}
}


extension WebViewCell: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
			if complete != nil {
				webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
					//let h: CGFloat = height as! CGFloat
				guard let h:CGFloat = height as? CGFloat else { return }
					self.delegate?.updateWebViewHeight(didCalculateHeight: h)
//
//					self.height1?.deactivate()
//					webView.snp.makeConstraints { (make) in
//						self.height1 = make.height.equalTo(h).constraint
//					}
//					self.height1?.activate()
//					self.layoutIfNeeded()
					//self.webView.scrollView.frame = CGRect(x: 0.0, y: 0.0, width: 357.0, height: 4000)
					//self.webView.frame = CGRect(x: 0.0, y: 0.0, width: 357.0, height: 1000)
					
				//	self.webView.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 1000.0)
			//print(self.webView.frame)
					//self.delegate?.newCell(self, didCalculateHeight: 10.0)
					//webView.frame = CGRect(x: 0.0, y: 0.0, width: 375.0, height: 1000.0)
					//print(self.webView.frame)
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
