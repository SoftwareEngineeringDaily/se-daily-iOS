//
//  DownloadsCollectionViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/21/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation

import UIKit
import StatefulViewController
import KoalaTeaFlowLayout

/// Collection view controller for viewing all downloads for the user.
class DownloadsCollectionViewController: UICollectionViewController, StatefulViewController {
	
	private let reuseIdentifier = "Cell"
	
	private var viewModelController = DownloadsViewModelController()
	weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	private var progressController = PlayProgressModelController()
	
	lazy var skeletonCollectionView: SkeletonCollectionView = {
		return SkeletonCollectionView(frame: self.collectionView!.frame)
	}()
	
	
	init(collectionViewLayout layout: UICollectionViewLayout, audioOverlayDelegate: AudioOverlayDelegate?) {
		super.init(collectionViewLayout: layout)
		self.audioOverlayDelegate = audioOverlayDelegate
		
		self.tabBarItem = UITabBarItem(title: L10n.tabBarDownloads, image: UIImage(named: "download_panel_outline"), selectedImage: UIImage(named: "download_panel"))
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
		
		self.errorView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		self.errorView?.backgroundColor = .green
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(
			self,
			action: #selector(pullToRefresh(_:)),
			for: .valueChanged)
		self.collectionView?.refreshControl = refreshControl
		//Analytics2.bookmarksPageViewed()
	}
	
	@objc private func pullToRefresh(_ sender: Any) {
		self.refreshView(useCache: true)
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
	
	private func refreshView(useCache: Bool) {
		self.startLoading()
		
		self.updateLoadingView(view: skeletonCollectionView)
		self.updateEmptyView(view:
			StateView(
				frame: CGRect.zero,
				text: L10n.noDownloads,
				showLoadingIndicator: false,
				showRefreshButton: false,
				delegate: self))
		
		if useCache {
			self.viewModelController.retrieveCachedDownloadsData(onSuccess: {
				self.endLoading()
				DispatchQueue.main.async {
					self.collectionView?.reloadData()
					self.collectionView?.refreshControl?.endRefreshing()
				}
			})
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
	
	func hasContent() -> Bool {
			return self.viewModelController.viewModelsCount > 0
	}
	
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int) -> Int {
			return self.viewModelController.viewModelsCount
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
			
			cell.playProgress = progressController.episodesPlayProgress[viewModel._id] ?? PlayProgress(id: "", currentTime: 0.0, totalLength: 0.0)
			
			
			cell.viewModel = viewModel
			cell.upvoteService = upvoteService
			cell.bookmarkService = bookmarkService
			
			cell.commentShowCallback = { [weak self] in
				self?.commentsButtonPressed(viewModel)
				
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

extension DownloadsCollectionViewController: StateViewDelegate {
	func refreshPressed() {
		self.refreshView(useCache: true)
		
	}
}

extension DownloadsCollectionViewController: PodcastDetailViewControllerDelegate {
	func modelDidChange(viewModel: PodcastViewModel) {
		self.viewModelController.update(with: viewModel)
		self.collectionView?.reloadData()
	}
}


extension DownloadsCollectionViewController {
	func commentsButtonPressed(_ viewModel: PodcastViewModel) {
		Analytics2.podcastCommentsViewed(podcastId: viewModel._id)
		let commentsViewController: CommentsViewController = CommentsViewController()
		if let thread = viewModel.thread {
			commentsViewController.rootEntityId = thread._id
			self.navigationController?.pushViewController(commentsViewController, animated: true)
		}
	}
}
