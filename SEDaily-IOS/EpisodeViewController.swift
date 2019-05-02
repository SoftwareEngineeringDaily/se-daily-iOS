//
//  EpisodeViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/30/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

protocol NewsTableViewCellDelegate {
	func newCell(_ cell: WebViewCell, didCalculateHeight height: CGFloat)
}
import UIKit
import WebKit

class EpisodeViewController: UIViewController {
	
	weak var delegate: PodcastDetailViewControllerDelegate?
	private weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	var loaded: Bool = false
	var webView: WKWebView = WKWebView()
	let networkService: API = API()
	
	var viewModel = PodcastViewModel()
	
	var tableView = UITableView()
	
	var upvoteService: UpvoteService?
	var bookmarkService: BookmarkService?
	
	required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, audioOverlayDelegate: AudioOverlayDelegate?) {
		self.audioOverlayDelegate = audioOverlayDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(cellType: EpisodeHeaderCell.self)
		tableView.register(cellType: WebViewCell.self)
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 750.0
		//tableView.delegate = self
		tableView.dataSource = self
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = .black
//		var htmlString = self.removePowerPressPlayerTags(html: viewModel.encodedPodcastDescription)
//		htmlString = self.addStyling(html: htmlString)
//		//htmlString = self.addHeightAdjustment(html: htmlString, height: headerView.height)
//		htmlString = self.addScaleMeta(html: htmlString)
//		webView.loadHTMLString(htmlString, baseURL: nil)
//		webView.navigationDelegate = self
		
		
		// Do any additional setup after loading the view.
	}
	func commentsButtonPressed(_ viewModel: PodcastViewModel) {
		Analytics2.podcastCommentsViewed(podcastId: viewModel._id)
		let commentsStoryboard = UIStoryboard.init(name: "Comments", bundle: nil)
		guard let commentsViewController = commentsStoryboard.instantiateViewController(
			withIdentifier: "CommentsViewController") as? CommentsViewController else {
				return
		}
		if let thread = viewModel.thread {
			commentsViewController.rootEntityId = thread._id
			self.navigationController?.pushViewController(commentsViewController, animated: true)
		}
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
	
	
	
}




extension EpisodeViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.row {
		case 0:
			let cell: EpisodeHeaderCell = tableView.dequeueReusableCell(for: indexPath)
			cell.selectionStyle = .none
			cell.bookmarkService = bookmarkService
			cell.upvoteService = upvoteService
			
			cell.viewModel = viewModel
			//cell.layoutIfNeeded()
			return cell
			
		default:
			let cell: WebViewCell = tableView.dequeueReusableCell(for: indexPath)
			//cell.delegate = self
			//cell.webView = webView
			var htmlString = self.removePowerPressPlayerTags(html: viewModel.encodedPodcastDescription)
			htmlString = self.addStyling(html: htmlString)
			//htmlString = self.addHeightAdjustment(html: htmlString, height: headerView.height)
			htmlString = self.addScaleMeta(html: htmlString)
			cell.webView.loadHTMLString(htmlString, baseURL: nil)
			//cell.webView.navigationDelegate = self
			print(cell.webView.frame)
			cell.delegate = self
			return cell
			
		}
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.loaded {
			return 2
		} else {return 2}
		
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
}

extension EpisodeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 750.0
	}
}



extension EpisodeViewController: NewsTableViewCellDelegate {
	func newCell(_ cell: WebViewCell, didCalculateHeight height: CGFloat) {
		//let index = tableView.indexPath(for: cell)
		//tableView.reloadData()
	}
}

extension EpisodeViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
			if complete != nil {
				webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
					//print(height)
					self.loaded = true
					self.tableView.reloadData()
				})
			}
		})
	}
}
