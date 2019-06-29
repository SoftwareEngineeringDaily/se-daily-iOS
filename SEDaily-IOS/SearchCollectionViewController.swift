//
//  SearchTableViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 9/7/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import KTResponsiveUI

import StatefulViewController

private let reuseIdentifier = "Cell"

class SearchCollectionViewController: UICollectionViewController, StatefulViewController {
	
	private let podcastViewModelController = PodcastViewModelController()
	
	weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	private var progressController = PlayProgressModelController()
	
	var loading = false
	private let pageSize = 10
	private let preloadMargin = 5
	private var lastLoadedPage = 0
	var errorChecks = 0
	let maximumErrorChecks = 5
	
	private let searchController = UISearchController(searchResultsController: nil)
	private var searchText: String {
		return searchController.searchBar.text ?? ""
	}
	
	init(collectionViewLayout layout: UICollectionViewLayout,
			 audioOverlayDelegate: AudioOverlayDelegate?) {
		self.audioOverlayDelegate = audioOverlayDelegate
		super.init(collectionViewLayout: layout)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		
		
		searchController.searchBar.delegate = self
		searchController.searchBar.layer.borderWidth = 1
		searchController.searchBar.layer.borderColor = Stylesheet.Colors.light.cgColor
		searchController.searchBar.tintColor = Stylesheet.Colors.base
		searchController.searchBar.barTintColor = Stylesheet.Colors.light
		
		
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		
		self.collectionView?.contentInset = UIEdgeInsetsMake(searchController.searchBar.frame.height - UIView.getValueScaledByScreenHeightFor(baseValue: 10), 0, 0, 0)
		self.view.addSubview(searchController.searchBar)
		self.title = L10n.search
		
		self.loadingView = StateView(
			frame: CGRect.zero,
			text: L10n.fetchingSearch,
			showLoadingIndicator: true,
			showRefreshButton: false,
			delegate: nil)
		self.loadingView?.isUserInteractionEnabled = false
		
		self.emptyView = StateView(
			frame: CGRect.zero,
			text: L10n.emptySearch,
			showLoadingIndicator: false,
			showRefreshButton: false,
			delegate: nil)
		self.emptyView?.isUserInteractionEnabled = false
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.searchController.searchBar.isHidden = false
		self.setupInitialViewState()
		progressController.retrieve()
		self.collectionView?.reloadData()
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.searchController.searchBar.isHidden = true
	}
	
	deinit {
		// perform the deinitialization
		NotificationCenter.default.removeObserver(self)
	}
	
	func hasContent() -> Bool {
		return podcastViewModelController.viewModelsCount > 0
	}
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
			if let audioOverlayDelegate = self.audioOverlayDelegate {
				let vc = EpisodeViewController()
				vc.viewModel = viewModel
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
	
	@objc func loginObserver() {
		self.podcastViewModelController.clearViewModels()
		DispatchQueue.main.async {
			self.collectionView?.reloadData()
		}
		self.getData(lastIdentifier: "", nextPage: 0, firstSearch: false)
	}
}


extension SearchCollectionViewController {
	func checkPage(currentIndexPath: IndexPath, lastIndexPath: IndexPath, lastIdentifier: String) {
		let nextPage: Int = Int(currentIndexPath.item / self.pageSize) + 1
		let preloadIndex = nextPage * self.pageSize - self.preloadMargin
		
		if (currentIndexPath.item >= preloadIndex && self.lastLoadedPage < nextPage) || currentIndexPath == lastIndexPath {
			self.getData(lastIdentifier: lastIdentifier, nextPage: nextPage, firstSearch: false)
		}
	}
	
	func getData(lastIdentifier: String, nextPage: Int, firstSearch: Bool) {
		self.startLoading()
		guard self.loading == false else { return }
		self.loading = true
		podcastViewModelController.fetchSearchData(
			searchTerm: self.searchText.lowercased(),
			createdAtBefore: lastIdentifier,
			firstSearch: firstSearch,
			onSuccess: { [weak self] in
				self?.errorChecks = 0
				self?.loading = false
				self?.endLoading()
				self?.lastLoadedPage = nextPage
				DispatchQueue.main.async {
					self?.collectionView?.reloadData()
				} },
			onFailure: {  [weak self] (apiError) in
				self?.endLoading()
				self?.loading = false
				self?.errorChecks += 1
				log.error(apiError ?? "")
				guard let strongSelf = self else { return }
				guard strongSelf.errorChecks <= strongSelf.maximumErrorChecks else { return } })
	}
}

extension SearchCollectionViewController {
	func filterContentForSearchText(_ searchText: String) {
		guard !searchBarIsEmpty() else { return }
		self.getData(lastIdentifier: "", nextPage: 0, firstSearch: true)
	}
	
	func searchBarIsEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func isFiltering() -> Bool {
		let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
		return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
	}
}

extension SearchCollectionViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
}



extension SearchCollectionViewController {
	
	func commentsButtonPressed(_ viewModel: PodcastViewModel) {
		Analytics2.podcastCommentsViewed(podcastId: viewModel._id)
		let commentsViewController: CommentsViewController = CommentsViewController()
		if let thread = viewModel.thread {
			commentsViewController.rootEntityId = thread._id
			self.navigationController?.pushViewController(commentsViewController, animated: true)
		}
	}
}

extension SearchCollectionViewController {
	@objc func onDidReceiveData(_ notification: Notification) {
		if let data = notification.userInfo as? [String: PodcastViewModel] {
			for (_, viewModel) in data {
				viewModelDidChange(viewModel: viewModel)
			}
		}
	}
}

extension SearchCollectionViewController {
	private func viewModelDidChange(viewModel: PodcastViewModel) {
		self.podcastViewModelController.update(with: viewModel)
	}
}
