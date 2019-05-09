//
//  ProfileViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/7/19.
//  Copyright © 2019 Koala Tea. All rights reserved.

//

// TODO: REFACTOR

import UIKit
import UserNotifications

class ProfileViewController: UIViewController {
	
	var tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .grouped)
	
	let notificationsController = NotificationsController()
	
	init() {
		super.init(nibName: nil, bundle: nil)
		self.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "person_outline"), selectedImage: UIImage(named: "person"))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(tableView)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50.0
		tableView.tableFooterView = UIView()
		tableView.allowsSelection = true
		tableView.separatorColor = .clear
		tableView.backgroundColor = .white
		tableView.register(cellType: ProfileCell.self)
		tableView.register(cellType: NotificationTableViewCell.self)
		tableView.register(cellType: SettingsCell.self)
		NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
		if UserManager.sharedInstance.getActiveUser().fullName == "" {
		API().loadUserInfo()
		}
	}
	@objc func loginObserver() {
		tableView.reloadData()
	}
}
extension ProfileViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			if UserManager.sharedInstance.isCurrentUserLoggedIn() {
			let cell: ProfileCell = tableView.dequeueReusableCell(for: indexPath)
			cell.nameLabel.text = UserManager.sharedInstance.getActiveUser().fullName
			cell.usernameOrEmailLabel.text = UserManager.sharedInstance.getActiveUser().usernameOrEmail
			cell.bioLabel.text = UserManager.sharedInstance.getActiveUser().bio
			cell.linkLabel.text = UserManager.sharedInstance.getActiveUser().website
			cell.setupAvatar(imageURL: URL(string: UserManager.sharedInstance.getActiveUser().avatarURL))
			cell.selectionStyle = .none
			return cell
			} else {
				let cell: SettingsCell = tableView.dequeueReusableCell(for: indexPath)
				cell.cellLabel.text = "Sign In to see your profile here"
				cell.cellLabel.font = UIFont(name: "OpenSans-SemiBold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
				cell.cellLabel.textColor = Stylesheet.Colors.base
				cell.selectionStyle = .none
				return cell
			}
			
		default:
			switch indexPath.row {
			case 0:
				let cell: NotificationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
				cell.cellLabel.text = "Enable Daily Notifications"
				cell.selectionStyle = .none
				if notificationsController.notificationsSubscribed {
					cell.cellToggle.setOn(true, animated: true)
				}
				cell.cellToggle.addTarget(self, action: #selector(switchValueDidChange), for: .touchUpInside)
				return cell
			default:
				let cell: SettingsCell = tableView.dequeueReusableCell(for: indexPath)
				cell.cellLabel.text = "Edit Profile"
				cell.selectionStyle = .none
				return cell
			}
			
		}
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		default:
			return 2
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section==1 {
			return "Settings"
		}
		return ""
	}
}




extension ProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 && indexPath.row == 1 {
			let alert = UIAlertController(title: "Please visit the web version", message: "We are working hard to bring this feature to mobile. Please visit softwaredaily.com to edit your profile", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true)
		}
	}
}


extension ProfileViewController {
	@objc func switchValueDidChange(sender: UISwitch!) {
		if sender.isOn {
			notificationsController.assignNotifications()
			notificationsController.notificationsSubscribed = true
		} else {
			// cancel
			UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
			notificationsController.notificationsSubscribed = false
		}
		
		let defaults = UserDefaults.standard
		defaults.set(notificationsController.notificationsSubscribed, forKey: notificationsController.notificationPrefKey)
	}
	
	func assignNotifications () {
		notificationsController.center.getNotificationSettings { [weak self] (settings) in
			if settings.authorizationStatus != .authorized {
				// Notifications not allowed
				self?.notificationsController.requestNotifications()
			} else {
				self?.notificationsController.createNotification()
			}
		}
	}
	

}
