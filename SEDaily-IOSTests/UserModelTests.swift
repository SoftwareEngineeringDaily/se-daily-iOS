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
            var user: User!
            var encoder = JSONEncoder()
            var decoder = JSONDecoder()
            
            beforeEach {
                let dict = [String:Any]()
                userManager = UserManager(userDefaults: UserDefaultsMock(dict: dict))
                
                user = User(firstName: "firstName",
                                lastName: "lastName",
                                email: "email@email.com",
                                token: "abcdefg")
                userManager.setCurrentUser(to: user)
            }

            describe("isCurrentUserLoggedIn tests") {
                it("returns false when user is not logged in") {
                    userManager.setCurrentUser(to: User())
                    expect(userManager.isCurrentUserLoggedIn()).to(beFalse())
                }
                it("returns true when user is logged in") {
                    expect(userManager.isCurrentUserLoggedIn()).to(beTrue())
                }
            }
            
            describe("getActiveUser tests") {
                it("returns the active user when the saved user matches the current user") {
                    expect(userManager.getActiveUser()).to(equal(user))
                }
                
                it("returns the current user rather than stale value from defaults if they differ") {
                    userManager.defaults.set(User(), forKey: "user")
                    expect(userManager.getActiveUser()).to(equal(user))
                }
            }
            
            describe("logout user") {

                it("sets current user to empty") {
                    userManager.logoutUser()
                    expect(userManager.currentUser).to(equal(User()))
                }
            }
            
            describe("setCurrentUser tests") {

                it("changes user if the value passed in is a different user") {
                    let newUser = User(firstName: "firstName",
                                       lastName: "lastName",
                                       email: "email@email.com",
                                       token: "abcdefg")
                    
                    userManager.setCurrentUser(to: newUser)
                    expect(userManager.currentUser).to(equal(newUser))
                }
                
                it("doesn't change user if the same user is passed in") {
                    let localUser = User(firstName: "firstName",
                                         lastName: "lastName",
                                         email: "email@email.com",
                                         token: "abcdefg")
                    
                    userManager.setCurrentUser(to: localUser)
                    let sameUser = User(firstName: "firstName",
                                        lastName: "lastName",
                                        email: "email@email.com",
                                        token: "abcdefg")
                    
                    userManager.setCurrentUser(to: sameUser)
                    expect(userManager.currentUser).to(equal(localUser))
                }
            }
        }
    }
}
