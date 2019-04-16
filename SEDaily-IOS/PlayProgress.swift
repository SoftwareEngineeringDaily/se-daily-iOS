//
//  PlayProgress.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/11/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation

struct PlayProgress: Codable {
	let id: String
	var currentTime: Float
	var totalLength: Float
	
	init(id: String, currentTime: Float, totalLength: Float) {
		self.id = id
		self.currentTime = currentTime
		self.totalLength = totalLength
	}
}
