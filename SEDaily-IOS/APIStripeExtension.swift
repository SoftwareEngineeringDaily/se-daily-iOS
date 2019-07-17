//
//  APIStripeExtension.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 1/10/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation
import Alamofire

private enum StripeEndpoints {
    static let subscription = "/subscription"
}

enum StripeParams: String {
    case stripeToken
    case stripeEmail
    case planType
    
    enum Plans: String {
        case monthly
        case yearly
    }
}

extension API {
    func stripeCreateSubscription(token: String, planType: StripeParams.Plans, completion: @escaping (Error?) -> Void) {
        let urlString = rootURL + StripeEndpoints.subscription

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token ?? ""
        
        let _headers: HTTPHeaders = [
            Headers.contentType: Headers.x_www_form_urlencoded,
            Headers.authorization: Headers.bearer + userToken
        ]
        
        var params = [String: String]()
        params[StripeParams.stripeToken.rawValue] = token
        params[StripeParams.planType.rawValue] = planType.rawValue
        
        Alamofire.request(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: _headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // Reload user info
                    self.loadUserInfo()
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func stripeCancelSubscription(completion: @escaping (Error?) -> Void) {
        let urlString = rootURL + StripeEndpoints.subscription
        
        let user = UserManager.sharedInstance.getActiveUser()
				let userToken = user.token ?? ""
        
        let _headers: HTTPHeaders = [
            Headers.contentType: Headers.x_www_form_urlencoded,
            Headers.authorization: Headers.bearer + userToken
        ]
        
        Alamofire.request(urlString, method: .delete, parameters: nil, encoding: URLEncoding.httpBody, headers: _headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    // Reload user info
                    self.loadUserInfo()
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
}
