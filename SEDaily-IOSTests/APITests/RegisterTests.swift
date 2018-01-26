//
//  RegisterTests.swift
//  SEDaily-IOSTests
//
//  Created by Berk Mollamustafaoglu on 20/01/2018.
//

import Foundation
import Quick
import Nimble
import Alamofire
import Mockingjay
@testable import SEDaily_IOS

class RegisterTests: QuickSpec {
    
    override func spec() {
        describe("register tests") {
            it("successfully registers a new user") {
                // Setup
                let path = Bundle(for: type(of: self)).path(forResource: "register_success", ofType: "json")!
                let data = NSData(contentsOfFile: path)!
                self.stub(everything, jsonData(data as Data))
                
                let api = API()
                var responseSuccess: Bool?
                
                api.register(firstName: "", lastName: "", email: "", username: "", password: "") { success in
                    responseSuccess = success
                }
                
                expect(responseSuccess).toEventually(beTrue())
                
            }
            
            it("returns false when user already exists") {
                // Setup
                let path = Bundle(for: type(of: self)).path(forResource: "register_userexists", ofType: "json")!
                let data = NSData(contentsOfFile: path)!
                self.stub(everything, jsonData(data as Data))
                
                let api = API()
                var responseSuccess: Bool?
                
                api.register(firstName: "", lastName: "", email: "", username: "", password: "") { success in
                    responseSuccess = success
                }
                
                expect(responseSuccess).toEventually(beFalse())
                
            }
            
            it("returns false when user already exists") {
                // Setup
                let path = Bundle(for: type(of: self)).path(forResource: "register_emptyusernamepass", ofType: "json")!
                let data = NSData(contentsOfFile: path)!
                self.stub(everything, jsonData(data as Data))
                
                let api = API()
                var responseSuccess: Bool?
                
                api.register(firstName: "", lastName: "", email: "", username: "", password: "") { success in
                    responseSuccess = success
                }
                
                expect(responseSuccess).toEventually(beFalse())
                
            }
            
            it("returns false when the response object is not a dictionary") {
                // Setup
                self.stub(everything, json(["skl"]))
                let api = API()
                var responseSuccess: Bool?
                
                api.register(firstName: "", lastName: "", email: "", username: "", password: "") { success in
                    responseSuccess = success
                }
                expect(responseSuccess).toEventually(beFalse())
            }
        }
        
    }
}

