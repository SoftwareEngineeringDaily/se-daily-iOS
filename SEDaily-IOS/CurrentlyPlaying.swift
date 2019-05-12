//
//  CurrentlyPlaying.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/6/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation
// This is a workaround to keep global playing state
class CurrentlyPlaying {
	static let shared = CurrentlyPlaying()
	private var currentlyPlayingId: String = ""
	func setCurrentlyPlaying(id: String) {
		currentlyPlayingId = id
	}
	func getCurrentlyPlayingId()-> String {
		return currentlyPlayingId
	}
}
