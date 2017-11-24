//
//  PostDetailViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/18/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import WebKit

protocol PodcastDetailViewControllerDelegate {
    func modelDidChange(viewModel: PodcastViewModel)
}

class PodcastDetailViewController: UIViewController, WKNavigationDelegate {

    var delegate: PodcastDetailViewControllerDelegate?
  
    var model = PodcastViewModel()

    lazy var scrollView: UIScrollView = {
        return UIScrollView(frame: self.view.frame)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Stylesheet.Colors.base

        let headerView = HeaderView(width: 375, height: 200)
        headerView.setupHeader(model: model)
        headerView.delegate = self

        let webView = WKWebView()
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }

        var htmlString = self.removePowerPressPlayerTags(html: model.encodedPodcastDescription)
        htmlString = self.addStyling(html: htmlString)
        htmlString = self.addHeightAdjustment(html: htmlString, height: headerView.height)
        htmlString = self.addScaleMeta(html: htmlString)
        webView.loadHTMLString(htmlString, baseURL: nil)

        webView.scrollView.addSubview(headerView)
    }

    private func removePowerPressPlayerTags(html: String) -> String {
        var modifiedHtml = html
        let powerPressPlayerRange = modifiedHtml.range(of: "<!--powerpress_player-->")
        modifiedHtml.removeSubrange(powerPressPlayerRange!)
        let divStartRange = modifiedHtml.range(of: "<div class=\"powerpress_player\"")
        let divEndRange = modifiedHtml.range(of: "</div>")
        modifiedHtml.removeSubrange(divStartRange!.lowerBound..<divEndRange!.upperBound)
        let pStartRange = modifiedHtml.range(of: "<p class=\"powerpress_links powerpress_links_mp3\">")
        let pEndRange = modifiedHtml.range(of: "</p>")
        modifiedHtml.removeSubrange(pStartRange!.lowerBound..<pEndRange!.upperBound)
        return modifiedHtml
    }

    private func addStyling(html: String) -> String {
        return "<style type=\"text/css\">body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; } </style>\(html)"
    }

    private func addHeightAdjustment(html: String, height: CGFloat) -> String {
        return "<div style='width:100%;height:\(height)px'></div>\(html)"
    }

    private func addScaleMeta(html: String) -> String {
        return "<meta name=\"viewport\" content=\"initial-scale=1.0\" />\(html)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension PodcastDetailViewController: HeaderViewDelegate {
    func modelDidChange(viewModel: PodcastViewModel) {
        self.delegate?.modelDidChange(viewModel: viewModel)
    }
}
