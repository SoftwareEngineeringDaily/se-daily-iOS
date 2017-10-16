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
import PopupDialog
import StoreKit
import MessageUI

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
        
        AskForReview.tryToExecute { didExecute in
            if didExecute {
                self.askForReview()
            }
        }
    }
    
    func setupNavBar() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.leftBarButtonPressed))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        switch User.getActiveUser().isLoggedIn() {
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
        let vc1 = PodcastPageViewController()
        let vc2 = JustForYouCollectionViewController(collectionViewLayout: layout)
        let vc3 = TopCollectionViewController(collectionViewLayout: layout)
//        let vc2 = GeneralCollectionViewController(collectionViewLayout: layout, type: API.Types.recommended)
//        let vc3 = GeneralCollectionViewController(collectionViewLayout: layout, type: API.Types.top)
        
        let icon1 = UITabBarItem(title: L10n.tabBarTitleLatest, image: #imageLiteral(resourceName: "mic_stand"), selectedImage: #imageLiteral(resourceName: "mic_stand_selected"))
        let icon2 = UITabBarItem(title: L10n.tabBarJustForYou, image: #imageLiteral(resourceName: "activity_feed"), selectedImage: #imageLiteral(resourceName: "activity_feed_selected"))
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
        imageView.image = #imageLiteral(resourceName: "Logo_BarButton")
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

    fileprivate func askForReview() {
        let popup = PopupDialog(title: L10n.enthusiasticHello,
                                message: L10n.appReviewPromptQuestion,
                                gestureDismissal: false)
        let feedbackPopup = PopupDialog(title: L10n.appReviewApology,
                                        message: L10n.appReviewGiveFeedbackQuestion)
        let feedbackYesButton = DefaultButton(title: L10n.enthusiasticSure) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["jeff@softwareengineeringdaily.com"])
                mail.setSubject(L10n.appReviewEmailSubject)
                
                self.present(mail, animated: true, completion: nil)
            }
        }
        
        let feedbackNoButton = DefaultButton(title: L10n.noWithGratitude) {
            popup.dismiss()
        }

        let yesButton = DefaultButton(title: L10n.enthusiasticYes) {
            SKStoreReviewController.requestReview()
            AskForReview.setReviewed()
        }

        let noButton = DefaultButton(title: L10n.genericNo) {
            popup.dismiss()
            self.present(feedbackPopup, animated: true, completion: nil)
        }

        popup.addButtons([yesButton, noButton])
        feedbackPopup.addButtons([feedbackYesButton, feedbackNoButton])
        self.present(popup, animated: true, completion: nil)
    }
}

extension CustomTabViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            AskForReview.setReviewed()
        default: break
        }
    }
}
