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
    private let reuseIdentifier = "reuseIdentifier"
    private let podcastViewModelController = PodcastViewModelController()
    weak var audioOverlayDelegate: AudioOverlayDelegate?

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

        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = Stylesheet.Colors.base
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
            tableView.register(PodcastTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            tableView.tableHeaderView = searchController.searchBar
            tableView.separatorStyle = .singleLine
            tableView.rowHeight = UIView.getValueScaledByScreenHeightFor(baseValue: 75)
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchController.searchBar.isHidden = true
    }

    func hasContent() -> Bool {
        return podcastViewModelController.viewModelsCount > 0
    }
}

extension SearchTableViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.podcastViewModelController.viewModelsCount
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = self.podcastViewModelController.viewModel(at: indexPath.row) {
            if let audioOverlayDelegate = self.audioOverlayDelegate {
                let vc = PodcastDetailViewController(nibName: nil, bundle: nil, audioOverlayDelegate: audioOverlayDelegate)
                vc.model = viewModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension SearchTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath) as? PodcastTableViewCell else {
                return UITableViewCell()
        }

        if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
            cell.viewModel = viewModel
            if let lastIndexPath = self.tableView?.indexPathForLastRow {
                if let lastItem = podcastViewModelController.viewModel(at: lastIndexPath.row) {
                    self.checkPage(currentIndexPath: indexPath,
                                   lastIndexPath: lastIndexPath,
                                   lastIdentifier: lastItem.uploadDateiso8601)
                }
            }
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
