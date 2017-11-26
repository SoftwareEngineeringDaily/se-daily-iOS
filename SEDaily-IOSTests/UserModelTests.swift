//
//  UserModelTests.swift
//  SEDaily-IOSTests
//
//  Created by Berk Mollamustafaoglu on 26/11/2017.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SEDaily_IOS

class UserModelTests: QuickSpec {
    
    override func spec() {
        describe("userModel tests") {
            var userManager: UserManager!
            var encoder = JSONEncoder()
            var decoder = JSONDecoder()
            
            beforeEach {
                let dict = [String : Any]()
                userManager = UserManager(userDefaults: UserDefaultsMock(dict: dict))
            }
            
            describe("isCurrentUserLoggedIn tests") {
                it("returns false when user is not logged in") {
                    expect(userManager.isCurrentUserLoggedIn()).to(beFalse())
                }
                
                it("returns true when user is logged in") {
                    let user = User(firstName: "firstName",
                                    lastName: "lastName",
                                    email: "email@email.com",
                                    token: "abcdefg")
                    userManager.setCurrentUser(to: user)
                    expect(userManager.isCurrentUserLoggedIn()).to(beTrue())
                }
            }
            
            describe("getActiveUser tests") {
                var user : User!
                beforeEach {
                    user = User(firstName: "firstName",
                                    lastName: "lastName",
                                    email: "email@email.com",
                                    token: "abcdefg")
                    userManager.setCurrentUser(to: user)
                }
                
                it("returns the active user when the saved user matches the current user") {
                    expect(userManager.getActiveUser()).to(equal(user))
                }
                
                it("returns the current user rather than stale value from defaults if they differ") {
                    userManager.defaults.set(User(), forKey: "user")
                    expect(userManager.getActiveUser()).to(equal(user))
                }


            }
        }
        
    }
}
