//
//  JustForYouCollectionViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 7/25/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import RealmSwift
import KoalaTeaFlowLayout

private let reuseIdentifier = "Cell"

class JustForYouCollectionViewController: UICollectionViewController {
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var token: NotificationToken?
    var data: Results<PodcastModel> = {
        let data = PodcastModel.getTop()
        
        return data
    }()
    
    var itemCount = 0
    
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
            make.top.equalToSuperview().inset(20.calculateHeight())
            make.centerX.equalToSuperview()
        }
        
        loadData()
    }
    
    func loginObserver() {
        itemCount = 0
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        loadData()
    }
    
    func loadData() {
        activityView.startAnimating()
        
        guard User.getActiveUser().isLoggedIn() else {
            API.sharedInstance.getPosts(type: API.Types.top, completion: {_ in 
                self.activityView.stopAnimating()
            })
            self.data = PodcastModel.getTop()
            self.registerNotifications()
            return
        }
        API.sharedInstance.getRecommendedPosts(completion: {_ in 
            self.activityView.stopAnimating()
        })
        self.data = PodcastModel.getRecommended()
        self.registerNotifications()
    }
}


extension JustForYouCollectionViewController {
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if !data.isEmpty {
//            //            if data.count < 20 {
//            //                self.getData()
//            //            }
//            return data.count
//        }
//        //        self.getData()
//        return 0
        return itemCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PodcastCollectionViewCell
        
        let item = data[indexPath.row]
        
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
}

extension JustForYouCollectionViewController {
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
