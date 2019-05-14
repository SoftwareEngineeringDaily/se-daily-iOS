//
//  Topic.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/14/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation

public struct Topic: Codable {
	let _id: String
	let name: String
	let slug: String
	let status: String
	let postCount: Int
	
//	init() {
//		self._id = ""
//		self.name = ""
//		self.slug = ""
//		self.status = ""
//		self.postCount = 0
//	}
}
extension Topic: Equatable {
	public static func == (lhs: Topic, rhs: Topic) -> Bool {
		return lhs._id == rhs._id &&
			lhs.name == rhs.name &&
			lhs.slug == rhs.slug &&
			lhs.status == rhs.status &&
			lhs.postCount == rhs.postCount
	}
}
