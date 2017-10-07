//
//  PodcastCollectionViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/26/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import RealmSwift
import KoalaTeaFlowLayout

private let reuseIdentifier = "Cell"

class PodcastCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(EmbeddedCollectonViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(supplementaryViewOfKind: UICollectionElementKindSectionHeader, withClass: CollectionReusableView.self)

        self.collectionView?.backgroundColor = UIColor(hex: 0xfafafa)
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.showsVerticalScrollIndicator = false
        
        let layout = KoalaTeaFlowLayout(ratio: 0.5, cellsAcross: 1, cellSpacing: 0)
        self.collectionView?.collectionViewLayout = layout
        
        // User Login observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
    }
    
    @objc func loginObserver() {
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EmbeddedCollectonViewCell

        // Configure the cell
        switch indexPath.section {
        case 1:
            
            cell.setupCell(type: API.Types.recommended, fromViewController: self)
            
            return cell
        case 2:
            cell.setupCell(type: API.Types.top, fromViewController: self)
            
            return cell
        default:
            cell.setupCell(type: API.Types.new, fromViewController: self)
            
            return cell
        }
        
    }
}

extension PodcastCollectionViewController {
    // MARK: Header
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionReusableView.self, for: indexPath)
        
        
        switch indexPath.section {
        case 1:
            reusableview?.setupTitleLabel(title: "Just For You")
        case 2:
            reusableview?.setupTitleLabel(title: "Greatest Hits")
        default:
            reusableview?.setupTitleLabel(title: "Latest")
        }
        
        return reusableview!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: self.collectionView!.width, height: 60.calculateHeight())
    }
}
