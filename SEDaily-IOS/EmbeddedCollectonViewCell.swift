//
//  EmbeddedCollectonViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit
import KoalaTeaFlowLayout
import RealmSwift

class EmbeddedCollectonViewCell: UICollectionViewCell {
    var token: NotificationToken?
    var data: Results<PodcastModel>!
    var fromViewController: UIViewController!
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(collectionView)
        
        collectionView.register(PodcastCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.showsVerticalScrollIndicator = false
        
        let height = contentView.height
        
        collectionView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalToSuperview()
            make.height.equalTo(height)
        }
        
        let layout = KoalaTeaFlowLayout(ratio: 1, topBottomMargin: 5, leftRightMargin: 10, cellsDown: 1, cellSpacing: 10, collectionViewHeight: height)
        collectionView.collectionViewLayout = layout
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func setupCell(type: String, fromViewController: UIViewController) {
        self.fromViewController = fromViewController
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.addSubview(activityView)
        activityView.center = self.contentView.center
        
        activityView.startAnimating()
        log.info("setting up")
        switch type {
        case API.Types.top:
            API.sharedInstance.getPosts(type: type, completion: {_ in 
                activityView.stopAnimating()
            })
            self.data = PodcastModel.getTop()
            self.registerNotifications()
        case API.Types.recommended:
            guard User.getActiveUser().isLoggedIn() else {
                API.sharedInstance.getPosts(type: API.Types.top, completion: {_ in 
                    activityView.stopAnimating()
                })
                self.data = PodcastModel.getTop()
                self.registerNotifications()
                break
            }
            API.sharedInstance.getRecommendedPosts(completion: {_ in 
                activityView.stopAnimating()
            })
            self.data = PodcastModel.getRecommended()
            self.registerNotifications()
        default: // new
            API.sharedInstance.getPosts(type: type, completion: {_ in 
                activityView.stopAnimating()
            })
            
            self.data = PodcastModel.all().sorted(byKeyPath: "uploadDate", ascending: false)
            self.registerNotifications()
        }
    }
}

extension EmbeddedCollectonViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard data != nil else { return 0 }
        if !data.isEmpty {
//            if data.count < 20 {
//                self.getData()
//            }
            return data.count
        }
//        self.getData()
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PodcastCollectionViewCell
        
        let item = data[indexPath.row]
        
        // Configure the cell
        cell.setupCell(model: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        let vc = PostDetailTableViewController()
        vc.model = item
        fromViewController.navigationController?.pushViewController(vc, animated: true)
    }
}


extension EmbeddedCollectonViewCell {
    // MARK: Realm
    func registerNotifications() {
        token = data.addNotificationBlock {[weak self] (changes: RealmCollectionChange) in
            guard let collectionView = self?.collectionView else { return }
            
            switch changes {
            case .initial:
                collectionView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                let deleteIndexPaths = deletions.map { IndexPath(item: $0, section: 0) }
                let insertIndexPaths = insertions.map { IndexPath(item: $0, section: 0) }
                let updateIndexPaths = modifications.map { IndexPath(item: $0, section: 0) }
                
                self?.collectionView.performBatchUpdates({
                    self?.collectionView.deleteItems(at: deleteIndexPaths)
                    self?.collectionView.insertItems(at: insertIndexPaths)
                    self?.collectionView.reloadItems(at: updateIndexPaths)
                }, completion: nil)
                break
            case .error(let error):
                print(error)
                break
            }
        }
    }
}
