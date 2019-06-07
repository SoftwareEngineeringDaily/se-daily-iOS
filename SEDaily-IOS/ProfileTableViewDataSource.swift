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
	private let user: UserMock
	private let organizer: DataOrganizer
	
	init(user: UserMock) {
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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return organizer.rowsCount(for: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = organizer.row(at: indexPath)
//		guard let cell: Reusable = tableView.dequeueReusableCell(for: indexPath) as? Reusable else {
//			// doesn't match
//			return
//		}
		guard let cell = tableView.dequeueReusableCell(with: row.cellType, for: indexPath) else {
			return UITableViewCell()
		}
			
		let section = organizer.section(at: indexPath.section)
		//cell.separator = section.separator
		if let configurableCell = cell as? UserConfigurable {
			configurableCell.configureWith(user: user, row: row)
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
		
		init(user: UserMock) {
			let sections: [ProfileViewController.Section] = [
				.summary([.avatar, .name, .username, .link, .bio].filter { user[$0] != nil }),
				.layout([.separator])
			]
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
	func configureWith(user: UserMock, row: RowType)
}

extension AvatarCell: UserConfigurable {
	func configureWith(user: UserMock, row: RowType) {
		avatarURL = user[.avatar] as? URL ?? nil
	}
}

extension SummaryCell: UserConfigurable {
	func configureWith(user: UserMock, row: RowType) {
		guard let row = row as? ProfileViewController.Section.SummaryRow else {
			assertionFailure("SummaryCell needs a row of type SummaryRow")
			return
		}
		viewModel = ViewModel(text: user[row] as? String ?? "", style: row.style)
	}
}

//extension DetailCell: UserConfigurable {
//	func configureWith(user: User, row: RowType) {
//		guard let row = row as? ProfileViewController.Section.DetailRow else {
//			assertionFailure("DetailCell needs a row of type DetailRow")
//			return
//		}
//		viewModel = ViewModel(icon: row.icon, text: user[row], active: row.isActive)
//	}
//}
//
//extension ListCell: UserConfigurable {
//	func configureWith(user: User, row: RowType) {
//		guard let row = row as? ProfileViewController.Section.ListRow else {
//			assertionFailure("ListCell needs a row of type ListRow")
//			return
//		}
//		viewModel = ViewModel(count: user[row], name: row.name)
//	}
//}
