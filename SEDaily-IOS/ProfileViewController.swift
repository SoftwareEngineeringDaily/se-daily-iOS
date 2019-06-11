//
//  ProfileViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/7/19.
//  Copyright © 2019 Altalogy All rights reserved.

//

// TODO: REFACTOR

import UIKit
import UserNotifications

class ProfileViewController: UIViewController {
	
	private var dataSource: ProfileTableViewDataSource?
	
	var tableView: UITableView = UITableView.init(frame: CGRect.zero, style: .grouped)
	
	var user: User = User()
	
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
		setupDataSource()
		tableView.delegate = self
		

		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50.0
		tableView.tableFooterView = UIView()
		tableView.allowsSelection = true
		tableView.separatorColor = .clear
		tableView.backgroundColor = .white
		tableView.register(cellType: ProfileCell.self)
		tableView.register(cellType: NotificationTableViewCell.self)
		tableView.register(cellType: SettingsCell.self)
		tableView.register(cellType: SummaryCell.self)
		tableView.register(cellType: AvatarCell.self)
		tableView.register(cellType: SeparatorCell.self)
		tableView.register(cellType: SwitchCell.self)
		tableView.register(cellType: LabelCell.self)
		NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
		if UserManager.sharedInstance.getActiveUser().name == "" {
		API().loadUserInfo()
		}
	}
	@objc func loginObserver() {
		setupDataSource()
		tableView.reloadData()
	}
}
extension ProfileViewController {
	private func setupDataSource() {
		//let user = UserManager.sharedInstance.getActiveUser()
		let dataSource = ProfileTableViewDataSource(user: user)
		self.dataSource = dataSource
		tableView.dataSource = dataSource
	}
}
//extension ProfileViewController: UITableViewDataSource {
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		switch indexPath.section {
//		case 0:
//			if UserManager.sharedInstance.isCurrentUserLoggedIn() {
//			let cell: ProfileCell = tableView.dequeueReusableCell(for: indexPath)
//			cell.nameLabel.text = UserManager.sharedInstance.getActiveUser().fullName
//			cell.usernameOrEmailLabel.text = UserManager.sharedInstance.getActiveUser().usernameOrEmail
//			cell.bioLabel.text = UserManager.sharedInstance.getActiveUser().bio
//			cell.linkLabel.text = UserManager.sharedInstance.getActiveUser().website
//			cell.setupAvatar(imageURL: URL(string: UserManager.sharedInstance.getActiveUser().avatarURL))
//			cell.selectionStyle = .none
//			return cell
//			} else {
//				let cell: SettingsCell = tableView.dequeueReusableCell(for: indexPath)
//				cell.cellLabel.text = "Sign In to see your profile here"
//				cell.cellLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
//				cell.cellLabel.textColor = Stylesheet.Colors.dark
//				cell.selectionStyle = .none
//				return cell
//			}
//
//		default:
//			switch indexPath.row {
//			case 0:
//				let cell: NotificationTableViewCell = tableView.dequeueReusableCell(for: indexPath)
//				cell.cellLabel.text = "Enable Daily Notifications"
//				cell.selectionStyle = .none
//				if notificationsController.notificationsSubscribed {
//					cell.cellToggle.setOn(true, animated: true)
//				}
//				cell.cellToggle.addTarget(self, action: #selector(switchValueDidChange), for: .touchUpInside)
//				return cell
//			default:
//				let cell: SettingsCell = tableView.dequeueReusableCell(for: indexPath)
//				cell.cellLabel.text = "Edit Profile"
//				cell.selectionStyle = .none
//				return cell
//			}
//
//		}
//	}
//
//
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		switch section {
//		case 0:
//			return 1
//		default:
//			return 2
//		}
//	}
//
//	func numberOfSections(in tableView: UITableView) -> Int {
//		return 2
//	}

//	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		if section==1 {
//			return "Settings"
//		}
//		return ""
//	}
//}




extension ProfileViewController: UITableViewDelegate {
	
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return dataSource?.section(at: section).headerHeight ?? 0
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = .clear
		print(view.height)
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


extension ProfileViewController {
	enum Section {
		case summary([SummaryRow])
		case layout([LayoutRow])
		case settings([SettingsRow])
		//case actions([ActionRow])
		
		var rows: [RowType] {
			switch self {
			case let .summary(rows): return rows
			case let .layout(rows): return rows
			case let .settings(rows): return rows
			//case let .actions(rows): return rows
			}
		}
		
		var headerHeight: CGFloat {
			switch self {
			case .summary, .settings: return 24.0
			case .layout: return 0.0
			}
		}
		
//		var separator: UITableViewCell.SeparatorType {
//			switch self {
//			case .lists: return .insetted(24.0)
//			case .summary, .details: return .none
//			}
//		}
	}
}

protocol RowType {
	var cellType: UITableViewCell.Type { get }
}

extension ProfileViewController.Section {
	enum LayoutRow: RowType {
		case separator
		
		var cellType: UITableViewCell.Type {
			switch self {
			case .separator: return SeparatorCell.self
			}
		}
	}
	
	enum SettingsRow: RowType {
		case notifications
		case editProfile
		
		var cellType: UITableViewCell.Type {
			switch self {
				case .notifications: return SwitchCell.self
				case .editProfile: return LabelCell.self
			}
		}
		
		var style: LabelCell.ViewModel.Style {
			switch self {
			case .editProfile: return LabelCell.ViewModel.Style(
				marginX: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
				marginY: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
				font: UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))!,
				color: Stylesheet.Colors.dark,
				alignment: .left,
				accessory: .disclosureIndicator)
			case .notifications:
				return LabelCell.ViewModel.Style()
			}
		}
	}
	
	enum SummaryRow: RowType {
		case avatar
		case name
		case username
		case bio
		case link
		
		var style: SummaryCell.ViewModel.Style {
			switch self {
			case .name: return SummaryCell.ViewModel.Style(
				marginX: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
				marginY: UIView.getValueScaledByScreenWidthFor(baseValue: 5.0),
				font: UIFont(name: "Roboto-Bold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 30))!,
				color: Stylesheet.Colors.dark,
				alignment: .center)
			case .username: return SummaryCell.ViewModel.Style(
				marginX: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
				marginY: UIView.getValueScaledByScreenWidthFor(baseValue: 5.0),
				font: UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 11))!,
				color: Stylesheet.Colors.grey,
				alignment: .center)
			case .link: return SummaryCell.ViewModel.Style(
				marginX: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
				marginY: UIView.getValueScaledByScreenWidthFor(baseValue: 5.0),
				font: UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))!,
				color: Stylesheet.Colors.base,
				alignment: .left)
			case .bio: return SummaryCell.ViewModel.Style(
				marginX: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
				marginY: UIView.getValueScaledByScreenWidthFor(baseValue: 5.0),
				font: UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))!,
				color: Stylesheet.Colors.dark,
				alignment: .left)
			case .avatar:
				//assertionFailure("There is no style for the avata row")
				return SummaryCell.ViewModel.Style()
			}
		}
		
		var cellType: UITableViewCell.Type {
			switch self {
			case .avatar: return AvatarCell.self
			case .name, .username, .bio, .link: return SummaryCell.self
			}
		}
	}
}
//	enum DetailRow: RowType {
//		case email
//		case blog
//		case company
//		case location
//
//		var icon: UIImage {
//			switch self {
//			case .email: return #imageLiteral(resourceName: "Email")
//			case .blog: return #imageLiteral(resourceName: "Blog")
//			case .company: return #imageLiteral(resourceName: "Company")
//			case .location: return #imageLiteral(resourceName: "Location")
//			}
//		}
//
//		var isActive: Bool {
//			switch self {
//			case .email, .blog: return true
//			case .company, .location: return false
//			}
//		}
//
//		var cellType: UITableViewCell.Type {
//			return DetailCell.self
//		}
//	}
	
//	enum ListRow: RowType {
//		case repositories
//		case stars
//		case followers
//		case following
//
//		var name: String {
//			switch self {
//			case .repositories: return "Repositories"
//			case .stars: return "Stars"
//			case .followers: return "Followers"
//			case .following: return "Following"
//			}
//		}
//
//		var cellType: UITableViewCell.Type {
//			return ListCell.self
//		}
//	}
//}
