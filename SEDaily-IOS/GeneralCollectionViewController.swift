//
//  GeneralCollectionViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 8/4/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import RealmSwift
import KoalaTeaFlowLayout
import XLPagerTabStrip
import SwifterSwift

private let reuseIdentifier = "Cell"

class GeneralCollectionViewController: UICollectionViewController, IndicatorInfoProvider {
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var type: String = ""
    var tabTitle = ""
    var tagId = -1
    var token: NotificationToken?
    var data: Results<PodcastModel>!
    
    var itemCount = 0
    
    // MARK: - Paging
    var loading = false
    
    let pageSize = 10
    let preloadMargin = 5
    var lastLoadedPage = 0
    
    enum APICheckDates {
        static let newFeedLastCheck = "newFeedLastCheck"
    }
    
    init(collectionViewLayout layout: UICollectionViewLayout, tagId: Int = -1, type: String) {
        super.init(collectionViewLayout: layout)
        
        self.tagId = tagId
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(PodcastCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.collectionView?.backgroundColor = UIColor(hex: 0xfafafa)
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.showsVerticalScrollIndicator = false
        
        let layout = KoalaTeaFlowLayout(ratio: 1, topBottomMargin: 12, leftRightMargin: 12, cellsAcross: 2, cellSpacing: 8)
        self.collectionView?.collectionViewLayout = layout
        
        // User Login observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
        
        // Add activity view
        self.view.addSubview(activityView)
        activityView.snp.makeConstraints {(make) -> Void in
            make.center.equalToSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginObserver() {
        loadData(lastItemDate: "")
    }
    
    // MARK: - Data stuff
    
    func getData(page: Int = 0, lastItemDate: String = "") {
        guard self.loading == false else { return }
        
        lastLoadedPage = page
        
        self.loading = true
        loadData(lastItemDate: lastItemDate)
    }
    
    func checkPage(indexPath: IndexPath, item: PodcastModel) {
        let nextPage: Int = Int(indexPath.item / pageSize) + 1
        let preloadIndex = nextPage * pageSize - preloadMargin
        
        if (indexPath.item >= preloadIndex && lastLoadedPage < nextPage) || indexPath == collectionView?.indexPathForLastItem! {
            if let lastDate = item.uploadDate {
                //@TODO: This is left open for paging for recommended and top posts
                // (I think top posts could be paged)
                guard type != API.Types.recommended || type != API.Types.top else { return }
                getData(page: nextPage, lastItemDate: lastDate)
            }
        }
    }
    
    // @TODO: Move to repository
    func loadNewLocalPodcasts (hasChanges: Bool) {
        self.activityView.stopAnimating()
        
        //@TODO: Fix this, right now it stops all loading completely
        //        if hasChanges {
        self.loading = false
        //        }
        
        // @TODO: Should probably only load count
        var returnData = PodcastModel.all()
        
        if self.tagId != -1 {
            returnData = returnData.filter("categories CONTAINS '\(self.tagId)'")
        }
        
        self.data = returnData.sorted(byKeyPath: "uploadDate", ascending: false)
        self.registerNotifications()
    }
    
    func alreadyLoadedNewToday (tagId: Int?) -> Bool {
        let defaults = UserDefaults.standard
        var key = APICheckDates.newFeedLastCheck
        
        if tagId != nil && tagId! > -1 {
            key = "\(key)-\(String(describing: tagId!))"
        }
        
        if let newFeedLastCheck = defaults.string(forKey: key) {
            let todayDate = Date().dateString()
            let newFeedDate = Date(iso8601String: newFeedLastCheck)!.dateString()
            if (newFeedDate == todayDate) {
                return true
            }
            
            return false
        }
        return false
    }
    
    func setLoadedNewToday (tagId: Int?) {
        let todayString = Date().iso8601String
        
        var key = APICheckDates.newFeedLastCheck
        if tagId != nil && tagId! > -1 {
            key = "\(key)-\(String(describing: tagId!))"
        }
        
        let defaults = UserDefaults.standard
        defaults.set(todayString, forKey: key)
    }
    
    func alreadyLoadMoreThanLastItemDateToday (tagId: Int, lastItemDate: String?) -> Bool {
        let defaults = UserDefaults.standard
        var key = APICheckDates.newFeedLastCheck
        
        if tagId > -1 {
            key = "\(key)-\(String(describing: tagId))"
        }
        
        if lastItemDate == nil || (lastItemDate?.isEmpty)! {
            return false
        }
        
        let lastItemDateString = Date(iso8601String: lastItemDate!)
        key = "\(key)-\(String(describing: lastItemDateString))"
        
        if let newFeedLastCheck = defaults.string(forKey: key) {
            let todayDate = Date().dateString()
            let newFeedDate = Date(iso8601String: newFeedLastCheck)!.dateString()
            
            if (newFeedDate == todayDate) {
                return true
            }
            
            return false
        }
        
        return false
    }
    
    func setLoadMoreThanLastItemDateToday (tagId: Int, lastItemDate: String?) {
        let todayString = Date().iso8601String
        
        var key = APICheckDates.newFeedLastCheck
        if tagId > -1 {
            key = "\(key)-\(String(describing: tagId))"
        }
        
        if lastItemDate == nil || (lastItemDate?.isEmpty)! {
            return
        }
        
        let lastItemDateString = Date(iso8601String: lastItemDate!)
        key = "\(key)-\(String(describing: lastItemDateString))"
        
        let defaults = UserDefaults.standard
        defaults.set(todayString, forKey: key)
    }
    
    func loadData(lastItemDate: String) {
        //@TODO: Fix this for recommended and top
        switch type {
        case API.Types.new:
            let alreadLoadedStartToday = self.alreadyLoadedNewToday(tagId: self.tagId)
            let alreadyLoadedCurrentTime = lastItemDate.isEmpty || self.alreadyLoadMoreThanLastItemDateToday(tagId: self.tagId, lastItemDate: lastItemDate)
            
            if (alreadLoadedStartToday && alreadyLoadedCurrentTime) {
                // !TODO: This may be being called during scroll when it doesn't need to be since we load all. However, we probably shouldn't load all from realm?
                self.loadNewLocalPodcasts(hasChanges: false)
                return;
            }
            
            self.activityView.startAnimating()
            
            API.sharedInstance.getPosts(type: type, createdAtBefore: lastItemDate, categoires: String(self.tagId), completion: { (hasChanges) in
                self.setLoadedNewToday(tagId: self.tagId)
                self.setLoadMoreThanLastItemDateToday(tagId: self.tagId, lastItemDate: lastItemDate)
                self.loadNewLocalPodcasts(hasChanges: hasChanges)
            })
            break
        case API.Types.recommended:
            guard User.getActiveUser().isLoggedIn() else {
                API.sharedInstance.getPosts(type: API.Types.top, createdAtBefore: lastItemDate, completion: { (hasChanges) in
                    self.activityView.stopAnimating()
                    
                    if hasChanges {
                        self.loading = false
                    }
                    
                    self.data = PodcastModel.getTop()
                    self.registerNotifications()
                })
                break
            }
            API.sharedInstance.getRecommendedPosts(completion: { (hasChanges) in
                self.activityView.stopAnimating()
                
                if hasChanges {
                    self.loading = false
                }
                
                self.data = PodcastModel.getRecommended()
                self.registerNotifications()
            })
            break
        case API.Types.top:
            API.sharedInstance.getPosts(type: API.Types.top, createdAtBefore: lastItemDate, completion: { (hasChanges) in
                self.activityView.stopAnimating()
                
                if hasChanges {
                    self.loading = false
                }
                
                self.data = PodcastModel.getTop()
                self.registerNotifications()
            })
            break
        default:
            break
        }
    }
}

extension GeneralCollectionViewController {
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        if !data.isEmpty {
        if itemCount < 10 {
            self.getData()
        }
        return itemCount
        //        }
        self.getData()
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PodcastCollectionViewCell
        
        let item = data[indexPath.row]
        
        checkPage(indexPath: indexPath, item: item)
        
        // Configure the cell
        cell.setupCell(model: item)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        let vc = PostDetailTableViewController()
        vc.model = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.tabTitle)
    }
}

extension GeneralCollectionViewController {
    // MARK: Realm
    func registerNotifications() {
        token = data.addNotificationBlock {[weak self] (changes: RealmCollectionChange) in
            guard let collectionView = self?.collectionView else { return }
            
            switch changes {
            case .initial:
                guard let int = self?.data.count else { return }
                self?.itemCount = int
                collectionView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                let deleteIndexPaths = deletions.map { IndexPath(item: $0, section: 0) }
                let insertIndexPaths = insertions.map { IndexPath(item: $0, section: 0) }
                let updateIndexPaths = modifications.map { IndexPath(item: $0, section: 0) }
                
                self?.collectionView?.performBatchUpdates({
                    self?.collectionView?.deleteItems(at: deleteIndexPaths)
                    if !deleteIndexPaths.isEmpty {
                        self?.itemCount -= 1
                    }
                    self?.collectionView?.insertItems(at: insertIndexPaths)
                    if !insertIndexPaths.isEmpty {
                        self?.itemCount += 1
                    }
                    self?.collectionView?.reloadItems(at: updateIndexPaths)
                }, completion: nil)
                break
            case .error(let error):
                print(error)
                break
            }
        }
    }
}
