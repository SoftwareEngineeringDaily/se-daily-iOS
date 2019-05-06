//
//  CollectionViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/12/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import KoalaTeaFlowLayout
import StatefulViewController

private let reuseIdentifier = "Cell"

class GeneralCollectionViewController: UICollectionViewController, StatefulViewController {
	lazy var skeletonCollectionView: SkeletonCollectionView = {
		return SkeletonCollectionView(frame: self.collectionView!.frame)
	}()
	
	var type: PodcastTypes
	var tabTitle: String
	var tags: [Int]
	var categories: [Int]
	weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	private var progressController = PlayProgressModelController()
	
	// Paging Properties
	var loading = false
	let pageSize = 10
	let preloadMargin = 5
	
	var lastLoadedPage = 0
	var errorChecks = 0
	let maximumErrorChecks = 5
	
	var customTabBarItem: UITabBarItem! {
		switch type {
		case .new:
			// This is actually greatest hits right now
			return UITabBarItem(tabBarSystemItem: .mostViewed, tag: 0)
		case .recommended:
			return UITabBarItem(title: L10n.tabBarJustForYou, image: #imageLiteral(resourceName: "activity_feed"), selectedImage: #imageLiteral(resourceName: "activity_feed_selected"))
		case .top:
			return UITabBarItem(tabBarSystemItem: .mostViewed, tag: 0)
		}
	}
	
	// ViewModelController
	private let podcastViewModelController: PodcastViewModelController = PodcastViewModelController()
	
	init(collectionViewLayout layout: UICollectionViewLayout,
			 audioOverlayDelegate: AudioOverlayDelegate?,
			 tags: [Int] = [],
			 categories: [PodcastCategoryIds] = [],
			 type: PodcastTypes = .new,
			 tabTitle: String = "") {
		self.tabTitle = tabTitle
		self.type = type
		self.tags = tags
		self.audioOverlayDelegate = audioOverlayDelegate
		self.categories = categories.flatMap { $0.rawValue }
		super.init(collectionViewLayout: layout)
		self.tabBarItem = self.customTabBarItem
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		
		// Register cell classes
		self.collectionView?.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		//hardcoded height
		let layout = KoalaTeaFlowLayout(cellWidth: Helpers.getScreenWidth(),
																		cellHeight: UIView.getValueScaledByScreenWidthFor(baseValue: 185.0),
																		topBottomMargin: UIView.getValueScaledByScreenHeightFor(baseValue: 10),
																		leftRightMargin: UIView.getValueScaledByScreenWidthFor(baseValue: 0),
																		cellSpacing: UIView.getValueScaledByScreenWidthFor(baseValue: 10))
		self.collectionView?.collectionViewLayout = layout
		self.collectionView?.backgroundColor = Stylesheet.Colors.light
		
		// User Login observer
		NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.onDidReceiveData(_:)),
			name: .viewModelUpdated,
			object: nil)
		
		self.collectionView?.addSubview(skeletonCollectionView)
		
		switch type {
		case .new:
			Analytics2.newPodcastsListViewed(tabTitle: self.tabTitle)
		case .recommended:
			Analytics2.recommendedPodcastsListViewed(tabTitle: self.tabTitle)
		case .top:
			Analytics2.topPodcastsListViewed(tabTitle: self.tabTitle)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		progressController.retrieve()
		self.collectionView?.reloadData()
	}
	deinit {
		// perform the deinitialization
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// Make sure skeletonCollectionView is animating when the view is visible
		if self.skeletonCollectionView.alpha != 0 {
			self.skeletonCollectionView.collectionView.reloadData()
		}
	}
	
	@objc func loginObserver() {
		self.podcastViewModelController.clearViewModels()
		DispatchQueue.main.async {
			self.collectionView?.reloadData()
		}
		self.getData(lastIdentifier: "", nextPage: 0)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if podcastViewModelController.viewModelsCount > 0 {
			self.skeletonCollectionView.fadeOut(duration: 0.5, completion: nil)
		}
		if podcastViewModelController.viewModelsCount <= 0 {
			// Load initial data
			self.getData(lastIdentifier: "", nextPage: 0)
		}
		return podcastViewModelController.viewModelsCount
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		// Configure the cell
		if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
			
			let upvoteService = UpvoteService(podcastViewModel: viewModel)
			let bookmarkService = BookmarkService(podcastViewModel: viewModel)
			let downloadService = DownloadService(podcastViewModel: viewModel)
			
			cell.playProgress = progressController.episodesPlayProgress[viewModel._id] ?? PlayProgress(id: "", currentTime: 0.0, totalLength: 0.0)
			

			cell.viewModel = viewModel
			cell.upvoteService = upvoteService
			cell.bookmarkService = bookmarkService
			
			cell.commentShowCallback = { [weak self] in
				self?.commentsButtonPressed(viewModel)
				
			}

			if let lastIndexPath = self.collectionView?.indexPathForLastItem {
				if let lastItem = podcastViewModelController.viewModel(at: lastIndexPath.row) {
					self.checkPage(currentIndexPath: indexPath,
												 lastIndexPath: lastIndexPath,
												 lastIdentifier: lastItem.uploadDateiso8601)
				}
			}
		}
		
		return cell
	}
	
	func checkPage(currentIndexPath: IndexPath, lastIndexPath: IndexPath, lastIdentifier: String) {
		let nextPage: Int = Int(currentIndexPath.item / self.pageSize) + 1
		let preloadIndex = nextPage * self.pageSize - self.preloadMargin
		
		if (currentIndexPath.item >= preloadIndex && self.lastLoadedPage < nextPage) || currentIndexPath == lastIndexPath {
			// @TODO: Turn lastIdentifier into some T
			self.getData(lastIdentifier: lastIdentifier, nextPage: nextPage)
		}
	}
	
	func getData(lastIdentifier: String, nextPage: Int) {
		guard self.loading == false else { return }
		self.loading = true
		podcastViewModelController.fetchData(
			type: self.type.rawValue,
			createdAtBefore: lastIdentifier,
			tags: self.tags,
			categories: self.categories,
			onSuccess: {
				self.errorChecks = 0
				self.loading = false
				self.lastLoadedPage = nextPage
				DispatchQueue.main.async {
					self.collectionView?.reloadData()
				}},
			onFailure: { (apiError) in
				self.loading = false
				self.errorChecks += 1
				log.error(apiError ?? "")
				guard self.errorChecks <= self.maximumErrorChecks else { return }
				self.getData(lastIdentifier: lastIdentifier, nextPage: nextPage)
		})
	}
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
			if let audioOverlayDelegate = self.audioOverlayDelegate {
				let vc = EpisodeViewController(nibName: nil, bundle: nil, audioOverlayDelegate: audioOverlayDelegate)
				vc.viewModel = viewModel
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
}

extension GeneralCollectionViewController {
	private func viewModelDidChange(viewModel: PodcastViewModel) {
			self.podcastViewModelController.update(with: viewModel)
	}
}



extension GeneralCollectionViewController {
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
}

extension GeneralCollectionViewController {
	@objc func onDidReceiveData(_ notification: Notification) {
		if let data = notification.userInfo as? [String: PodcastViewModel] {
			for (_, viewModel) in data {
				viewModelDidChange(viewModel: viewModel)
			}
		}
	}
}
