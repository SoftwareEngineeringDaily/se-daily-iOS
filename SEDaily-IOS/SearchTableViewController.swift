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
    
    var lastData = [PodcastModel]()
    var filteredData = [PodcastModel]()
    
    // MARK: - Paging
    let pageSize = 10
    let preloadMargin = 5
    var lastLoadedPage = 0
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchText: String {
        get {
            return searchController.searchBar.text ?? ""
        }
    }
    
    lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        return view
    }()
    
    var isLoading = false {
        didSet {
            switch isLoading {
            case true:
                activityView.startAnimating()
            case false:
                activityView.stopAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityView.center = self.view.center
        self.view.addSubview(activityView)
        
        self.tableView.register(PodcastTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = Stylesheet.Colors.base
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
//        definesPresentationContext = true
        
        self.tableView.tableHeaderView = searchController.searchBar
        
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UIView.getValueScaledByScreenHeightFor(baseValue: 75)
        
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
        return filteredData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PodcastTableViewCell

        let item = filteredData[indexPath.row]
        // Configure the cell...
        cell.setupCell(title: item.podcastName ?? "", imageURLString: item.imageURLString ?? nil)
        
        checkPage(indexPath: indexPath, item: item)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = filteredData[indexPath.row]
        let vc = PostDetailTableViewController()
        vc.model = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchTableViewController {
    // MARK: Data/Paging
    func checkPage(indexPath: IndexPath, item: PodcastModel) {
        let nextPage: Int = Int(indexPath.item / pageSize) + 1
        let preloadIndex = nextPage * pageSize - preloadMargin
        
        if (indexPath.item >= preloadIndex && lastLoadedPage < nextPage) || indexPath == tableView?.indexPathForLastRow! {
            if let lastDate = item.uploadDate {
                guard !self.isLoading else { return }
                self.isLoading = true
                getData(page: nextPage, lastItemDate: lastDate)
            }
        }
    }
    
    func getData(page: Int = 0, lastItemDate: String = "") {
        lastLoadedPage = page
        loadData(lastItemDate: lastItemDate)
    }
    
    func loadData(lastItemDate: String) {
        API.sharedInstance.getPostsWith(searchTerm: searchText.lowercased(), createdAtBefore: lastItemDate) { (podcastArray) in
            self.isLoading = false
            //@TODO: add podcastArray?.count is 0 check
            if let podcastArray = podcastArray {
                for item in podcastArray {
                    let existingObject = self.filteredData.filter { $0.podcastName! == item.podcastName! }.first
                    guard existingObject == nil else { continue }
                    self.filteredData.append(item)
                }
                // Guard for new data
                guard self.lastData != podcastArray else { return }
                self.lastData = podcastArray
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchTableViewController {
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String) {
        guard !searchBarIsEmpty() else { return }
        
        self.isLoading = true
        self.loadData(lastItemDate: "")
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
        if !filteredData.isEmpty {
            filteredData = [PodcastModel]()
        }
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {

    }
}

