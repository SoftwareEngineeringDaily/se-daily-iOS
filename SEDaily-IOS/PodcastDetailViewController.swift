//
//  PostDetailViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/18/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import WebKit
import SwiftIcons

protocol PodcastDetailViewControllerDelegate: class {
    func modelDidChange(viewModel: PodcastViewModel)
}

protocol BookmarksDelegate: class {
    func bookmarkPodcast()

}

class PodcastDetailViewController: UIViewController, WKNavigationDelegate {

    weak var delegate: PodcastDetailViewControllerDelegate?
    private weak var audioOverlayDelegate: AudioOverlayDelegate?

    private var bookmarkButton: UIButton?

    let networkService: API = API()

    var model = PodcastViewModel()

    lazy var scrollView: UIScrollView = {
        return UIScrollView(frame: self.view.frame)
    }()

    required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, audioOverlayDelegate: AudioOverlayDelegate?) {
        self.audioOverlayDelegate = audioOverlayDelegate
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Stylesheet.Colors.base

        let headerView = HeaderView(width: 375, height: 200)
        headerView.setupHeader(model: model)
        headerView.delegate = self
        headerView.bookmarkDelegate = self
        headerView.audioOverlayDelegate = self.audioOverlayDelegate

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

        let iconSize = UIView.getValueScaledByScreenHeightFor(baseValue: 25)
        self.bookmarkButton = UIButton()
        self.bookmarkButton?.addTarget(self, action: #selector(self.bookmarkButtonPressed), for: .touchUpInside)
        self.bookmarkButton?.setIcon(
            icon: .fontAwesome(.bookmarkO),
            iconSize: iconSize,
            color: Stylesheet.Colors.white,
            forState: .normal)
        self.bookmarkButton?.setIcon(
            icon: .fontAwesome(.bookmark),
            iconSize: iconSize,
            color: Stylesheet.Colors.white,
            forState: .selected)
        self.bookmarkButton?.isSelected = self.model.isBookmarked
        if let bookmarkButton = self.bookmarkButton {
            let bookmarkBarButtonItem = UIBarButtonItem(customView: bookmarkButton)
            self.navigationItem.rightBarButtonItem = bookmarkBarButtonItem
        }
        Analytics2.podcastPageViewed(podcastId: model._id)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.audioOverlayDelegate?.setCurrentShowingDetailView(
            podcastViewModel: self.model)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.audioOverlayDelegate?.setCurrentShowingDetailView(
            podcastViewModel: nil)
    }

    private func setBookmarked(_ bool: Bool) {
        self.model.isBookmarked = bool
        self.bookmarkButton?.isSelected = bool
    }

    private func removePowerPressPlayerTags(html: String) -> String {
        var modifiedHtml = html
        guard let powerPressPlayerRange = modifiedHtml.range(of: "<!--powerpress_player-->") else {
            return modifiedHtml
        }
        modifiedHtml.removeSubrange(powerPressPlayerRange)

        /////////////////////////
        guard let divStartRange = modifiedHtml.range(of: "<div class=\"powerpress_player\"") else {
            return modifiedHtml
        }
        guard let divEndRange = modifiedHtml.range(of: "</div>") else {
            return modifiedHtml
        }
        modifiedHtml.removeSubrange(divStartRange.lowerBound..<divEndRange.upperBound)

        /////////////////////////
        guard let pStartRange = modifiedHtml.range(of: "<p class=\"powerpress_links powerpress_links_mp3\">") else {
            return modifiedHtml
        }
        guard let pEndRange = modifiedHtml.range(of: "</p>") else {
            return modifiedHtml
        }
        modifiedHtml.removeSubrange(pStartRange.lowerBound..<pEndRange.upperBound)
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

    func relatedLinksButtonPressed() {
        Analytics2.relatedLinksButtonPressed(podcastId: model._id)
        let relatedLinksStoryboard = UIStoryboard.init(name: "RelatedLinks", bundle: nil)
        guard let relatedLinksViewController = relatedLinksStoryboard.instantiateViewController(
            withIdentifier: "RelatedLinksViewController") as? RelatedLinksViewController else {
                return
        }
        let podcastId = model._id
        relatedLinksViewController.postId = podcastId
        self.navigationController?.pushViewController(relatedLinksViewController, animated: true)
    }

    func commentsButtonPressed() {
        Analytics2.podcastCommentsViewed(podcastId: model._id)
        let commentsStoryboard = UIStoryboard.init(name: "Comments", bundle: nil)
        guard let commentsViewController = commentsStoryboard.instantiateViewController(
            withIdentifier: "CommentsViewController") as? CommentsViewController else {
                return
        }
        if let thread = model.thread {
            commentsViewController.rootEntityId = thread._id
            self.navigationController?.pushViewController(commentsViewController, animated: true)
        }
    }

    func modelDidChange(viewModel: PodcastViewModel) {
        self.delegate?.modelDidChange(viewModel: viewModel)
    }
}

extension PodcastDetailViewController: BookmarksDelegate {
     @objc private func bookmarkButtonPressed() {
        guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
            return
        }

        guard let bookmarkButton = self.bookmarkButton else {
            log.error("There is no bookmark button")
            return
        }

        bookmarkButton.isSelected = !bookmarkButton.isSelected
        self.setBookmark(value: bookmarkButton.isSelected)

    }

    private func setBookmark(value: Bool) {
            let podcastId = model._id
            networkService.setBookmarkPodcast(
                value: value,
                podcastId: podcastId,
                completion: { (success, active) in
                    guard success != nil else { return }
                    if success == true {
                        guard let active = active else { return }
                        self.updateBookmarked(active: active)
                    }
            })
        Analytics2.bookmarkButtonPressed(podcastId: model._id)
    }

    func bookmarkPodcast() {
        if !model.isBookmarked {
            setBookmark(value: true)
        }
    }

    func updateBookmarked(active: Bool) {
        self.setBookmarked(active)
        self.model.isBookmarked = active
        self.delegate?.modelDidChange(viewModel: self.model)
        // Update the bookmark button too with actual result:

        guard let bookmarkButton = self.bookmarkButton else {
            log.error("There is no bookmark button")
            return
        }

        bookmarkButton.isSelected = active

    }

}

