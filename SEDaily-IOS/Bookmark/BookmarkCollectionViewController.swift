//
//  BookmarkCollectionViewController.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/4/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import StatefulViewController
import KoalaTeaFlowLayout

/// Collection view controller for viewing all bookmarks for the user.
class BookmarkCollectionViewController: UICollectionViewController, StatefulViewController {
	static private let cellId = "PodcastCellId"
	private let reuseIdentifier = "Cell"
	
	private var viewModelController = BookmarkViewModelController()
	weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	private var progressController = PlayProgressModelController()
	
	lazy var skeletonCollectionView: SkeletonCollectionView = {
		return SkeletonCollectionView(frame: self.collectionView!.frame)
	}()
	
	
	init(collectionViewLayout layout: UICollectionViewLayout, audioOverlayDelegate: AudioOverlayDelegate?) {
		super.init(collectionViewLayout: layout)
		self.audioOverlayDelegate = audioOverlayDelegate
		
		self.tabBarItem = UITabBarItem(title: L10n.tabBarSaved, image:#imageLiteral(resourceName: "bookmark"), selectedImage: #imageLiteral(resourceName: "bookmark_selected"))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		self.collectionView?.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		let layout = KoalaTeaFlowLayout(cellWidth: Helpers.getScreenWidth(),
																		cellHeight: UIView.getValueScaledByScreenWidthFor(baseValue: 185.0),
																		topBottomMargin: UIView.getValueScaledByScreenHeightFor(baseValue: 10),
																		leftRightMargin: UIView.getValueScaledByScreenWidthFor(baseValue: 0),
																		cellSpacing: UIView.getValueScaledByScreenWidthFor(baseValue: 10))
		self.collectionView?.collectionViewLayout = layout
		self.collectionView?.backgroundColor = Stylesheet.Colors.light
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.loginObserver),
			name: .loginChanged,
			object: nil)
		
		
		self.errorView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		self.errorView?.backgroundColor = .green
		
		
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(
			self,
			action: #selector(pullToRefresh(_:)),
			for: .valueChanged)
		self.collectionView?.refreshControl = refreshControl
		Analytics2.bookmarksPageViewed()
	}
	
	@objc private func pullToRefresh(_ sender: Any) {
		self.refreshView(useCache: false)
	}
	
	func hasContent() -> Bool {
		if UserManager.sharedInstance.getActiveUser().isLoggedIn() {
			return self.viewModelController.viewModelsCount > 0
		}
		return false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setupInitialViewState()
		progressController.retrieve()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.refreshView(useCache: true)
	}
	
	/// Refresh the view
	///
	/// - Parameter useCache: true to use disk cache first while network calls occur in the background
	private func refreshView(useCache: Bool) {
		self.startLoading()
		if UserManager.sharedInstance.getActiveUser().isLoggedIn() {
			self.updateLoadingView(view: skeletonCollectionView)
			self.updateEmptyView(view:
				StateView(
					frame: CGRect.zero,
					text: L10n.noBookmarks,
					showLoadingIndicator: false,
					showRefreshButton: true,
					delegate: self))
			
			if useCache {
				self.viewModelController.retrieveCachedBookmarkData(onSuccess: {
					self.endLoading()
					DispatchQueue.main.async {
						self.collectionView?.reloadData()
						self.collectionView?.refreshControl?.endRefreshing()
					}
				})
			}
			self.viewModelController.retrieveNetworkBookmarkData {
				self.endLoading()
				DispatchQueue.main.async {
					self.collectionView?.reloadData()
					self.collectionView?.refreshControl?.endRefreshing()
				}
			}
		} else {
			self.updateLoadingView(view:
				StateView(
					frame: CGRect.zero,
					text: "",
					showLoadingIndicator: false,
					showRefreshButton: false,
					delegate: nil))
			self.updateEmptyView(view:
				StateView(
					frame: CGRect.zero,
					text: L10n.loginSeeBookmarks,
					showLoadingIndicator: false,
					showRefreshButton: false,
					delegate: nil))
			self.endLoading()
			DispatchQueue.main.async {
				self.collectionView?.reloadData()
				self.collectionView?.refreshControl?.endRefreshing()
			}
		}
	}
	
	private func updateLoadingView(view: UIView) {
		self.loadingView?.removeFromSuperview()
		self.loadingView = view
	}
	
	private func updateEmptyView(view: UIView) {
		self.emptyView?.removeFromSuperview()
		self.emptyView = view
	}
	
	@objc func loginObserver() {
		self.refreshView(useCache: false)
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int) -> Int {
		return UserManager.sharedInstance.getActiveUser().isLoggedIn() ?
			self.viewModelController.viewModelsCount : 0
	}
	
	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		if let viewModel = self.viewModelController.viewModel(at: indexPath.row) {
			cell.viewModel = viewModel
			
			let upvoteService = UpvoteService(podcastViewModel: viewModel)
			let bookmarkService = BookmarkService(podcastViewModel: viewModel)
			let downloadService = DownloadService(podcastViewModel: viewModel)
			
			cell.playProgress = progressController.episodesPlayProgress[viewModel._id] ?? PlayProgress(id: "", currentTime: 0.0, totalLength: 0.0)
			
			
			cell.viewModel = viewModel
			cell.upvoteService = upvoteService
			cell.bookmarkService = bookmarkService
			
			cell.commentShowCallback = { [weak self] in
				//self?.commentsButtonPressed(viewModel)
				
			}
			
		}
		
		return cell
	}
	
	override func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath) {
		if let viewModel = viewModelController.viewModel(at: indexPath.row) {
			if let audioOverlayDelegate = self.audioOverlayDelegate {
				let vc = EpisodeViewController(nibName: nil, bundle: nil, audioOverlayDelegate: audioOverlayDelegate)
				vc.viewModel = viewModel
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
}

extension BookmarkCollectionViewController: StateViewDelegate {
	func refreshPressed() {
		self.refreshView(useCache: false)
		Analytics2.refreshMyBookmarksPressed()
	}
}

extension BookmarkCollectionViewController: PodcastDetailViewControllerDelegate {
	func modelDidChange(viewModel: PodcastViewModel) {
		self.viewModelController.update(with: viewModel)
		self.collectionView?.reloadData()
	}
}



