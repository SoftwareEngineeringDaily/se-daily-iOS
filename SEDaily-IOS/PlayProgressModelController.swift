//
//  PlayProgressModelController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/12/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import Foundation

typealias PlayProgressDict = [String: PlayProgress]

class PlayProgressModelController {
	
	var episodesPlayProgress: PlayProgressDict = PlayProgressDict()
	
	func save() {
		var progressToSave: [String: Data] = [String: Data]()
		for (key, playProgress) in self.episodesPlayProgress {
			guard let playProgressData = encodePlayProgress(from: playProgress) else { return }
			progressToSave[key] = playProgressData
		}
		saveToDefaults(progressToSave: progressToSave)
	}
	
	func retrieve() {
		guard let fetched = fetchFromDefaults() else { return }
		var result: PlayProgressDict = PlayProgressDict()
		for (key, playProgressData) in fetched {
			guard let playProgress = decodePlayProgress(from: playProgressData) else { return }
			result[key] = playProgress
		}
		episodesPlayProgress = result
	}
	
}

private extension PlayProgressModelController {
	
	private func saveToDefaults(progressToSave: [String: Data]) {
		let defaults = UserDefaults.standard
		defaults.set(progressToSave, forKey: "sedaily-playProgress")
	}
	
	private func fetchFromDefaults()-> [String: Data]? {
		let defaults = UserDefaults.standard
		guard let fetchedData = defaults.object(forKey: "sedaily-playProgress") as? [String: Data] else { return nil}
		return fetchedData
	}
	
	private func decodePlayProgress(from data: Data)-> PlayProgress? {
		guard let fetchedPlayProgress = try? PropertyListDecoder().decode(PlayProgress.self, from: data)
			else { return nil }
		return fetchedPlayProgress
	}
	
	private func encodePlayProgress(from playProgress: PlayProgress)-> Data? {
		guard let progressData = try? PropertyListEncoder().encode(playProgress) else { return nil }
		return progressData
	}
}

