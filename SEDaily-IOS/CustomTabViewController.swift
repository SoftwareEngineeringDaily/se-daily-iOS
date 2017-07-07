//
//  CustomTabViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/26/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

//
//  CustomTabViewController.swift
//  Kibbl-IOS
//
//  Created by Craig Holliday on 4/28/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SideMenu
import SwifterSwift
import SnapKit

class CustomTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    var ifset = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let leftBarButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.presentLeftSideMenu))
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        delegate = self
        
        self.view.backgroundColor = .white
        
        setupNavBar()
        setupTabs()
        setupSideMenu()
        setupTitleView()
        self.selectedIndex = 0
    }
    
    func setupNavBar() {
        
    }
    
//    func setupNavButton() {
//        let navBarHeight = 44.0
//        let height = navBarHeight / 1.5
//        let icon = #imageLiteral(resourceName: "Bell")
//        let iconSize = CGRect(origin: .zero, size: CGSize(width: height, height: height))
//        bellButton = UIButton(frame: iconSize)
//        bellButton.setBackgroundImage(icon, for: .normal)
//        bellButton.addTarget(self, action: #selector(self.updatesButtonPressed), for: .touchUpInside)
//        let barButton = UIBarButtonItem(customView: bellButton)
//        navigationItem.rightBarButtonItem = barButton
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTabs() {
        let layout = UICollectionViewLayout()
        let vc1 = PodcastCollectionViewController(collectionViewLayout: layout)
        let vc2 = FeedCollectionViewController(collectionViewLayout: layout)
                
        let icon1 = UITabBarItem(title: "Podcast", image: #imageLiteral(resourceName: "mic_stand"), selectedImage: nil)
        let icon2 = UITabBarItem(title: "Feed", image: #imageLiteral(resourceName: "activity_feed"), selectedImage: nil)
        
        vc1.tabBarItem = icon1
        vc2.tabBarItem = icon2
        
        let controllers = [vc1,vc2]
        self.viewControllers = controllers
        
        self.tabBar.backgroundColor = .white
        self.tabBar.isTranslucent = false
    }
    
    func setupTitleView() {
        let height = 40.calculateHeight()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
        self.navigationItem.titleView = imageView
    }
}

extension CustomTabViewController {
    fileprivate func setupSideMenu() {
        // Define the menus
        guard !ifset else { return }
//        let leftSideMenu = UISideMenuNavigationController(rootViewController: LeftViewController())
//        SideMenuManager.menuLeftNavigationController = leftSideMenu
        ifset = true
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        //        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        //        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // Set up a cool background image for demo purposes
        //        SideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        SideMenuManager.menuFadeStatusBar = false
        
        SideMenuManager.menuPresentMode = .viewSlideInOut
    }
    
    func presentLeftSideMenu() {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
}
