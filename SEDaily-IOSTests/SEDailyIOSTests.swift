//
//  SEDaily_IOSTests.swift
//  SEDaily-IOSTests
//
//  Created by Craig Holliday on 6/25/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import XCTest
@testable import SEDaily_IOS

class SEDailyIOSTests: XCTestCase {
    
    var downloadManager: OfflineDownloadsManager!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.downloadManager = OfflineDownloadsManager()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.downloadManager = nil
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let promise = expectation(description: "Status code: 200")

        let podcast = Podcast(_id: "", date: "", link: "", categories: [], tags: [], mp3: "http://traffic.libsyn.com/sedaily/IncidentResponse.mp3", featuredImage: "", content: Podcast.Content.init(rendered: ""), title: Podcast.Title.init(rendered: ""), score: 0, type: nil, upvoted: nil, downvoted: nil, bookmarked: nil)
        downloadManager.save(podcast: podcast, onProgress: { (fractionCompleted) in
            print(fractionCompleted)
        }, onSucces: {
            promise.fulfill()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 400, handler: nil)
    }

}
