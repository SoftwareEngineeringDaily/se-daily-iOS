//
//  VotingTests.swift
//  SEDaily-IOSTests
//
//  Created by Berk Mollamustafaoglu on 20/01/2018.
//

import Quick
import Nimble
import Alamofire
import Mockingjay
@testable import SEDaily_IOS

class VotingTests: QuickSpec {
    
    override func spec() {
        describe("upvote tests") {
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
        
        describe("downvote tests") {
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

