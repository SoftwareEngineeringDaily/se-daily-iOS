//
//  API.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Fabric
import Crashlytics

extension API {
    enum Headers {
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
        static let x_www_form_urlencoded = "application/x-www-form-urlencoded"
        static let bearer = "Bearer "
    }
    
    enum Endpoints {
        static let posts = "/posts"
        static let recommendations = "/posts/recommendations"
        static let login = "/auth/login"
        static let register = "/auth/register"
        static let upvote = "/upvote"
        static let downvote = "/downvote"
    }
    
    enum Types {
        static let new = "new"
        static let top = "top"
        static let recommended = "recommended"
    }
    
    enum TagIds {
        static let business = "1200"
    }
    
    enum Params {
        static let bearer = "Bearer"
        static let lastUpdatedBefore = "lastUpdatedBefore"
        static let createdAtBefore = "createdAtBefore"
        static let active = "active"
        static let platform = "platform"
        static let deviceToken = "deviceToken"
        static let accessToken = "accessToken"
        static let type = "type"
        static let username = "username"
        static let password = "password"
        static let token = "token"
        static let tags = "tags"
        static let categories = "categories"
        static let search = "search"
    }
}

class API {
    let rootURL: String = "https://software-enginnering-daily-api.herokuapp.com/api";
    
    static let sharedInstance: API = API()
    private init() {}
}

extension API {
    // MARK: Auth
    func login(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ success: Bool?) -> Void) {
        let urlString = rootURL + Endpoints.login
        
        let _headers : HTTPHeaders = [Headers.contentType:Headers.x_www_form_urlencoded]
        var params = [String: String]()
        params[Params.username] = email
        params[Params.password] = password
        
        Alamofire.request(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary
                
                if let message = jsonResponse["message"] {
                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    completion(false)
                    Tracker.logLoginError(string: String(describing: message))
                    return
                }
                
                if let token = jsonResponse["token"] as? String {
                    let user = User(firstName: firstName, lastName: lastName, email: email, token: token)
                    UserManager.sharedInstance.setCurrentUser(to: user)
                    
                    NotificationCenter.default.post(name: .loginChanged, object: nil)
                    completion(true)
                }
            case .failure(let error):
                log.error(error)

                Helpers.alertWithMessage(title: Helpers.Alerts.error, message: error.localizedDescription, completionHandler: nil)
                Tracker.logLoginError(error: error)
                completion(false)
            }
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, completion: @escaping (_ success: Bool?) -> Void) {
        let urlString = rootURL + Endpoints.register
        
        let _headers : HTTPHeaders = [Headers.contentType:Headers.x_www_form_urlencoded]
        var params = [String: String]()
        params[Params.username] = email
        params[Params.password] = password
        
        Alamofire.request(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary
                
                if let message = jsonResponse["message"] {
                    log.error(message)
                    
                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    Tracker.logRegisterError(string: String(describing: message))
                    completion(false)
                    return
                }
                
                if let token = jsonResponse["token"] as? String {
                    let user = User(firstName: firstName, lastName: lastName, email: email, token: token)
                    UserManager.sharedInstance.setCurrentUser(to: user)
                    
                    NotificationCenter.default.post(name: .loginChanged, object: nil)
                    completion(true)
                }
            case .failure(let error):
                log.error(error)
                
                Helpers.alertWithMessage(title: Helpers.Alerts.error, message: error.localizedDescription, completionHandler: nil)
                Tracker.logRegisterError(error: error)
                completion(false)
            }
        }
    }

}

typealias podcastModel = Podcast
// MARK: Search
extension API {
    func getPostsWith(searchTerm: String,
                      createdAtBefore beforeDate: String = "",
                      onSucces: @escaping ([Podcast]) -> Void,
                      onFailure: @escaping (APIError?) -> Void) {
        let urlString = rootURL + Endpoints.posts
        
        var params = [String: String]()
        params[Params.search] = searchTerm
        params[Params.createdAtBefore] = beforeDate
        
        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers : HTTPHeaders = [
            Headers.authorization:Headers.bearer + userToken,
            ]
        
        Alamofire.request(urlString, method: .get, parameters: params, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    // Handle error here
                    print("response has no data")
                    onFailure(.NoResponseDataError)
                    return
                }
                
                var data: [podcastModel] = []
                let this = JSON(responseData)
                for (_, subJson):(String, JSON) in this {
                    guard let jsonData = try? subJson.rawData() else { continue }
                    let newObject = try? JSONDecoder().decode(podcastModel.self, from: jsonData)
                    if let newObject = newObject {
                        data.append(newObject)
                    }
                }
                onSucces(data)
            case .failure(let error):
                log.error(error.localizedDescription)
                Tracker.logGeneralError(error: error)
                onFailure(.GeneralFailure)
            }
        }
    }
}

