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

    private var viewModelController = BookmarkViewModelController()

    lazy var skeletonCollectionView: SkeletonCollectionView = {
        return SkeletonCollectionView(frame: self.collectionView!.frame)
    }()

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.register(
            PodcastCell.self,
            forCellWithReuseIdentifier: BookmarkCollectionViewController.cellId)

        let layout = KoalaTeaFlowLayout(
            cellWidth: UIView.getValueScaledByScreenWidthFor(baseValue: 158),
            cellHeight: UIView.getValueScaledByScreenHeightFor(baseValue: 250),
            topBottomMargin: UIView.getValueScaledByScreenHeightFor(baseValue: 12),
            leftRightMargin: UIView.getValueScaledByScreenWidthFor(baseValue: 20),
            cellSpacing: UIView.getValueScaledByScreenWidthFor(baseValue: 8))
        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.backgroundColor = .white

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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookmarkCollectionViewController.cellId,
            for: indexPath) as? PodcastCell else {
                return UICollectionViewCell()
        }

        if let viewModel = self.viewModelController.viewModel(at: indexPath.row) {
            cell.viewModel = viewModel            
        }

        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        if let viewModel = viewModelController.viewModel(at: indexPath.row) {
            let vc = PodcastDetailViewController()
            vc.model = viewModel
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
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
