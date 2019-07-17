
//
//  PostsForTopicTableViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/16/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//


import UIKit


private let reuseIdentifier = "Cell"

class PostsForTopicCollectionViewController: UICollectionViewController, MainCoordinated {
  var mainCoordinator: MainFlowCoordinator?
  
	lazy var skeletonCollectionView: SkeletonCollectionView = {
		return SkeletonCollectionView(frame: self.collectionView!.frame)
	}()
	
	
	var topic: Topic
	
	private var progressController = PlayProgressModelController()
	
	// Paging Properties
	var loading = false
	let pageSize = 10
	let preloadMargin = 5
	
	var lastLoadedPage = 0
	var errorChecks = 0
	let maximumErrorChecks = 5
	
	
	// ViewModelController
	private let podcastViewModelController: PodcastViewModelController = PodcastViewModelController()
	
	init(collectionViewLayout layout: UICollectionViewLayout,
			 topic: Topic = Topic(_id: "", name: "", slug: "", status: "", postCount: 0)
		) {
		
		self.topic = topic
		super.init(collectionViewLayout: layout)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = topic.name
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
		podcastViewModelController.fetchTopicData(
			slug: topic._id,
			createdAtBefore: lastIdentifier,
			onSuccess: { [weak self] in
				self?.errorChecks = 0
				self?.loading = false
				self?.lastLoadedPage = nextPage
				DispatchQueue.main.async {
					self?.collectionView?.reloadData()
				} },
			onFailure: {  [weak self] (apiError) in
				self?.loading = false
				self?.errorChecks += 1
				log.error(apiError ?? "")
				guard let strongSelf = self else { return }
				guard strongSelf.errorChecks <= strongSelf.maximumErrorChecks else { return }
		})
	}
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
			
				let vc = EpisodeViewController()
        mainCoordinator?.configure(viewController: vc)
				vc.viewModel = viewModel
				self.navigationController?.pushViewController(vc, animated: true)
			
		}
	}
}

extension PostsForTopicCollectionViewController {
	private func viewModelDidChange(viewModel: PodcastViewModel) {
		self.podcastViewModelController.update(with: viewModel)
	}
}



extension PostsForTopicCollectionViewController {
	func commentsButtonPressed(_ viewModel: PodcastViewModel) {
		Analytics2.podcastCommentsViewed(podcastId: viewModel._id)
		let commentsViewController: CommentsViewController = CommentsViewController()
		if let thread = viewModel.thread {
			commentsViewController.rootEntityId = thread._id
			self.navigationController?.pushViewController(commentsViewController, animated: true)
		}
	}
}

extension PostsForTopicCollectionViewController {
	@objc func onDidReceiveData(_ notification: Notification) {
		if let data = notification.userInfo as? [String: PodcastViewModel] {
			for (_, viewModel) in data {
				viewModelDidChange(viewModel: viewModel)
			}
		}
	}
}
