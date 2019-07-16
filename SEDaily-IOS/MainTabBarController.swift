//
//  MainTabBarController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/26/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit
import MessageUI
import PopupDialog
import SnapKit
import StoreKit
import SwifterSwift
import SwiftIcons
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate, MainCoordinated {
  
  var mainCoordinator: MainFlowCoordinator?
	
	let layout = UICollectionViewLayout()
	
	let latestVC = PodcastPageViewController()
	let bookmarksVC =  BookmarkCollectionViewController(collectionViewLayout: UICollectionViewLayout())
	let downloadsVC = DownloadsCollectionViewController(collectionViewLayout: UICollectionViewLayout())
	let profileVC = ProfileViewController()
	
	var ifset = false
	
	var actionSheet = UIAlertController()
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
    NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
		self.view.backgroundColor = .white
		
		setupNavigationControllers(viewControllers: [latestVC, downloadsVC, bookmarksVC, profileVC])
		setupTabs()
		[latestVC, downloadsVC, bookmarksVC, profileVC].forEach(setupTitleView(viewController:))
		self.tabBar.tintColor = Stylesheet.Colors.base
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AskForReview.tryToExecute { didExecute in
			if didExecute {
				self.askForReview()
			}
		}
	}
  
  @objc func loginObserver() {
    setupNavigationControllers(viewControllers: [latestVC, downloadsVC, bookmarksVC, profileVC])
  }
	
	func setupNavBar(viewController: UIViewController) {
		let rightBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.rightBarButtonPressed))
		viewController.navigationItem.rightBarButtonItem = rightBarButton
		
		switch UserManager.sharedInstance.getActiveUser().isLoggedIn() {
		case false:
			let leftBarButton = UIBarButtonItem(title: L10n.loginTitle, style: .done, target: self, action: #selector(self.loginButtonPressed))
			viewController.navigationItem.leftBarButtonItem = leftBarButton
		case true:
			let leftBarButton = UIBarButtonItem(title: L10n.logoutTitle, style: .plain, target: self, action: #selector(self.leftBarButtonPressed))
			
			// Hacky way to show bars icon
			let iconSize: CGFloat = 16.0
			let image = UIImage(bgIcon: .fontAwesome(.bars), bgTextColor: .clear, bgBackgroundColor: .clear, topIcon: .fontAwesome(.bars), topTextColor: .white, bgLarge: false, size: CGSize(width: iconSize, height: iconSize))
			leftBarButton.image = image
			leftBarButton.imageInsets = UIEdgeInsets(top: 0, left: -(iconSize / 2), bottom: 0, right: 0)
			
			viewController.navigationItem.leftBarButtonItem = leftBarButton
		}
	}
	
	@objc func rightBarButtonPressed() {
		let layout = UICollectionViewLayout()
    let searchCollectionViewController = SearchCollectionViewController(collectionViewLayout: layout)
    guard let navigationController = self.selectedViewController as? UINavigationController else { return }
    mainCoordinator?.viewController(navigationController, push: searchCollectionViewController)
		Analytics2.searchNavButtonPressed()
	}
	
	@objc func leftBarButtonPressed() {
		self.setupLogoutSubscriptionActionSheet()
		self.actionSheet.show()
	}
	
	@objc func loginButtonPressed() {
		Analytics2.loginNavButtonPressed()
		let vc = LoginViewController()
		guard let navigationController = self.selectedViewController as? UINavigationController else { return }
    navigationController.pushViewController(vc, animated: true)
	}
	
	@objc func logoutButtonPressed() {
		Analytics2.logoutNavButtonPressed()
		UserManager.sharedInstance.logoutUser()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func setupNavigationControllers(viewControllers: [UIViewController]) {
		for viewController in viewControllers {
			setupNavBar(viewController: viewController)
		}
	}
  
	
	func setupTabs() {
		
		let layout = UICollectionViewLayout()
		
		let latestVC1 = UINavigationController(rootViewController: latestVC)
		let bookmarksVC1 =  UINavigationController(rootViewController: bookmarksVC)
		let downloadsVC1 = UINavigationController(rootViewController: downloadsVC)
		let profileVC1 = UINavigationController(rootViewController: profileVC)
		
		self.viewControllers = [
			latestVC1,
			bookmarksVC1,
			downloadsVC1,
			profileVC1
		]
		
		//        #if DEBUG
		//            // This will cause the tab bar to overflow so it will be auto turned into "More ..."
		//            let debugStoryboard = UIStoryboard.init(name: "Debug", bundle: nil)
		//            let debugViewController = debugStoryboard.instantiateViewController(
		//                withIdentifier: "DebugTabViewController")
		//            if let viewControllers = self.viewControllers {
		//                self.viewControllers =  viewControllers + [debugViewController]
		//            }
		//        #endif
		
		self.tabBar.backgroundColor = .white
		self.tabBar.isTranslucent = false
	}
	
  func setupTitleView(viewController: UIViewController) {
		let height = UIView.getValueScaledByScreenHeightFor(baseValue: 40)
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
		imageView.contentMode = .scaleAspectFit
		imageView.image = #imageLiteral(resourceName: "Logo_BarButton")
		viewController.navigationItem.titleView = imageView
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
		default: break
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
