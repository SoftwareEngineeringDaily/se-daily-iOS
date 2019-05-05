//
//  EpisodeViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/30/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

protocol WebViewCellDelegate {
	func updateWebViewHeight(didCalculateHeight height: CGFloat)
}
import UIKit
import WebKit

class EpisodeViewController: UIViewController {
	
	weak var delegate: PodcastDetailViewControllerDelegate?
	private weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	
	
	var loaded: Bool = false // to check if HTML content has loaded
	var webView: WKWebView = WKWebView()
	let networkService: API = API()
	
	var webViewHeight: CGFloat = 600
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			tableView.reloadData()
		}
	}
	
	var tableView = UITableView()
	
//	let upvoteService: UpvoteService = UpvoteService(podcastViewModel: viewModel)
//	let bookmarkService: BookmarkService = BookmarkService(podcastViewModel: viewModel)
	
	var isPlaying: Bool = false
	
	required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, audioOverlayDelegate: AudioOverlayDelegate?) {
		self.audioOverlayDelegate = audioOverlayDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
		tableView.register(cellType: EpisodeHeaderCell.self)
		tableView.register(cellType: WebViewCell.self)
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50.0
		tableView.separatorStyle = .none
		
		//tableView.delegate = self
		tableView.dataSource = self
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = .white
		
		self.audioOverlayDelegate?.setCurrentShowingDetailView(
			podcastViewModel: viewModel)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.onDidReceiveData(_:)),
			name: .podcastLiked,
			object: nil)
		
		
		
//		self.audioOverlayDelegate?.setServices(upvoteService: upvoteService, bookmarkService: bookmarkService)
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.audioOverlayDelegate?.setCurrentShowingDetailView(
			podcastViewModel: nil)
	}

	deinit {
		// perform the deinitialization
		NotificationCenter.default.removeObserver(self)
	}
	
	func playButtonPressed(isPlaying: Bool) {
		self.isPlaying = isPlaying
		if !isPlaying {
		self.audioOverlayDelegate?.animateOverlayIn()
		self.audioOverlayDelegate?.playAudio(podcastViewModel: viewModel)
		AskForReview.triggerEvent()
		} else {
			self.audioOverlayDelegate?.animateOverlayOut()
			self.audioOverlayDelegate?.stopAudio()
		}
	}
}


extension EpisodeViewController {
	private func relatedLinksButtonPressed() {
		Analytics2.relatedLinksButtonPressed(podcastId: viewModel._id)
		let relatedLinksStoryboard = UIStoryboard.init(name: "RelatedLinks", bundle: nil)
		guard let relatedLinksViewController = relatedLinksStoryboard.instantiateViewController(
			withIdentifier: "RelatedLinksViewController") as? RelatedLinksViewController else {
				return
		}
		let podcastId = viewModel._id
		relatedLinksViewController.postId = podcastId
		self.navigationController?.pushViewController(relatedLinksViewController, animated: true)
	}
	private func commentsButtonPressed() {
		Analytics2.podcastCommentsViewed(podcastId: self.viewModel._id)
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
}

extension EpisodeViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.row {
		case 0:
			let cell: EpisodeHeaderCell = tableView.dequeueReusableCell(for: indexPath)
			cell.selectionStyle = .none
			cell.bookmarkService = BookmarkService(podcastViewModel: viewModel)
			cell.upvoteService = UpvoteService(podcastViewModel: viewModel)
			cell.viewModel = viewModel
			cell.playButtonCallBack = { [weak self] isPlaying in
				self?.playButtonPressed(isPlaying: isPlaying)
			}
			cell.relatedLinksButtonCallBack = { [weak self] in
				self?.relatedLinksButtonPressed()
			}
			cell.actionView.commentShowCallback = { [weak self] in
				self?.commentsButtonPressed()
			}
			return cell
			
		default:
			let cell: WebViewCell = tableView.dequeueReusableCell(for: indexPath)
			var htmlString = HtmlHelper.getHTML(html: viewModel.encodedPodcastDescription)
			cell.webViewHeight = webViewHeight
			cell.webView.loadHTMLString(htmlString, baseURL: nil)
			cell.webView.navigationDelegate = cell
			cell.delegate = self
			return cell
		}
	}
	
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
}

extension EpisodeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}



extension EpisodeViewController: WebViewCellDelegate {
	func updateWebViewHeight(didCalculateHeight height: CGFloat) {
		if !loaded {
			webViewHeight = height
			tableView.reloadData()
			loaded = true
		} else { return }
	}
}

extension EpisodeViewController {
	@objc func onDidReceiveData(_ notification: Notification)
	{
		if let data = notification.userInfo as? [String: PodcastViewModel]
		{
			for (name, score) in data
			{
				guard score._id == viewModel._id else { return }
				self.viewModel = score
				
			}
		}
	}
}

//extension EpisodeViewController: UpvoteServiceModelDelegate {
//	func upvoteModelDidChange(viewModel: PodcastViewModel) {
//		self.podcastViewModelController.update(with: viewModel)
//	}
//}
//
//extension EpisodeViewController: BookmarkServiceModelDelegate {
//	func bookmarkModelDidChange(viewModel: PodcastViewModel) {
//		self.podcastViewModelController.update(with: viewModel)
//	}
//}


