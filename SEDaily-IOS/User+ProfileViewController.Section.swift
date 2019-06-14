//
//  User+ProfileViewController.Section.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/5/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
import UIKit

extension User {
	subscript(row: ProfileViewController.Section.SummaryRow) -> Any? {
		switch row {
		case .bio: return bio
		case .name: return name ?? username
		case .username: return username
		case .avatar: return URL(string: avatarUrl ?? "https://sd-profile-pictures.s3.amazonaws.com/5d03934823a39c002ae7dd70")
		case .link: return website
		case .signInPlaceholder: return nil
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


