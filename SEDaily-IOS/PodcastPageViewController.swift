//
//  PodcastPageViewController.swift
//  SEDaily-IOS
//
//  Created by Keith Holliday on 7/26/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PodcastPageViewController: ButtonBarPagerTabStripViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.setupView()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
//        settings.style.selectedBarBackgroundColor = purpleInspireColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
//            newCell?.label.textColor = self?.purpleInspireColor
        }
        // change selected bar color
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let layout = UICollectionViewLayout()
        
        let child_1 = LatestCollectionViewController(collectionViewLayout: layout)
        child_1.tabTitle = "All"
        
        let child_2 = LatestCollectionViewController(collectionViewLayout: layout)
        child_2.tabTitle = "Business and Philosophy"
        child_2.tagId = 1068
        
        let child_3 = LatestCollectionViewController(collectionViewLayout: layout)
        child_3.tabTitle = "Blockchain"
        child_3.tagId = 1082
        
        let child_4 = LatestCollectionViewController(collectionViewLayout: layout)
        child_4.tabTitle = "Cloud Engineering"
        child_4.tagId = 1079
        
        let child_5 = LatestCollectionViewController(collectionViewLayout: layout)
        child_5.tabTitle = "Data"
        child_5.tagId = 1081
        
        let child_6 = LatestCollectionViewController(collectionViewLayout: layout)
        child_6.tabTitle = "JavaScript"
        child_6.tagId = 1084
        
        let child_7 = LatestCollectionViewController(collectionViewLayout: layout)
        child_7.tabTitle = "Machine Learning"
        child_7.tagId = 1080
        
        let child_8 = LatestCollectionViewController(collectionViewLayout: layout)
        child_8.tabTitle = "Open Source"
        child_8.tagId = 1078
        
        let child_9 = LatestCollectionViewController(collectionViewLayout: layout)
        child_9.tabTitle = "Security"
        child_9.tagId = 1083
        
        let child_10 = LatestCollectionViewController(collectionViewLayout: layout)
        child_10.tabTitle = "Hackers"
        child_10.tagId = 1085
        
        return [child_1, child_2, child_3, child_4, child_5]
        
    }
}
