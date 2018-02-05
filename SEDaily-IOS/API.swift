//
//  API.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import SwiftyBeaver
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
        static let favorites = "/favorites"
        static let favorite = "/favorite"
        static let unfavorite = "/unfavorite"
        static let myBookmarked = "/users/me/bookmarked"
        static let relatedLinks = "/related-links"
        static let comments = "/comments"
        static let createComment = "/comment"
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
        static let email = "email"
        static let username = "username"
        static let password = "password"
        static let token = "token"
        static let tags = "tags"
        static let categories = "categories"
        static let search = "search"
        static let commentContent = "content"
        static let parentCommentId = "parentCommentId"
    }
}

class API {
    private let prodRootURL = "http://localhost:4040/api"
//    private let prodRootURL = "https://software-enginnering-daily-api.herokuapp.com/api"
    private let stagingRootURL = "https://sedaily-backend-staging.herokuapp.com/api"

    private var rootURL: String {
        #if DEBUG
            if let useStagingEndpointTestHook = TestHookManager.testHookBool(id: TestHookId.useStagingEndpoint),
                useStagingEndpointTestHook.value {
                return stagingRootURL
            }
        #endif
        return prodRootURL
    }

}

extension API {
    // MARK: Auth
    func login(usernameOrEmail: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        let urlString = rootURL + Endpoints.login

        let _headers: HTTPHeaders = [Headers.contentType: Headers.x_www_form_urlencoded]
        var params = [String: String]()
        params[Params.username] = usernameOrEmail
        params[Params.password] = password

        networkRequest(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let jsonResponse = response.result.value as? NSDictionary else {
                    completion(false)
                    Tracker.logLoginError(string: "Error: result value is not a NSDictionary")
                    return
                }

                if let message = jsonResponse["message"] {
                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    completion(false)
                    Tracker.logLoginError(string: String(describing: message))
                    return
                }

                if let token = jsonResponse["token"] as? String {
                    let user = User(firstName: "", lastName: "", usernameOrEmail: usernameOrEmail, token: token)
                    UserManager.sharedInstance.setCurrentUser(to: user)

                    // Clear disk cache
                    PodcastDataSource.clean(diskKey: .podcastFolder)
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

    func register(firstName: String, lastName: String, email: String, username: String, password: String, completion: @escaping (_ success: Bool?) -> Void) {
        let urlString = rootURL + Endpoints.register
        
        let _headers: HTTPHeaders = [Headers.contentType: Headers.x_www_form_urlencoded]
        var params = [String: String]()
        params[Params.username] = username
        params[Params.email] = email
        params[Params.password] = password
        
        networkRequest(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let jsonResponse = response.result.value as? NSDictionary else {
                    Tracker.logRegisterError(string: "Error: result value is not a NSDictionary")
                    completion(false)
                    return
                }

                if let message = jsonResponse["message"] {
                    log.error(message)

                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    Tracker.logRegisterError(string: String(describing: message))
                    completion(false)
                    return
                }

                if let token = jsonResponse["token"] as? String {
                    let user = User(firstName: firstName, lastName: lastName, usernameOrEmail: username, token: token)
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

typealias PodcastModel = Podcast

// MARK: Search
extension API {
    func getPostsWith(searchTerm: String,
                      createdAtBefore beforeDate: String = "",
                      onSuccess: @escaping ([Podcast]) -> Void,
                      onFailure: @escaping (APIError?) -> Void) {
        let urlString = self.rootURL + Endpoints.posts

        var params = [String: String]()
        params[Params.search] = searchTerm
        params[Params.createdAtBefore] = beforeDate

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [
            Headers.authorization: Headers.bearer + userToken
            ]

        networkRequest(urlString, method: .get, parameters: params, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    // Handle error here
                    log.error("response has no data")
                    onFailure(.NoResponseDataError)
                    return
                }

                var data: [PodcastModel] = []
                let this = JSON(responseData)
                for (_, subJson):(String, JSON) in this {
                    guard let jsonData = try? subJson.rawData() else { continue }
                    let newObject = try? JSONDecoder().decode(PodcastModel.self, from: jsonData)
                    if let newObject = newObject {
                        data.append(newObject)
                    }
                }
                onSuccess(data)
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
    func getPost(podcastId: String, completion: @escaping (_ success: Bool, _ result: Podcast?) -> Void) {
        let urlString = self.rootURL + Endpoints.posts + "/" + podcastId

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [
            Headers.authorization: Headers.bearer + userToken,
            Headers.contentType: Headers.x_www_form_urlencoded
        ]

        Alamofire.request(urlString, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    log.error("response has no data")
                    completion(false, nil)
                    return
                }

                let jsonData = JSON(responseData)
                guard let data = try? jsonData.rawData() else {
                    log.error("response has no data")
                    completion(false, nil)
                    return
                }
                let podcast = try? JSONDecoder().decode(PodcastModel.self, from: data)
                completion(true, podcast)
            case .failure(let error):
                log.error(error)
                Tracker.logGeneralError(error: error)
                Helpers.alertWithMessage(title: Helpers.Alerts.error, message: error.localizedDescription, completionHandler: nil)
                completion(false, nil)
            }
        }
    }

    func getPosts(type: String = "",
                  createdAtBefore beforeDate: String = "",
                  tags: String = "-1",
                  categories: String = "",
                  onSuccess: @escaping ([Podcast]) -> Void,
                  onFailure: @escaping (APIError?) -> Void) {
        var type = type

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [
            Headers.authorization: Headers.bearer + userToken
            ]

        if userToken.isEmpty && type == PodcastTypes.recommended.rawValue {
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
        if !tags.isEmpty {
            params[Params.tags] = tags
        }

        if !categories.isEmpty {
            params[Params.categories] = categories
        }
       
        networkRequest(urlString, method: .get, parameters: params, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    // Handle error here
                    log.error("response has no data")
                    onFailure(.NoResponseDataError)
                    return
                }

                var data: [PodcastModel] = []
                let this = JSON(responseData)
                for (_, subJson):(String, JSON) in this {
                    guard let jsonData = try? subJson.rawData() else { continue }
                    let newObject = try? JSONDecoder().decode(PodcastModel.self, from: jsonData)
                    if var newObject = newObject {
                        newObject.type = type
                        data.append(newObject)
                    }
                }
                onSuccess(data)
            case .failure(let error):
                log.error(error.localizedDescription)
                Tracker.logGeneralError(error: error)
                onFailure(.GeneralFailure)
            }
        }
    }
}

typealias RelatedLinkModel = RelatedLink

// MARK: Related Links
extension API {
    func getRelatedLinks(podcastId: String, onSuccess: @escaping ([RelatedLink]) -> Void,
                         onFailure: @escaping (APIError?) -> Void) {
        print(rootURL)
        let urlString = self.rootURL + Endpoints.posts + "/" + podcastId + Endpoints.relatedLinks
        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [
            Headers.authorization: Headers.bearer + userToken,
            Headers.contentType: Headers.x_www_form_urlencoded
        ]
        
        networkRequest(urlString, method: .get, parameters: nil, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    // Handle error here
                    log.error("response has no data")
                    onFailure(.NoResponseDataError)
                    return
                }
                
                do {
                    let data: [RelatedLinkModel] = try JSONDecoder().decode([RelatedLinkModel].self, from: responseData)
                    onSuccess(data)
                } catch let jsonErr {
                    onFailure(.NoResponseDataError)
                    print(jsonErr)
                }
                
            case .failure(let error):
                log.error(error.localizedDescription)
                Tracker.logGeneralError(error: error)
                onFailure(.GeneralFailure)
            }
        }
    }
}

typealias  CommentModel = Comment
// MARK: Comments
extension API {
    // get Comments
    func getComments(podcastId: String, onSuccess: @escaping ([Comment]) -> Void,
                     onFailure: @escaping (APIError?) -> Void) {
        let urlString = self.rootURL + Endpoints.posts + "/" + podcastId + Endpoints.comments
        
        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [Headers.contentType: Headers.x_www_form_urlencoded,
                                     Headers.authorization: Headers.bearer + userToken
        ]
        
        print(urlString)
        networkRequest(urlString, method: .get, parameters: nil, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    // Handle error here
                    log.error("response has no data")
                    onFailure(.NoResponseDataError)
                    return
                }
                
                do {
          
                    let data: CommentsResponse = try JSONDecoder().decode(CommentsResponse.self, from: responseData)
                    print(data)
                    onSuccess(data.result)
                } catch let jsonErr {
                    onFailure(.NoResponseDataError)
                    print(jsonErr)
                }
                
            case .failure(let error):
                log.error(error.localizedDescription)
                Tracker.logGeneralError(error: error)
                onFailure(.GeneralFailure)
            }
        }
    }
    // create Reply
    
    // create Comment
    func createComment(podcastId: String, parentComment: Comment?, commentContent: String, onSuccess: @escaping () -> Void,
                       onFailure: @escaping (APIError?) -> Void) {
       
        let urlString = self.rootURL + Endpoints.posts + "/" + podcastId + Endpoints.createComment
        
        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [Headers.contentType: Headers.x_www_form_urlencoded,
                                     Headers.authorization: Headers.bearer + userToken
                                     ]
        var params = [String: String]()
        params[Params.commentContent] = commentContent
        // This is included if we are replying to a comment
        if let parentComment = parentComment {
            params[Params.parentCommentId] = parentComment._id
        }
        
        networkRequest(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: _headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
            
            print(response)
            switch response.result {
            case .success:
                print("success commenting")
            case .failure(let error):
                log.error(error)
    
                print("failed")
                
            }
        }
    }
}

// MARK: Bookmarks
extension API {
    /// Network call to get bookmarks for the current user
    ///
    /// - Parameter completion: Callback when the network call completes.
    func podcastBookmarks(completion: @escaping (_ success: Bool, _ results: [PodcastModel]?) -> Void) {
        let urlString = self.rootURL + Endpoints.myBookmarked

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let headers = [
            Headers.authorization: Headers.bearer + userToken,
            Headers.contentType: Headers.x_www_form_urlencoded
        ]

        Alamofire.request(
            urlString,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.httpBody,
            headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    log.error("response has no data")
                    completion(false, nil)
                    return
                }

                let jsonData = JSON(responseData)

                var podcastModels = [PodcastModel]()
                jsonData.forEach({ (_, itemJsonData) in
                    if let rawData = try? itemJsonData.rawData(),
                        let podcast = try? JSONDecoder().decode(PodcastModel.self, from: rawData) {
                        podcastModels.push(podcast)
                    }
                })

                completion(true, podcastModels)
            case .failure(let error):
                log.error(error)
                Tracker.logGeneralError(error: error)
                Helpers.alertWithMessage(
                    title: Helpers.Alerts.error,
                    message: error.localizedDescription,
                    completionHandler: nil)
                completion(false, nil)
            }
        }
    }

    /// Network call to bookmark or unbookmark a pod cast.
    ///
    /// - Parameters:
    ///   - value: True to bookmark the pod cast, false to unbookmark the pod cast
    ///   - podcastId: The id of the pod cast
    ///   - completion: Callback when network call completes
    func setBookmarkPodcast(
        value: Bool,
        podcastId: String,
        completion: @escaping (_ success: Bool?, _ active: Bool?) -> Void) {
        let urlString = self.rootURL + Endpoints.posts + "/" + podcastId +
            (value ? Endpoints.favorite : Endpoints.unfavorite)

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let headers = [
            Headers.authorization: Headers.bearer + userToken,
            Headers.contentType: Headers.x_www_form_urlencoded
        ]

        Alamofire.request(
            urlString,
            method: .post,
            parameters: nil,
            encoding: URLEncoding.httpBody,
            headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let jsonResponse = response.result.value as? NSDictionary else {
                    Tracker.logGeneralError(string: "Error result value is not a NSDictionary")
                    completion(false, nil)
                    return
                }

                if let message = jsonResponse["message"] {
                    Helpers.alertWithMessage(
                        title: Helpers.Alerts.error,
                        message: String(describing: message),
                        completionHandler: nil)
                    completion(false, nil)
                    return
                }

                if let active = jsonResponse["active"] as? Bool {
                    completion(true, active)
                }
            case .failure(let error):
                log.error(error)
                Tracker.logGeneralError(error: error)
                Helpers.alertWithMessage(
                    title: Helpers.Alerts.error,
                    message: error.localizedDescription,
                    completionHandler: nil)
                completion(false, nil)
            }
        }
    }
}

