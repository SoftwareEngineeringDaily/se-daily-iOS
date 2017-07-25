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
import SwiftIcons

class CustomTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    var ifset = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        delegate = self
        
        self.view.backgroundColor = .white
        
        setupTabs()
        setupSideMenu()
        setupTitleView()
        self.selectedIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    func setupNavBar() {
//        let leftBarButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(self.presentLeftSideMenu))
        
//        self.navigationItem.leftBarButtonItem = leftBarButton
        switch User.getActiveUser().isLoggedIn() {
        case false:
            let rightBarButton = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(self.loginButtonPressed))
            self.navigationItem.rightBarButtonItem = rightBarButton
            break
        case true:
            let rightBarButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.logoutButtonPressed))
            self.navigationItem.rightBarButtonItem = rightBarButton
            break
        }
    }
    
    func loginButtonPressed() {
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc)
    }
    
    func logoutButtonPressed() {
        User.logout()
        self.setupNavBar()
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
        let vc1 = LatestCollectionViewController(collectionViewLayout: layout)
        let vc2 = JustForYouCollectionViewController(collectionViewLayout: layout)
        let vc3 = TopCollectionViewController(collectionViewLayout: layout)
                
        let icon1 = UITabBarItem(title: "Latest", image: #imageLiteral(resourceName: "mic_stand"), selectedImage: #imageLiteral(resourceName: "mic_stand_selected"))
        let icon2 = UITabBarItem(title: "Just For You", image: #imageLiteral(resourceName: "activity_feed"), selectedImage: #imageLiteral(resourceName: "activity_feed_selected"))
        let icon3 = UITabBarItem(tabBarSystemItem: .mostViewed, tag: 0)
        
        vc1.tabBarItem = icon1
        vc2.tabBarItem = icon2
        vc3.tabBarItem = icon3
        
        let controllers = [vc1,vc2,vc3]
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
