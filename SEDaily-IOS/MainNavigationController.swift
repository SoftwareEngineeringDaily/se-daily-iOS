//
//  MainNavigationController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/27/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavBar()
		setupTitleView()
		
		// Do any additional setup after loading the view.
	}
	
	func setupTitleView() {
		
		let height = UIView.getValueScaledByScreenHeightFor(baseValue: 40)
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
		imageView.contentMode = .scaleAspectFit
		imageView.image = #imageLiteral(resourceName: "Logo_BarButton")
		self.navigationItem.titleView = imageView
		
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
		let layout = UICollectionViewLayout()
		//		var searchCollectionViewController = SearchCollectionViewController(collectionViewLayout: layout, audioOverlayDelegate: self.audioOverlayDelegate)
		//		self.navigationController?.pushViewController(searchCollectionViewController)
		Analytics2.searchNavButtonPressed()
	}
	
	@objc func leftBarButtonPressed() {
		//		self.setupLogoutSubscriptionActionSheet()
		//		self.actionSheet.show()
	}
	
	@objc func loginButtonPressed() {
		Analytics2.loginNavButtonPressed()
		let vc = LoginViewController()
		self.navigationController?.pushViewController(vc)
	}
	
	@objc func logoutButtonPressed() {
		Analytics2.logoutNavButtonPressed()
		UserManager.sharedInstance.logoutUser()
		//self.setupNavBar()
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
