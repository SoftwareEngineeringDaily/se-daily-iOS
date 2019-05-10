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

class SearchTableViewController: UIViewController, StatefulViewController {
	
	private let podcastViewModelController = PodcastViewModelController()
	weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	private var progressController = PlayProgressModelController()
	
	private let pageSize = 10
	private let preloadMargin = 5
	private var lastLoadedPage = 0
	private let searchController = UISearchController(searchResultsController: nil)
	private var searchText: String {
		return searchController.searchBar.text ?? ""
	}
	private var tableView: UITableView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		
		self.tableView = UITableView()
		if let tableView = self.tableView {
			tableView.dataSource = self
			tableView.delegate = self
			self.view.addSubview(tableView)
			tableView.tableFooterView = UIView()
			tableView.snp.makeConstraints { (make) in
				make.edges.equalToSuperview()
			}
			tableView.register(cellType: PodcastTableViewCell.self)
			tableView.tableHeaderView = searchController.searchBar
			tableView.separatorStyle = .singleLine
			tableView.rowHeight = UITableViewAutomaticDimension
			tableView.estimatedRowHeight = 50.0
			tableView.backgroundColor = Stylesheet.Colors.light
			
		}
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
		self.tableView?.reloadData()
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
}

extension SearchTableViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.podcastViewModelController.viewModelsCount
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let viewModel = self.podcastViewModelController.viewModel(at: indexPath.row) {
			if let audioOverlayDelegate = self.audioOverlayDelegate {
				let vc = EpisodeViewController(nibName: nil, bundle: nil, audioOverlayDelegate: audioOverlayDelegate)
				vc.viewModel = viewModel
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
}

extension SearchTableViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let viewModel = podcastViewModelController.viewModel(at: indexPath.row) else { return UITableViewCell() }
		
		let cell: PodcastTableViewCell = tableView.dequeueReusableCell(for: indexPath)
		cell.selectionStyle = .none
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
		
		return cell
	}
}




extension SearchTableViewController {
	func checkPage(currentIndexPath: IndexPath, lastIndexPath: IndexPath, lastIdentifier: String) {
		let nextPage: Int = Int(currentIndexPath.item / self.pageSize) + 1
		let preloadIndex = nextPage * self.pageSize - self.preloadMargin
		
		if (currentIndexPath.item >= preloadIndex && self.lastLoadedPage < nextPage) || currentIndexPath == lastIndexPath {
			self.getData(lastIdentifier: lastIdentifier, nextPage: nextPage, firstSearch: false)
		}
	}
	
	func getData(lastIdentifier: String, nextPage: Int, firstSearch: Bool) {
		self.startLoading()
		
		podcastViewModelController.fetchSearchData(
			searchTerm: self.searchText.lowercased(),
			createdAtBefore: lastIdentifier,
			firstSearch: firstSearch,
			onSuccess: { [weak self] in
				self?.endLoading()
				self?.lastLoadedPage = nextPage
				DispatchQueue.main.async {
					self?.tableView?.reloadData()
				} },
			onFailure: {  [weak self] (apiError) in
				self?.endLoading()
				log.error(apiError ?? "") })
	}
}

extension SearchTableViewController {
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

extension SearchTableViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
}



extension SearchTableViewController {
	
	func commentsButtonPressed(_ viewModel: PodcastViewModel) {
		Analytics2.podcastCommentsViewed(podcastId: viewModel._id)
		let commentsViewController: CommentsViewController = CommentsViewController()
		if let thread = viewModel.thread {
			commentsViewController.rootEntityId = thread._id
			self.navigationController?.pushViewController(commentsViewController, animated: true)
		}
	}
}
	
	extension SearchTableViewController {
		@objc func onDidReceiveData(_ notification: Notification) {
			if let data = notification.userInfo as? [String: PodcastViewModel] {
				for (_, viewModel) in data {
					viewModelDidChange(viewModel: viewModel)
				}
			}
		}
	}
	
	
	extension SearchTableViewController {
		private func viewModelDidChange(viewModel: PodcastViewModel) {
			self.podcastViewModelController.update(with: viewModel)
		}
}
