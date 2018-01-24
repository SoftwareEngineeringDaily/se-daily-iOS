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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        delegate = self

        self.view.backgroundColor = .white

        setupTabs()
        setupTitleView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavBar()
    }

    func setupNavBar() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.leftBarButtonPressed))
        self.navigationItem.rightBarButtonItem = rightBarButton

        switch UserManager.sharedInstance.getActiveUser().isLoggedIn() {
        case false:
            let leftBarButton = UIBarButtonItem(title: L10n.loginTitle, style: .done, target: self, action: #selector(self.loginButtonPressed))
            self.navigationItem.leftBarButtonItem = leftBarButton
        case true:
            let leftBarButton = UIBarButtonItem(title: L10n.logoutTitle, style: .done, target: self, action: #selector(self.logoutButtonPressed))
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
    }

    @objc func leftBarButtonPressed() {
        let vc = SearchTableViewController()
        self.navigationController?.pushViewController(vc)
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
            GeneralCollectionViewController(collectionViewLayout: layout, type: .top),
            BookmarkCollectionViewController(collectionViewLayout: layout)
        ]

        #if DEBUG
            let debugStoryboard = UIStoryboard.init(name: "Debug", bundle: nil)
            let debugViewController = debugStoryboard.instantiateViewController(
                withIdentifier: "DebugTabViewController")
            if let viewControllers = self.viewControllers {
                self.viewControllers =  viewControllers + [debugViewController]
            }
        #endif

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
}