// MARK: - MVVM Getters
extension API {
    func getPosts(type: String = "",
                  createdAtBefore beforeDate: String = "",
                  tags: String = "-1",
                  categories: String = "",
                  onSucces: @escaping ([Podcast]) -> Void,
                  onFailure: @escaping (APIError?) -> Void) {
        var type = type
        
        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers : HTTPHeaders = [
            Headers.authorization:Headers.bearer + userToken,
            ]

        if userToken == "" && type == PodcastTypes.recommended.rawValue {
            type = PodcastTypes.top.rawValue
        }
        
        var urlString = self.rootURL + API.Endpoints.posts
        if type == PodcastTypes.recommended.rawValue {
            urlString = self.rootURL + Endpoints.recommendations
        }
        
        // Params
        var params = [String: String]()
        params[Params.type] = type
        if beforeDate != "" && type != PodcastTypes.recommended.rawValue {
            params[Params.createdAtBefore] = beforeDate
        }
        
        // @TODO: Allow for an array and join the array
        if (tags != "") {
            params[Params.tags] = tags
        }
        
        if (categories != "") {
            params[Params.categories] = categories
        }

        Alamofire.request(urlString, method: .get, parameters: params, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    // Handle error here
                    print("response has no data")
                    onFailure(.NoResponseDataError)
                    return
                }
                
                var data: [podcastModel] = []
                let this = JSON(responseData)
                for (_, subJson):(String, JSON) in this {
                    guard let jsonData = try? subJson.rawData() else { continue }
                    let newObject = try? JSONDecoder().decode(podcastModel.self, from: jsonData)
                    if var newObject = newObject {
                        newObject.type = type
                        data.append(newObject)
                    }
                }
                onSucces(data)
            case .failure(let error):
                log.error(error.localizedDescription)
                Tracker.logGeneralError(error: error)
                onFailure(.GeneralFailure)
            }
        }
    }
}

// MARK: Voting
extension API {
    func upvotePodcast(podcastId: String, completion: @escaping (_ success: Bool?, _ active: Bool?) -> Void) {
        let urlString = rootURL + Endpoints.posts + "/" + podcastId + Endpoints.upvote
        
        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers : HTTPHeaders = [
            Headers.authorization:Headers.bearer + userToken,
            Headers.contentType:Headers.x_www_form_urlencoded
        ]
        
        Alamofire.request(urlString, method: .post, parameters: nil, encoding: URLEncoding.httpBody , headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary

                if let message = jsonResponse["message"] {
                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    completion(false, nil)
                    return
                }
                
                if let active = jsonResponse["active"] as? Bool {
                    completion(true, active)
                }
            case .failure(let error):
                log.error(error)
                Tracker.logGeneralError(error: error)
                Helpers.alertWithMessage(title: Helpers.Alerts.error, message: error.localizedDescription, completionHandler: nil)
                completion(false, nil)
            }
        }
    }
    
    func downvotePodcast(podcastId: String, completion: @escaping (_ success: Bool?, _ active: Bool?) -> Void) {
        let urlString = rootURL + Endpoints.posts + "/" + podcastId + Endpoints.downvote
        
        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers : HTTPHeaders = [
            Headers.authorization:Headers.bearer + userToken,
            Headers.contentType:Headers.x_www_form_urlencoded
        ]
        
        Alamofire.request(urlString, method: .post, parameters: nil, encoding: URLEncoding.httpBody , headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary

                if let message = jsonResponse["message"] {
                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    completion(false, nil)
                    return
                }
                if let active = jsonResponse["active"] as? Bool {
                    completion(true, active)
                }
            case .failure(let error):
                log.error(error)
                Tracker.logGeneralError(error: error)
                Helpers.alertWithMessage(title: Helpers.Alerts.error, message: error.localizedDescription, completionHandler: nil)
                completion(false, nil)
            }
        }
    }
}