// MARK: Voting
extension API {
    func upvotePodcast(podcastId: String, completion: @escaping (_ success: Bool?, _ active: Bool?) -> Void) {
        let urlString = self.rootURL + Endpoints.posts + "/" + podcastId + Endpoints.upvote

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [
            Headers.authorization: Headers.bearer + userToken,
            Headers.contentType: Headers.x_www_form_urlencoded
        ]

        networkRequest(urlString, method: .post, parameters: nil, encoding: URLEncoding.httpBody, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let jsonResponse = response.result.value as? NSDictionary else {
                    Tracker.logGeneralError(string: "Error result value is not a NSDictionary")
                    completion(false, nil)
                    return
                }

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
        let urlString = self.rootURL + Endpoints.posts + "/" + podcastId + Endpoints.downvote

        let user = UserManager.sharedInstance.getActiveUser()
        let userToken = user.token
        let _headers: HTTPHeaders = [
            Headers.authorization: Headers.bearer + userToken,
            Headers.contentType: Headers.x_www_form_urlencoded
        ]

        networkRequest(urlString, method: .post, parameters: nil, encoding: URLEncoding.httpBody, headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                guard let jsonResponse = response.result.value as? NSDictionary else {
                    completion(false, nil)
                    Tracker.logGeneralError(string: "Error: result value is not a NSDictionary")
                    return
                }

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

extension API: NetworkService {
    func networkRequest(_ urlString: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders?) -> DataRequest {
        return Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
}

