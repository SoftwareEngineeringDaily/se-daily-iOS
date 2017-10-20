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
    let email: String
    let token: String
    let pushNotificationsSetting: Bool = false
    let deviceToken: String? = nil
    
    init(firstName: String,
         lastName: String,
         email: String,
         token: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.token = token
    }
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.token = ""
    }
    
    // Mark: Getters
    
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
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.key == rhs.key &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.email == rhs.email &&
            lhs.token == rhs.token &&
            lhs.pushNotificationsSetting == rhs.pushNotificationsSetting &&
            lhs.deviceToken == rhs.deviceToken
    }
}

public class UserManager {
    static let sharedInstance: UserManager = UserManager()
    private init() {}
    
    let defaults = UserDefaults.standard
    
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
            break
        case false:
            if let retrievedUser = self.retriveCurrentUserFromDefaults() {
                if self.currentUser == User() && retrievedUser != User() {
                    self.setCurrentUser(to: retrievedUser)
                    return retrievedUser
                }
            }
            self.saveUserToDefaults(user: self.currentUser)
            return self.currentUser
            break
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

//public class UserTEMP: Object, Mappable {
//    @objc dynamic var key = 1
//    @objc dynamic var firstName: String? = nil
//    @objc dynamic var lastName: String? = nil
//    @objc dynamic var email: String? = nil
//    @objc dynamic var token: String? = nil
//    @objc dynamic var pushNotificationsSetting: Bool = false
//    @objc dynamic var deviceToken: String = ""
//
//    override public static func primaryKey() -> String? {
//        return "key"
//    }
//
//    //Impl. of Mappable protocol
//    required convenience public init?(map: Map) {
//        self.init()
//    }
//
//    // Mappable
//    public func mapping(map: Map) {
//        key <- map["id"]
//        firstName <- map["firstName"]
//        lastName <- map["lastName"]
//        email <- map["email"]
//        token <- map["token"]
//    }
//
//
//}
//
//extension User {
//    func save() {
//        let realm = try? Realm()
//        try! realm?.write {
//            realm?.add(self, update: true)
//        }
//    }
//
//    // Probably rename this to something more understandable
//    class func checkAndAlert() -> Bool {
//        let realm = try! Realm()
//        let user = realm.objects(User.self).first
//
//        if user?.token == nil || user?.token == "" {
//            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
//            return false
//        }
//        return true
//    }
//
//    class func getActiveUser() -> User {
//        let realm = try? Realm()
//        guard let user = realm?.objects(User.self).first else {
//            User.createDefault()
//            return (realm?.objects(User.self).first!)!
//        }
//        return user
//    }
//
//    class func all() -> Results<User> {
//        let realm = try! Realm()
//        return realm.objects(User.self)
//    }
//
//    class func logout() {
//        log.error("loggin out")
//        let user = User()
//        user.firstName = ""
//        user.lastName = ""
//        user.email = ""
//        user.token = ""
//        user.save()
//        NotificationCenter.default.post(name: .loginChanged, object: nil)
//    }
//
//    class func createDefault() {
//        log.error("creating default")
//        let user = User()
//        user.email = ""
//        user.token = ""
//        user.save()
//    }
//
//    func delete() {
//        let realm = try! Realm()
//        try! realm.write {
//            realm.delete(self)
//        }
//    }
//
//    func update(deviceToken: String) {
//        let realm = try! Realm()
//        try! realm.write {
//            self.deviceToken = deviceToken
//        }
//    }
//
//    func update(pushNotificationsSetting: Bool) {
//        let realm = try! Realm()
//        try! realm.write {
//            self.pushNotificationsSetting = pushNotificationsSetting
//        }
//    }
//}

