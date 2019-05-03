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
	
	var webViewHeight: CGFloat = 0.0 {
		didSet {
			snp.removeConstraints()
			webView.snp.remakeConstraints { (make) in
				make.left.top.right.bottom.equalToSuperview()
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
		webView = WKWebView()
		self.contentView.addSubview(webView)
		webView.scrollView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(15.0)
			make.right.equalToSuperview().offset(-15.0)
		}
	}
	
	required init
		(coder aDecoder: NSCoder) {
		fatalError("init(coder:)")
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}



extension WebViewCell: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
			if complete != nil {
				webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
					guard let h:CGFloat = height as? CGFloat else { return }
					self.delegate?.updateWebViewHeight(didCalculateHeight: h)
				})
			}
		})
	}
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if navigationAction.navigationType == .linkActivated {
			if let url = navigationAction.request.url,
				UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url)
				decisionHandler(.cancel)
			} else {
				decisionHandler(.allow)
			}
		} else {
			decisionHandler(.allow)
		}
	}
}
