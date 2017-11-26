//
//  HelpersTests.swift
//  SEDaily-IOSTests
//
//  Created by Berk Mollamustafaoglu on 25/11/2017.
//
//

import XCTest
import Quick
import Nimble
@testable import SEDaily_IOS

class HelpersTests: QuickSpec {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    override func spec() {
        describe("isValidEmailAddress") {
            it("accepts regular email address format") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "test@example.com")).to(beTrue())
            }
            
            it("accepts dots and underscores") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "test.exampl_e@example.com")).to(beTrue())
            }

            it("accepts letters and numbers") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "test.exampl_e981@example.com")).to(beTrue())
            }
            
            it("accepts emails with multiple dots") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "bla@university.ac.uk")).to(beTrue())
            }
            
            it("doesn't accept empty string before the @ sign") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "@example.com")).to(beFalse())
            }

            it("doesn't accept characters other than dots and underscores in the main part of the address") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "test.exam&pl_e981@example.com")).to(beFalse())
            }
            
            it("doesn't accept single characters after the final dot") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "test@example.c")).to(beFalse())
            }
            
            it("doesn't accept numbers after the final dot") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "test@example.coa3f")).to(beFalse())
            }
            
            it("doesn't accept symbols after the final dot") {
                expect(Helpers.isValidEmailAddress(emailAddressString: "test@example.co/f")).to(beFalse())
            }

        }
        
        describe("getStringFrom tests") {
            it("displays the value if the value is above 10") {
                expect(Helpers.getStringFrom(seconds: 15)).to(equal("15"))
            }
            
            it("displays the value with a leading zero if it's below 10") {
                expect(Helpers.getStringFrom(seconds: 9)).to(equal("09"))
            }
        }
      
    }
    
}
