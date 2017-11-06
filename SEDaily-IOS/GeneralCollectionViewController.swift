//
//  CollectionViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/12/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import KoalaTeaFlowLayout
import SDWebImage

private let reuseIdentifier = "Cell"

class GeneralCollectionViewController: UICollectionViewController {
    lazy var skeletonCollectionView: SkeletonCollectionView = {
        return SkeletonCollectionView(frame: self.collectionView!.frame)
    }()
    
    var type: PodcastTypes
    var tabTitle: String
    var tags: [Int]
    var categories: [Int]
    
    // Paging Properties
    var loading = false
    let pageSize = 10
    let preloadMargin = 5
    
    var lastLoadedPage = 0
    
    var customTabBarItem: UITabBarItem! {
        get {
            switch type {
            case .new:
                return nil
            case .recommended:
                return UITabBarItem(title: L10n.tabBarJustForYou, image: #imageLiteral(resourceName: "activity_feed"), selectedImage: #imageLiteral(resourceName: "activity_feed_selected"))
            case .top:
                return UITabBarItem(tabBarSystemItem: .mostViewed, tag: 0)
            }
        }
    }
    
    // ViewModelController
    private let podcastViewModelController: PodcastViewModelController = PodcastViewModelController()
    
    init(collectionViewLayout layout: UICollectionViewLayout,
         tags: [Int] = [],
         categories: [PodcastCategoryIds] = [],
         type: PodcastTypes = .new,
         tabTitle: String = "") {
        self.tabTitle = tabTitle
        self.type = type
        self.tags = tags
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
        self.collectionView?.register(PodcastCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let layout = KoalaTeaFlowLayout(cellWidth: UIView.getValueScaledByScreenWidthFor(baseValue: 158),
                                        cellHeight: UIView.getValueScaledByScreenHeightFor(baseValue: 250),
                                        topBottomMargin: UIView.getValueScaledByScreenHeightFor(baseValue: 12),
                                        leftRightMargin: UIView.getValueScaledByScreenWidthFor(baseValue: 20),
                                        cellSpacing: UIView.getValueScaledByScreenWidthFor(baseValue: 8))
        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.backgroundColor = .white
        
        // User Login observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
        
        self.collectionView?.addSubview(skeletonCollectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Make sure skeletonCollectionView is animating when the view is visible
        if self.skeletonCollectionView.alpha != 0 {
            self.skeletonCollectionView.collectionView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //@TODO: Find a better way to manage cached Images
        SDImageCache.shared().clearMemory()
    }
    
    @objc func loginObserver() {
        if self.type == .recommended {
            self.podcastViewModelController.clearViewModels()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PodcastCell
    
        // Configure the cell
        if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
            cell.viewModel = viewModel
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
        podcastViewModelController.fetchData(type: self.type.rawValue, createdAtBefore: lastIdentifier, tags: self.tags, categories: self.categories, page: nextPage, onSucces: {
            self.loading = false
            self.lastLoadedPage = nextPage
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }) { (apiError) in
            self.loading = false
            log.error(apiError)
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewModel = podcastViewModelController.viewModel(at: indexPath.row) {
            let vc = PodcastDetailViewController()
            vc.model = viewModel
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension GeneralCollectionViewController: PodcastDetailViewControllerDelegate {
    func modelDidChange(viewModel: PodcastViewModel) {
        self.podcastViewModelController.update(with: viewModel)
    }
}
