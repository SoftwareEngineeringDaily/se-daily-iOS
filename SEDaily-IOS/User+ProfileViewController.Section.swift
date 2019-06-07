//
//  User+ProfileViewController.Section.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/5/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
import UIKit

struct UserMock {
	var name: String = "Dawid Cedrych"
	var bio: String = "Still writing his bio..."
	var username: String = "TheDC"
	var avatar: URL = URL(string: "https://sd-profile-pictures.s3.amazonaws.com/5b43197c31ed27002a6b0f5e")!
	var link: String? = "www.startups.com"
}

extension UserMock {
	subscript(row: ProfileViewController.Section.SummaryRow) -> Any? {
		switch row {
		case .bio: return bio
		case .name: return name
		case .username: return username
		case .avatar: return avatar
		case .link: return link
		}
	}
}

extension UITableView {
	func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell? {
		return dequeueReusableCell(withIdentifier: String(describing: Cell.self), for: indexPath) as? Cell
	}
	
	func dequeueReusableCell<Cell: UITableViewCell>(with type: Cell.Type, for indexPath: IndexPath) -> Cell? {
		return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as? Cell
	}
}


//import UIKit
//
//extension UITableView {
//	func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
//		return dequeueReusableCell(withIdentifier: String(describing: Cell.self), for: indexPath) as! Cell
//	}
//	
//	func dequeueReusableCell<Cell: UITableViewCell>(with type: Cell.Type, for indexPath: IndexPath) -> Cell {
//		return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as! Cell
//	}
//}
	
//	subscript(row: ProfileViewController.Section.DetailRow) -> String {
//		let details = self.details.fetchedValue
//		let text: String? = {
//			switch row {
//			case .email: return details?.email
//			case .company: return details?.company
//			case .location: return details?.location
//			case .blog: return details?.blog?.absoluteString
//			}
//		}()
//		return text ?? ""
//	}
//
//	subscript(row: ProfileViewController.Section.ListRow) -> Int {
//		let details = self.details.fetchedValue
//		let count: Int? = {
//			switch row {
//			case .repositories: return details?.publicRepositoriesCount
//			case .stars: return stars.fetchedValue?.count
//			case .followers: return details?.followersCount
//			case .following: return details?.followingCount
//			}
//		}()
//		return count ?? 0
//	}
//
//	func users(for listRow: ProfileViewController.Section.ListRow) -> FetchableValue<[User]> {
//		switch listRow {
//		case .followers: return followers
//		case .following: return following
//		default:
//			assertionFailure("Requesting users for a repositories rows")
//			return FetchableValue(url: URL(string: "")!, value: .fetched(value: []))
//		}
//	}
//
//	func repositories(for listRow: ProfileViewController.Section.ListRow) -> FetchableValue<[Repository]> {
//		switch listRow {
//		case .repositories: return repositories
//		case .stars: return stars
//		default:
//			assertionFailure("Requesting repositories for a user rows")
//			return FetchableValue(url: URL(string: "")!, value: .fetched(value: []))
//		}
//	}
//}

