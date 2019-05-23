//
//  UserModel.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwifterSwift

public struct User: Codable {
	let key: Int = 1
	let firstName: String
	let lastName: String
	let usernameOrEmail: String
	let token: String
	let pushNotificationsSetting: Bool = false
	let deviceToken: String? = nil
	let hasPremium: Bool
	
	let avatarURL: String
	let bio: String
	let website: String
	let fullName: String
	
	
	
	init(firstName: String = "",
			 lastName: String = "",
			 usernameOrEmail: String = "",
			 token: String = "",
			 hasPremium: Bool = false,
			 avatarURL: String = "",
			 bio: String = "",
			 website: String = "",
			 fullName: String = ""
		) {
		self.firstName = firstName
		self.lastName = lastName
		self.usernameOrEmail = usernameOrEmail
		self.token = token
		self.hasPremium = hasPremium
		self.avatarURL = avatarURL
		self.bio = bio
		self.website = website
		self.fullName = fullName
	}
	
	// MARK: Getters
	
	func getFullName() -> String {
		return self.firstName + self.lastName
	}
	
	func isLoggedIn() -> Bool {
		if token != "" {
			return true
		}
		return false
	}
}

extension User: Equatable {
	public static func == (lhs: User, rhs: User) -> Bool {
		return lhs.key == rhs.key &&
			lhs.firstName == rhs.firstName &&
			lhs.lastName == rhs.lastName &&
			lhs.usernameOrEmail == rhs.usernameOrEmail &&
			lhs.token == rhs.token &&
			lhs.pushNotificationsSetting == rhs.pushNotificationsSetting &&
			lhs.deviceToken == rhs.deviceToken &&
			lhs.hasPremium == rhs.hasPremium &&
			lhs.avatarURL == rhs.avatarURL &&
			lhs.bio == rhs.bio &&
			lhs.website == rhs.website &&
			lhs.fullName == rhs.fullName
		
	}
}

public class UserManager {
	static let sharedInstance: UserManager = UserManager()
	
	// Put in this init for tests, but it'd be great to turn this into a non-singleton in general
	init(userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
		defaults = userDefaults
	}
	
	let defaults: UserDefaultsProtocol
	
	let staticUserKey = "user"
	
	var currentUser: User = User() {
		didSet {
			self.saveUserToDefaults(user: self.currentUser)
		}
	}
	
	public func getActiveUser() -> User {
		switch checkIfSavedUserEqualsCurrentUser() {
		case true:
			return self.currentUser
		case false:
			if let retrievedUser = self.retriveCurrentUserFromDefaults() {
				if self.currentUser == User() && retrievedUser != User() {
					self.setCurrentUser(to: retrievedUser)
					return retrievedUser
				}
			}
			self.saveUserToDefaults(user: self.currentUser)
			return self.currentUser
		}
	}
	
	public func setCurrentUser(to newUser: User) {
		guard currentUser != newUser else { return }
		self.currentUser = newUser
	}
	
	public func isCurrentUserLoggedIn() -> Bool {
		let token = self.currentUser.token
		guard token != "" else { return false }
		return true
	}
	
	public func logoutUser() {
		self.setCurrentUser(to: User())
		
		// Clear disk cache
		PodcastDataSource.clean(diskKey: .PodcastFolder)
		NotificationCenter.default.post(name: .loginChanged, object: nil)
	}
	
	private func checkIfSavedUserEqualsCurrentUser() -> Bool {
		guard let retrievedUser = self.retriveCurrentUserFromDefaults() else { return false }
		guard retrievedUser == self.currentUser else { return false }
		return true
	}
	
	private func saveUserToDefaults(user: User) {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(user) {
			defaults.set(encoded, forKey: staticUserKey)
		}
	}
	
	private func retriveCurrentUserFromDefaults() -> User? {
		let decoder = JSONDecoder()
		if let returnedEncodedUser = defaults.data(forKey: staticUserKey),
			let user = try? decoder.decode(User.self, from: returnedEncodedUser) {
			return user
		}
		return nil
	}
}

public protocol UserDefaultsProtocol {
	func set(_ value: Any?, forKey defaultName: String)
	func data(forKey defaultName: String) -> Data?
}

extension UserDefaults: UserDefaultsProtocol {}
