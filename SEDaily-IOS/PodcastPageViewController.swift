//
//  PodcastPageViewController.swift
//  SEDaily-IOS
//
//  Created by Keith Holliday on 7/26/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class PodcastPageViewController: TabmanViewController, PageboyViewControllerDataSource {
    
    var viewControllers = [GeneralCollectionViewController]()
    var barItems = [TabmanBar.Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        self.loadViewControllers()
        
        // configure the bar
        self.bar.style = .scrollingButtonBar
        
        self.bar.items = barItems
        
        self.reloadPages()
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func loadViewControllers() {
        let layout = UICollectionViewLayout()
        
        let child_1 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      tabTitle: PodcastCategoryIds.All.description)
        viewControllers.append(child_1)
        
        
        let child_2 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.Business_and_Philosophy],
                                                      tabTitle: PodcastCategoryIds.Business_and_Philosophy.description)
        viewControllers.append(child_2)

        let child_3 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.Blockchain],
                                                      tabTitle: PodcastCategoryIds.Blockchain.description)
        viewControllers.append(child_3)

        let child_4 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.Cloud_Engineering],
                                                      tabTitle: PodcastCategoryIds.Cloud_Engineering.description)
        viewControllers.append(child_4)

        let child_5 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.Data],
                                                      tabTitle: PodcastCategoryIds.Data.description)
        viewControllers.append(child_5)

        let child_6 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.JavaScript],
                                                      tabTitle: PodcastCategoryIds.JavaScript.description)
        viewControllers.append(child_6)

        let child_7 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.Machine_Learning],
                                                      tabTitle: PodcastCategoryIds.Machine_Learning.description)
        viewControllers.append(child_7)

        let child_8 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.Open_Source],
                                                      tabTitle: PodcastCategoryIds.Open_Source.description)
        viewControllers.append(child_8)

        let child_9 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                      categories: [PodcastCategoryIds.Security],
                                                      tabTitle: PodcastCategoryIds.Security.description)
        viewControllers.append(child_9)

        let child_10 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                       categories: [PodcastCategoryIds.Hackers],
                                                       tabTitle: PodcastCategoryIds.Hackers.description)
        viewControllers.append(child_10)

        let child_11 = GeneralCollectionViewController(collectionViewLayout: layout,
                                                       categories: [PodcastCategoryIds.Greatest_Hits],
                                                       tabTitle: PodcastCategoryIds.Greatest_Hits.description)
        viewControllers.append(child_11)
        
        viewControllers.forEach { (controller) in
            barItems.append(Item(title: controller.tabTitle))
        }
    }
}
