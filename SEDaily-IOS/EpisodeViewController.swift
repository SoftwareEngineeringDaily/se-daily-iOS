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

protocol EpisodeViewDelegate: class {
  func playAudio(podcastViewModel: PodcastViewModel)
  func stopAudio()
}

import UIKit
import WebKit
import Tags

class EpisodeViewController: UIViewController, AudioControllable, MainCoordinated, Stateful {
  
  var stateController: StateController?
  
	var mainCoordinator: MainFlowCoordinator?
	
	
	let tagsView = TagsView()
	let tagsScrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: 375.0, height: 50.0))
	
	
	//weak var delegate: PodcastDetailViewControllerDelegate?
	weak var audioControlDelegate: EpisodeViewDelegate?
	
	var loaded: Bool = false // to check if HTML content has loaded
	var webView: WKWebView = WKWebView()
	let networkService: API = API()
	
	var topics:[Topic] = [] { didSet {
		tagsView.set(contentsOf: topicsStringArray)
		}
	}
	
	var topicsStringArray: [String] {
		get {
			return topics.map{ $0.name }
		}
	}
	
	var webViewHeight: CGFloat = 600
	
	
	
	var viewModel: PodcastViewModel = PodcastViewModel() {
		willSet {
			guard newValue != self.viewModel else { return }
		}
		didSet {
			tableView.reloadData()
		}
	}
	var isPlaying = false { didSet {
		tableView.reloadData()
		
		}}
	var transcriptURL: String?
	var tableView = UITableView()
	
	
	required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(tableView)
		
		
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(EpisodeViewController.shareTapped))
		
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
		
		
		tableView.register(cellType: EpisodeHeaderCell.self)
		tableView.register(cellType: WebViewCell.self)
		tableView.register(cellType: TagsCell.self)
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50.0
		tableView.separatorStyle = .none
		
		tableView.delegate = self
		tableView.dataSource = self
		tagsView.delegate = self
		
		
		
		
		tagsScrollView.addSubview(tagsView)
		tableView.tableHeaderView = tagsScrollView
		setupTagsHeaderLayout()
		tableView.backgroundColor = .white
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.onDidReceiveData(_:)),
			name: .viewModelUpdated,
			object: nil)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.onDidReceiveReloadRequest(_:)),
			name: .reloadEpisodeView,
			object: nil)
		
		getTrascriptURL()
		getTopics()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.isPlaying = stateController?.getCurrentlyPlayingId() == viewModel._id
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	deinit {
		// perform the deinitialization
		NotificationCenter.default.removeObserver(self)
	}
	
	func playButtonPressed(isPlaying: Bool) {
		if !isPlaying {
			self.audioControlDelegate?.playAudio(podcastViewModel: viewModel)
			AskForReview.triggerEvent()
			self.isPlaying = true
		} else {
			self.audioControlDelegate?.stopAudio()
      self.isPlaying = false
		}
	}
	
	@objc func shareTapped() {
		
		if let link = viewModel.postLinkURL {
			let objectsToShare = [link]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			self.present(activityVC, animated: true, completion: nil)
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
		relatedLinksViewController.transcriptURL = transcriptURL
		self.navigationController?.pushViewController(relatedLinksViewController, animated: true)
	}
	func commentsButtonPressed() {
		Analytics2.podcastCommentsViewed(podcastId: viewModel._id)
		let commentsViewController: CommentsViewController = CommentsViewController()
		if let thread = viewModel.thread {
			commentsViewController.rootEntityId = thread._id
			self.navigationController?.pushViewController(commentsViewController, animated: true)
		}
	}
}

extension EpisodeViewController {
	private func getTrascriptURL() {
		networkService.getPost(podcastId: viewModel._id, completion: { [weak self] (success, result) in
			if success {
				guard let transcriptURL = result?.transcriptURL else { return }
				self?.transcriptURL = transcriptURL
			}
		})
	}
}


extension EpisodeViewController {
	private func getTopics() {
		networkService.getTopicsForPost(podcastId: viewModel._id, onSuccess: { [weak self] data in
			self?.topics = data
			}, onFailure: { _ in print("error")})
	}
}

extension EpisodeViewController {
	private func setupTagsHeaderLayout() {
		
		tagsScrollView.showsHorizontalScrollIndicator = false
		
		tagsView.lastTagTitleColor = .white
		tagsView.lastTagLayerColor = Stylesheet.Colors.base
		tagsView.lastTagBackgroundColor = Stylesheet.Colors.base
		
		tagsView.tagLayerRadius = 5
		tagsView.tagLayerWidth = 1
		tagsView.tagLayerColor = Stylesheet.Colors.base
		tagsView.tagTitleColor = Stylesheet.Colors.base
		tagsView.tagBackgroundColor = .white
		tagsView.tagFont = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 14)) ?? .systemFont(ofSize: 14)
		tagsView.lineBreakMode = .byTruncatingMiddle
		
		tagsScrollView.snp.makeConstraints{ (make) in
			make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 5))
			make.bottom.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 5))
			make.height.equalTo(50)
			make.width.equalTo(UIScreen.main.bounds.width)
		}
		
		tagsView.translatesAutoresizingMaskIntoConstraints = false
		tagsView.snp.makeConstraints { (make) in
			make.left.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
			make.right.bottom.top.equalToSuperview()
			make.height.equalTo(50)
			make.width.equalTo(9000) //arbitrary value wider than the actual screen
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
			cell.downloadService = DownloadService(podcastViewModel: viewModel)
			
			cell.isPlaying = isPlaying
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
	@objc func onDidReceiveData(_ notification: Notification) {
		if let data = notification.userInfo as? [String: PodcastViewModel] {
			for (_, viewModel) in data {
				guard viewModel._id == self.viewModel._id else { return }
				self.viewModel = viewModel
			}
		}
	}
}

extension EpisodeViewController {
	@objc func onDidReceiveReloadRequest(_ notification: Notification) {
    if let data = notification.userInfo as? [String: PodcastViewModel] {
      for (_, viewModel) in data {
        guard viewModel._id == self.viewModel._id else { return }
        self.isPlaying = false
      }
    }
	}
}



extension EpisodeViewController: TagsDelegate {
	
	// Tag Touch Action
	func tagsTouchAction(_ tagsView: TagsView, tagButton: TagButton) {
		let layout = UICollectionViewLayout()
		let topic = topics[tagButton.index]
		var postsForTopicCollectionViewController = PostsForTopicCollectionViewController(collectionViewLayout: layout, topic: topic)
    mainCoordinator?.configure(viewController: postsForTopicCollectionViewController)
		self.navigationController?.pushViewController(postsForTopicCollectionViewController, animated: true)
	}
	// Last Tag Touch Action
	func tagsLastTagAction(_ tagsView: TagsView, tagButton: TagButton) {
		
	}
	// TagsView Change Height
	func tagsChangeHeight(_ tagsView: TagsView, height: CGFloat) {
	}
}


