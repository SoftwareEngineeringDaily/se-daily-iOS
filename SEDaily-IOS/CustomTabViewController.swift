//
//  CustomTabViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/26/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

enum CollectionConfig {
	case latest
	case bookmarks
	case downloaded
	case search
}

import UIKit
import MessageUI
import PopupDialog
import SnapKit
import StoreKit
import SwifterSwift
import SwiftIcons
import Firebase

class CustomTabViewController: UITabBarController, UITabBarControllerDelegate {

    var ifset = false

    var actionSheet = UIAlertController()

    weak var audioOverlayDelegate: AudioOverlayDelegate?

    init(audioOverlayDelegate: AudioOverlayDelegate?) {
        self.audioOverlayDelegate = audioOverlayDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.view.backgroundColor = .white

        setupTabs()
        setupTitleView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavBar()

        AskForReview.tryToExecute { didExecute in
            if didExecute {
                self.askForReview()
            }
        }
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
        vc.audioOverlayDelegate = self.audioOverlayDelegate
        self.navigationController?.pushViewController(vc)
        Analytics2.searchNavButtonPressed()
    }

    @objc func leftBarButtonPressed() {
        self.setupLogoutSubscriptionActionSheet()
        self.actionSheet.show()
    }

    @objc func loginButtonPressed() {
        Analytics2.loginNavButtonPressed()
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc)
    }

    @objc func logoutButtonPressed() {
        Analytics2.logoutNavButtonPressed()
        UserManager.sharedInstance.logoutUser()
        self.setupNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupTabs() {
        let layout = UICollectionViewLayout()

        let feedListStoryboard = UIStoryboard.init(name: "FeedList", bundle: nil)
        guard let FeedViewController = feedListStoryboard.instantiateViewController(
            withIdentifier: "FeedListViewController") as? FeedListViewController else {
                return
        }
        FeedViewController.audioOverlayDelegate = self.audioOverlayDelegate

        
        let forumStoryboard = UIStoryboard.init(name: "ForumList", bundle: nil)
        guard let ForumViewController = forumStoryboard.instantiateViewController(
            withIdentifier: "ForumListViewController") as? ForumListViewController else {
                return
        }
        
//        ForumViewController.audioOverlayDelegate = self.audioOverlayDelegate
			
			//            FeedViewController,
			//            ForumViewController,
			//            BookmarkCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate),
			//            NotificationsTableViewController()

        
        self.viewControllers = [
            PodcastPageViewController(audioOverlayDelegate: self.audioOverlayDelegate),
					ProfileViewController(),
					ForumViewController,
					BookmarkCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate),
					NotificationsTableViewController()
        ]

        #if DEBUG
            // This will cause the tab bar to overflow so it will be auto turned into "More ..."
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

    private func askForReview() {
        let popup = PopupDialog(title: L10n.enthusiasticHello,
                                message: L10n.appReviewPromptQuestion,
                                gestureDismissal: false)
        let feedbackPopup = PopupDialog(title: L10n.appReviewApology,
                                        message: L10n.appReviewGiveFeedbackQuestion)
        let feedbackYesButton = DefaultButton(title: L10n.enthusiasticSureSendEmail) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["jeff@softwareengineeringdaily.com"])
                mail.setSubject(L10n.appReviewEmailSubject)

                self.present(mail, animated: true, completion: nil)
            } else {
                let emailUnsupportedPopup = PopupDialog(title: L10n.emailUnsupportedOnDevice, message: L10n.emailUnsupportedMessage)
                let okayButton = DefaultButton(title: L10n.genericOkay) {
                    emailUnsupportedPopup.dismiss()
                }
                emailUnsupportedPopup.addButton(okayButton)
                self.present(emailUnsupportedPopup, animated: true, completion: nil)
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

    func setupLogoutSubscriptionActionSheet() {
        self.actionSheet = UIAlertController(title: "", message: "Whatcha wanna do?", preferredStyle: .actionSheet)
        self.actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem

        switch UserManager.sharedInstance.getActiveUser().hasPremium {
        case true:
            self.actionSheet.addAction(title: "View Subscription", style: .default, isEnabled: true) { _ in
                // Show view subscription status view
                let rootVC = SubscriptionStatusViewController()
                let navVC = UINavigationController(rootViewController: rootVC)
                self.present(navVC, animated: true, completion: nil)
            }
        case false:
//            self.actionSheet.addAction(title: "Purchase Subscription", style: .default, isEnabled: true) { _ in
//                // Show purchase subscription view
//                let rootVC = PurchaseSubscriptionViewController()
//                let navVC = UINavigationController(rootViewController: rootVC)
//                self.present(navVC, animated: true, completion: nil)
//            }
            break
        }

        self.actionSheet.addAction(title: "Logout", style: .destructive, isEnabled: true) { _ in
            self.logoutButtonPressed()
        }
        self.actionSheet.addAction(title: "Cancel", style: .cancel, isEnabled: true) { _ in
            self.actionSheet.dismiss(animated: true, completion: nil)
        }
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
