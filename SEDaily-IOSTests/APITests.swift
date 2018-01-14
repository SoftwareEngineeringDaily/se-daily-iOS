//
//  APITests.swift
//  SEDaily-IOSTests
//
//  Created by Berk Mollamustafaoglu on 13/01/2018.
//

import Quick
import Nimble
import Alamofire
@testable import SEDaily_IOS

class APITests: QuickSpec {
    
    override func spec() {
        describe("API tests") {
            it("performs login logic") {
                let bla = MockNetworkService()
                bla.networkRequest("", method: .get, parameters: nil, headers: nil, responseCallback: {_ in print("hello")})
                
            }
        }
    }
    
}

class MockNetworkService: NetworkService {
    func networkRequest(_ urlString: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders?, responseCallback: @escaping (DataResponse<Any>) -> Void) {
        print("Hello")
    }
}
