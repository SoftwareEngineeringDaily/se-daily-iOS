//
//  ProfileTableViewDataSource.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/4/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
import Reusable

import UIKit

class ProfileTableViewDataSource: NSObject {
	private let user: User
	private let organizer: DataOrganizer
	
	weak var parent: ProfileViewController?
	
	
	init(user: User) {
		self.user = user
		organizer = DataOrganizer(user: user)
	}
	
	func section(at index: Int) -> ProfileViewController.Section {
		return organizer.section(at: index)
	}
	
	func row(at indexPath: IndexPath) -> RowType {
		return organizer.row(at: indexPath)
	}
}

// MARK: UITableViewDataSource
extension ProfileTableViewDataSource: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return organizer.sectionsCount
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 2: return "Settings"
		default: return "Dummy"
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return organizer.rowsCount(for: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = organizer.row(at: indexPath)
		guard let cell = tableView.dequeueReusableCell(with: row.cellType, for: indexPath) else {
			return UITableViewCell()
		}
			
		let section = organizer.section(at: indexPath.section)
	
		if let configurableCell = cell as? UserConfigurable {
			configurableCell.configureWith(user: user, row: row)
		}
		if let configurableCell = cell as? Configurable {
			configurableCell.configureWith(row: row, parent: parent!)
		}
		return cell
	}
}



// MARK: - DataOrganizer
extension ProfileTableViewDataSource {
	struct DataOrganizer {
		private let sections: [ProfileViewController.Section]
		
		var sectionsCount: Int {
			return sections.count
		}
		
		init(user: User) {
			var sections: [ProfileViewController.Section] = []
			if user.username.isEmpty {
				sections = [
					.summary([.signInPlaceholder])
				]
			} else {
			sections = [
				.summary([.avatar, .name, .username, .bio, .link].filter { user[$0] != nil }),
				.layout([.separator]),
				.settings([.notifications, .editProfile].filter { $0 != nil && user.isMainUser })
			]
			}

			self.sections = sections.filter({ !$0.rows.isEmpty })
		}
		
		func section(at index: Int) -> ProfileViewController.Section {
			return sections[index]
		}
		
		func rowsCount(for section: Int) -> Int {
			return sections[section].rows.count
		}
		
		func row(at indexPath: IndexPath) -> RowType {
			return sections[indexPath.section].rows[indexPath.row]
		}
	}
}

// MARK: RowConfigurable
protocol UserConfigurable {
	func configureWith(user: User, row: RowType)
}

protocol Configurable {
	func configureWith(row: RowType, parent: ProfileViewController)
}

extension AvatarCell: UserConfigurable {
	func configureWith(user: User, row: RowType) {
		avatarURL = user[.avatar] as? URL ?? nil
	}
}

extension SummaryCell: UserConfigurable {
	func configureWith(user: User, row: RowType) {
		guard let row = row as? ProfileViewController.Section.SummaryRow else {
			assertionFailure("SummaryCell needs a row of type SummaryRow")
			return
		}
		if user.username.isEmpty {
			viewModel = ViewModel(text: "Sign in to view your profile" as? String ?? "", style: row.style)
		} else {
		viewModel = ViewModel(text: user[row] as? String ?? "", style: row.style)
		}
	}
}

extension SwitchCell: Configurable {
	func configureWith(row: RowType, parent: ProfileViewController) {
		guard let row = row as? ProfileViewController.Section.SettingsRow else {
			assertionFailure("SwitchCell needs a row of type SettingsRow")
			return
		}
		// Refactor when more switch cells are available
		switch row {
		case .notifications:
			
			let notificationsController = NotificationsController()
			
			if notificationsController.notificationsSubscribed {
				toggle.setOn(true, animated: true)
			}
			toggle.addTarget(parent, action: #selector(ProfileViewController.switchValueDidChange), for: .touchUpInside)

			viewModel = ViewModel(text: L10n.enableNotifications, callback: { _ in })
		default:
			return
		}
	}
}

extension LabelCell: Configurable {
	func configureWith(row: RowType, parent: ProfileViewController) {
		guard let row = row as? ProfileViewController.Section.SettingsRow else {
			assertionFailure("LabelCell needs a row of type SettingsRow")
			return
		}
		// Refactor when more label cells are available
		switch row {
		case .editProfile:
			viewModel = ViewModel(text: L10n.editProfile, style: row.style)
		default:
			return
		}
	}
}


