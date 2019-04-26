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
    weak var audioOverlayDelegate: AudioOverlayDelegate?
    var customTabBarItem: UITabBarItem! {
        return UITabBarItem(title: L10n.tabBarTitleLatest, image: #imageLiteral(resourceName: "mic_stand"), selectedImage: #imageLiteral(resourceName: "mic_stand_selected"))
    }

    init(audioOverlayDelegate: AudioOverlayDelegate?) {
        self.audioOverlayDelegate = audioOverlayDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem = customTabBarItem

        self.dataSource = self

        self.loadViewControllers()

        // configure the bar
        self.bar.style = .scrollingButtonBar
			
				bar.appearance = TabmanBar.Appearance({ (appearance) in
					appearance.style.background = .solid(color: UIColor.white)
					appearance.indicator.color = Stylesheet.Colors.base
					appearance.state.selectedColor = Stylesheet.Colors.base
				})
			

        self.bar.items = barItems

        self.reloadPages()

        // Set the tab bar controller first selected item here
        self.tabBarController?.selectedIndex = 0
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

        viewControllers = [
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            tabTitle: PodcastCategoryIds.All.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Greatest_Hits],
                                            tabTitle: PodcastCategoryIds.Greatest_Hits.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Business_and_Philosophy],
                                            tabTitle: PodcastCategoryIds.Business_and_Philosophy.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Blockchain],
                                            tabTitle: PodcastCategoryIds.Blockchain.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Cloud_Engineering],
                                            tabTitle: PodcastCategoryIds.Cloud_Engineering.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Data],
                                            tabTitle: PodcastCategoryIds.Data.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.JavaScript],
                                            tabTitle: PodcastCategoryIds.JavaScript.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Machine_Learning],
                                            tabTitle: PodcastCategoryIds.Machine_Learning.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Open_Source],
                                            tabTitle: PodcastCategoryIds.Open_Source.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Security],
                                            tabTitle: PodcastCategoryIds.Security.description),
            GeneralCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate,
                                            categories: [PodcastCategoryIds.Hackers],
                                            tabTitle: PodcastCategoryIds.Hackers.description)
        ]

        viewControllers.forEach { (controller) in
            barItems.append(Item(title: controller.tabTitle))
        }
    }
}
