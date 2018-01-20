//
//  PostsTests.swift
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

class PostsTests: QuickSpec {
    
    override func spec() {
        describe("posts calls") {
            it("getPostsWith returns a list of posts with a successful call") {
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
            
            it("getPostsWith failure callback called on API call failure") {
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
            
            it("getPosts returns the top podcasts successfully") {
                // Setup
                let path = Bundle(for: type(of: self)).path(forResource: "getPosts_topPosts", ofType: "json")!
                let data = NSData(contentsOfFile: path)!
                self.stub(everything, jsonData(data as Data))
                
                let api = API()
                var successCalled: Bool? = nil, failureCalled: Bool? = nil
                
                api.getPosts(type: "top", createdAtBefore: "", tags: "", categories: "", onSuccess: { (podcasts) in
                    expect(podcasts).toNot(beNil())
                    expect(podcasts).toNot(beEmpty())
                    successCalled = true
                }, onFailure: { _ in
                    failureCalled = true
                })
                expect(failureCalled).toEventually(beNil())
                expect(successCalled).toEventually(beTrue())
            }
            
            it("getPosts failure callback called on API call failure") {
                // Setup
                let error = NSError(domain: "", code: 401, userInfo: nil)
                self.stub(everything, failure(error))
                
                let api = API()
                var successCalled: Bool? = nil, failureCalled: Bool? = nil
                
                api.getPosts(type: "top", createdAtBefore: "", tags: "", categories: "", onSuccess: { (podcasts) in
                    successCalled = true
                }, onFailure: { _ in
                    failureCalled = true
                })
                expect(failureCalled).toEventually(beTrue())
                expect(successCalled).toEventually(beNil())
                
            }
        }
    }
}

