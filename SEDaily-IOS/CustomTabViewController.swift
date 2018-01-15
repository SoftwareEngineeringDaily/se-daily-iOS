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
import SwifterSwift
import SnapKit
import SwiftIcons

class CustomTabViewController: UITabBarController, UITabBarControllerDelegate {

    var ifset = false
    
    var actionSheet = UIAlertController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        delegate = self

        self.view.backgroundColor = .white

        setupTabs()
        setupTitleView()
    }

    override func viewDidAppear(_ animated: Bool) {
        setupNavBar()
    }

    func setupNavBar() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.rightBarButtonPressed))
        self.navigationItem.rightBarButtonItem = rightBarButton

        switch UserManager.sharedInstance.getActiveUser().isLoggedIn() {
        case false:
            let leftBarButton = UIBarButtonItem(title: L10n.loginTitle, style: .done, target: self, action: #selector(self.loginButtonPressed))
            self.navigationItem.leftBarButtonItem = leftBarButton
        case true:
            let leftBarButton = UIBarButtonItem(title: L10n.logoutTitle, style: .plain, target: self, action: #selector(self.leftBarButtonPressed))
            
            // Hacky way to show bars icon
            let iconSize: CGFloat = 16.0
            let image = UIImage(bgIcon: .fontAwesome(.bars), bgTextColor: .clear, bgBackgroundColor: .clear, topIcon: .fontAwesome(.bars), topTextColor: .white, bgLarge: false, size: CGSize(width: iconSize, height: iconSize))
            leftBarButton.image = image
            leftBarButton.imageInsets = UIEdgeInsets(top: 0, left: -(iconSize / 2), bottom: 0, right: 0)

            self.navigationItem.leftBarButtonItem = leftBarButton
        }
    }

    @objc func rightBarButtonPressed() {
        let vc = SearchTableViewController()
        self.navigationController?.pushViewController(vc)
    }
    
    @objc func leftBarButtonPressed() {
        self.setupLogoutSubscriptionActionSheet()
        self.actionSheet.show()
    }

    @objc func loginButtonPressed() {
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc)
    }

    @objc func logoutButtonPressed() {
        UserManager.sharedInstance.logoutUser()
        self.setupNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupTabs() {
        let layout = UICollectionViewLayout()

        self.viewControllers = [
            PodcastPageViewController(),
            GeneralCollectionViewController(collectionViewLayout: layout, type: .recommended),
            GeneralCollectionViewController(collectionViewLayout: layout, type: .top)
        ]

        self.tabBar.backgroundColor = .white
        self.tabBar.isTranslucent = false
    }

    func setupTitleView() {
        let height = UIView.getValueScaledByScreenHeightFor(baseValue: 40)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "Logo_BarButton")
        self.navigationItem.titleView = imageView
    }
    
    func setupLogoutSubscriptionActionSheet() {
        self.actionSheet = UIAlertController(title: "", message: "Whatcha wanna do?", preferredStyle: .actionSheet)
        
        switch UserManager.sharedInstance.getActiveUser().hasPremium {
        case true:
            self.actionSheet.addAction(title: "View Subscription", style: .default, isEnabled: true) { _ in
                // Show view subscription status view
                let rootVC = SubscriptionStatusViewController()
                let navVC = UINavigationController(rootViewController: rootVC)
                self.present(navVC, animated: true, completion: nil)
            }
        case false:
            self.actionSheet.addAction(title: "Purchase Subscription", style: .default, isEnabled: true) { _ in
                // Show purchase subscription view
                let rootVC = PurchaseSubscriptionViewController()
                let navVC = UINavigationController(rootViewController: rootVC)
                self.present(navVC, animated: true, completion: nil)
            }
        }
        
        self.actionSheet.addAction(title: "Logout", style: .destructive, isEnabled: true) { _ in
            self.logoutButtonPressed()
        }
        self.actionSheet.addAction(title: "Cancel", style: .cancel, isEnabled: true) { _ in
            self.actionSheet.dismiss(animated: true, completion: nil)
        }
    }
}
