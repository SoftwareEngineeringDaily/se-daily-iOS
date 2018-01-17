//
//  APITests.swift
//  SEDaily-IOSTests
//
//  Created by Berk Mollamustafaoglu on 13/01/2018.
//

import Quick
import Nimble
import Alamofire
import Mockingjay
@testable import SEDaily_IOS

class APITests: QuickSpec {
    
    override func spec() {

        describe("API tests") {
            context("login", {
                it("performs successful login") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "login_success", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))

                    let api = API()

                    var responseSuccess: Bool?
                    api.login(usernameOrEmail: "", password: "", completion: { success in
                        responseSuccess = success
                    })
                    
                    expect(responseSuccess).toEventually(beTrue())
                }

                it("returns false when a wrong password is supplied") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "login_wrongpass", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))

                    let api = API()
                    var responseSuccess: Bool?

                    api.login(usernameOrEmail: "", password: "", completion: { success in
                        responseSuccess = success
                    })
                    
                    expect(responseSuccess).toEventually(beFalse())

                }
                
                it("returns false when a non-existing user tries to log in") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "login_nonexistinguser", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))
                    let api = API()
                    var responseSuccess: Bool?

                    api.login(usernameOrEmail: "", password: "", completion: { success in
                        responseSuccess = success
                    })
                    expect(responseSuccess).toEventually(beFalse())
                }
                
                it("returns false when API returns an error") {
                    // Setup
                    let error = NSError(domain: "MockDomain", code: 401, userInfo: nil)
                    self.stub(everything, failure(error))

                    let api = API()
                    var responseSuccess: Bool?
                    
                    api.login(usernameOrEmail: "", password: "", completion: { success in
                        responseSuccess = success
                    })
                    expect(responseSuccess).toEventually(beFalse())
                }
                
                it("returns false when the response object is not a dictionary") {
                    // Setup
                    self.stub(everything, json(["skl"]))
                    let api = API()
                    var responseSuccess: Bool?
                    
                    api.login(usernameOrEmail: "", password: "", completion: { success in
                        responseSuccess = success
                    })
                    expect(responseSuccess).toEventually(beFalse())
                }
            })

        }
    }
}

