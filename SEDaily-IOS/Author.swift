//
//  Author.swift
//  SEDaily-IOS
//
//  Created by jason on 2/5/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation
// TODO: should merge this with User constuct?

public struct Author: Codable {
	let email: String?
	let username: String?
	let name: String?
	let avatarUrl: String?
	let _id: String?
}


extension Author {
	func displayName() -> String {
		
		if let name = self.name {
			return name
		}
		if let username = self.username {
			return username
		}
		
		return L10n.anonymous
	}
}
