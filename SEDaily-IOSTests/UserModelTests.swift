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
        describe("isCurrentUserLoggedIn tests") {
            var userManager: UserManager!

            beforeEach {
                let dict = [String : Any]()
                userManager = UserManager(userDefaults: UserDefaultsMock(dict: dict))
            }
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
    }
    
    
}
