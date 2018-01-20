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
            
            context("register tests") {
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
            
            context("posts calls") {
                it("returns a list of posts with a successful call") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "getPostsWith_success", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))
                    
                    let api = API()
                    var successCalled: Bool? = nil, failureCalled: Bool? = nil
                    
                    api.getPostsWith(searchTerm: "blockchain", createdAtBefore: "", onSuccess: { podcasts in
                        expect(podcasts).toNot(beNil())
                        expect(podcasts).toNot(beEmpty())
                        successCalled = true
                    }, onFailure: { _ in
                        failureCalled = true
                    })
                    expect(failureCalled).toEventually(beNil())
                    expect(successCalled).toEventually(beTrue())
                }
                
                it("failure callback called on API call failure") {
                    // Setup
                    let error = NSError(domain: "", code: 401, userInfo: nil)
                    self.stub(everything, failure(error))

                    let api = API()
                    var successCalled: Bool? = nil, failureCalled: Bool? = nil

                    api.getPostsWith(searchTerm: "", createdAtBefore: "", onSuccess: { podcasts in
                        successCalled = true
                    }, onFailure: { _ in
                        failureCalled = true
                    })
                    expect(failureCalled).toEventually(beTrue())
                    expect(successCalled).toEventually(beNil())

                }
            }
            
            context("upvote tests") {
                it("returns success for a successful upvote") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "upvote_success", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))
                    
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.upvotePodcast(podcastId: "5a63b51866503d002a70f809") { (success, active) in
                        responseSuccess = success
                        responseActive = active
                    }
                    
                    expect(responseSuccess).toEventually(beTrue())
                    expect(responseActive).toEventually(beTrue())
                }
                
                it("returns false when the podcast doesn't exist") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "upvote_failure", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))
                    
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.upvotePodcast(podcastId: "") { (success, active) in
                        responseSuccess = success
                        responseActive = active
                    }
                    
                    expect(responseSuccess).toEventually(beFalse())
                    expect(responseActive).toEventually(beNil())
                }
                
                it("returns false when the call fails") {
                    // Setup
                    let error = NSError(domain: "", code: 401, userInfo: nil)
                    self.stub(everything, failure(error))
                    
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.upvotePodcast(podcastId: "") { (success, active) in
                        responseSuccess = success
                        responseActive = active
                    }
                    
                    expect(responseSuccess).toEventually(beFalse())
                    expect(responseActive).toEventually(beNil())
                }
                
                it("returns false when the upvote response object is not a dictionary") {
                    // Setup
                    self.stub(everything, json(["skl"]))
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.upvotePodcast(podcastId: "5a63b51866503d002a70f809") { (success, active) in
                        responseSuccess = success
                        responseActive = active

                    }
                    expect(responseSuccess).toEventually(beFalse())
                    expect(responseActive).toEventually(beNil())
                }
            }
            
            context("downvote tests") {
                it("returns success for a successful downvote") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "upvote_success", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))
                    
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.downvotePodcast(podcastId: "5a63b51866503d002a70f809") { (success, active) in
                        responseSuccess = success
                        responseActive = active
                    }
                    
                    expect(responseSuccess).toEventually(beTrue())
                    expect(responseActive).toEventually(beTrue())
                }
                
                it("returns false when the podcast doesn't exist") {
                    // Setup
                    let path = Bundle(for: type(of: self)).path(forResource: "upvote_failure", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(everything, jsonData(data as Data))
                    
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.downvotePodcast(podcastId: "") { (success, active) in
                        responseSuccess = success
                        responseActive = active
                    }
                    
                    expect(responseSuccess).toEventually(beFalse())
                    expect(responseActive).toEventually(beNil())
                }
                
                it("returns false when the call fails") {
                    // Setup
                    let error = NSError(domain: "", code: 401, userInfo: nil)
                    self.stub(everything, failure(error))
                    
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.downvotePodcast(podcastId: "") { (success, active) in
                        responseSuccess = success
                        responseActive = active
                    }
                    
                    expect(responseSuccess).toEventually(beFalse())
                    expect(responseActive).toEventually(beNil())
                }
                
                it("returns false when the downvote response object is not a dictionary") {
                    // Setup
                    self.stub(everything, json(["skl"]))
                    let api = API()
                    var responseSuccess: Bool?
                    var responseActive: Bool?
                    
                    api.downvotePodcast(podcastId: "5a63b51866503d002a70f809") { (success, active) in
                        responseSuccess = success
                        responseActive = active
                        
                    }
                    expect(responseSuccess).toEventually(beFalse())
                    expect(responseActive).toEventually(beNil())
                }
            }
        }
    }
}

