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
	
	var user: User?
	
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
	}
	@objc func loginObserver() {
		setupDataSource()
		tableView.reloadData()
	}
}
extension ProfileViewController {
	private func setupDataSource() {
		let user = self.user ?? UserManager.sharedInstance.getActiveUser()
		let dataSource = ProfileTableViewDataSource(user: user)
		dataSource.parent = self
		self.dataSource = dataSource
		tableView.dataSource = dataSource
	}
}

extension ProfileViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return dataSource?.section(at: section).headerHeight ?? 0
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = .clear
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		dataSource.map { dataSource in
			let row = dataSource.row(at: indexPath)
			(row as? Section.SummaryRow).map { row in
				switch row {
				case .link: user?.website.map {
					if let linkUrl = URL(string: URLSchemaHelper.addSchema(url: $0)) {
						UIApplication.shared.open(linkUrl, options: [:], completionHandler: nil)
					}
				}
				default: break
				}
			}
			(row as? Section.SettingsRow).map { row in
				switch row {
				case .editProfile:
					let alert = UIAlertController(title: "Please visit the web version", message: "We are working hard to bring this feature to mobile. Please visit softwaredaily.com to edit your profile", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
					self.present(alert, animated: true)
				default: break
				}
			}
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
			case .settings: return 24.0
			case .summary, .layout: return 0.0
			}
		}
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
		case signInPlaceholder
		
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
				marginY: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
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
			case .signInPlaceholder: return SummaryCell.ViewModel.Style(
				marginX: UIView.getValueScaledByScreenWidthFor(baseValue: 15.0),
				marginY: UIView.getValueScaledByScreenWidthFor(baseValue: 50.0),
				font: UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))!,
				color: Stylesheet.Colors.dark,
				alignment: .center)
			}
		}
		
		var cellType: UITableViewCell.Type {
			switch self {
			case .avatar: return AvatarCell.self
			case .name, .username, .bio, .link, .signInPlaceholder: return SummaryCell.self
			}
		}
	}
}
