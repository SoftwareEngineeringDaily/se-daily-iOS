//
//  SearchTableViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 9/7/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import KTResponsiveUI

private let reuseIdentifier = "reuseIdentifier"

class SearchTableViewController: UITableViewController {

    // ViewModelController
    private let podcastViewModelController = PodcastViewModelController()

    lazy var footerView: UIActivityIndicatorView = {
        let footerView = UIActivityIndicatorView(height: 44)
        footerView.width = self.tableView.width
        footerView.activityIndicatorViewStyle = .gray
        return footerView
    }()

    // MARK: - Paging
    let pageSize = 10
    let preloadMargin = 5
    var lastLoadedPage = 0
    var loading = false

    let searchController = UISearchController(searchResultsController: nil)
    var searchText: String {
        return searchController.searchBar.text ?? ""
    }

    var isLoading = false {
        didSet {
            switch isLoading {
            case true:
                footerView.startAnimating()
            case false:
                footerView.stopAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(PodcastTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)

        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = Stylesheet.Colors.base
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
//        definesPresentationContext = true

        self.tableView.tableHeaderView = searchController.searchBar

        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UIView.getValueScaledByScreenHeightFor(baseValue: 75)

        self.tableView.tableFooterView = footerView

        self.title = "Search"
    }

    override func viewWillAppear(_ animated: Bool) {
        self.searchController.searchBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.searchController.searchBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastViewModelController.viewModelsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? PodcastTableViewCell else {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
            let vc = PodcastDetailViewController()
            vc.model = viewModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SearchTableViewController {
    // MARK: Data/Paging
    func checkPage(currentIndexPath: IndexPath, lastIndexPath: IndexPath, lastIdentifier: String) {
        let nextPage: Int = Int(currentIndexPath.item / self.pageSize) + 1
        let preloadIndex = nextPage * self.pageSize - self.preloadMargin

        if (currentIndexPath.item >= preloadIndex && self.lastLoadedPage < nextPage) || currentIndexPath == lastIndexPath {
            self.getData(lastIdentifier: lastIdentifier, nextPage: nextPage, firstSearch: false)
        }
    }

    func getData(lastIdentifier: String, nextPage: Int, firstSearch: Bool) {
        guard self.loading == false else { return }
        self.loading = true
        podcastViewModelController.fetchSearchData(
            searchTerm: self.searchText.lowercased(),
            createdAtBefore: lastIdentifier,
            firstSearch: firstSearch,
            onSucces: {
                self.loading = false
                self.lastLoadedPage = nextPage
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                } },
            onFailure: { (apiError) in
                self.loading = false
                log.error(apiError ?? "") })
    }
}

extension SearchTableViewController {
    // MARK: - Private instance methods

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
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
