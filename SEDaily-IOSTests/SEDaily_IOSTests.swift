//
//  SEDaily_IOSTests.swift
//  SEDaily-IOSTests
//
//  Created by Craig Holliday on 6/25/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import XCTest
import Alamofire
@testable import SEDaily_IOS

class SEDaily_IOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let datasource = PodcastRealmDataSource()
        let content = Podcast.Content.init(rendered: "Test")
        let title = Podcast.Title.init(rendered: "Test 2")
        let podacast1 = Podcast(_id: "1", date: "", link: "", categories: [], tags: [], mp3: "", featuredImage: "", content: content, title: title, score: 0)
        datasource.insert(item: podacast1)
        
        print(datasource.getAll())
//        datasource.clean()
        print(datasource.getAll())
        
        let viewModelController = PodcastViewModelController()
        viewModelController.fetchData(onSucces: {
            if let model = viewModelController.viewModel(at: 0){
                print(model)
            }
        }) { (error) in
            print(error?.localizedDescription)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
