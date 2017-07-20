//
//  API.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import RealmSwift
import SwiftyJSON

extension API {
    enum Headers {
        static let contentType = "Content-Type"
        static let x_www_form_urlencoded = "application/x-www-form-urlencoded"
    }
    
    enum Endpoints {
        static let posts = "/posts"
        static let recommendations = "/posts/recommendations"
        static let login = "/auth/login"
        static let register = "/auth/register"
    }
    
    enum Types {
        static let new = "new"
        static let top = "top"
        static let recommended = "recommended"
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
    }
}

class API {
    let rootURL: String = "https://software-enginnering-daily-api.herokuapp.com/api";
    
    static let sharedInstance: API = API()
    private init() {}
}

extension API {
    // MARK: Auth
    func login(username: String, password: String, completion: @escaping (_ success: Bool?) -> Void) {
        let urlString = rootURL + Endpoints.login
        
        let _headers : HTTPHeaders = [Headers.contentType:Headers.x_www_form_urlencoded]
        var params = [String: String]()
        params[Params.username] = username
        params[Params.password] = password
        
        typealias model = PodcastModel
        
        Alamofire.request(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary
                
                if let message = jsonResponse["message"] {
                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    completion(false)
                    return
                }
                
                if let token = jsonResponse["token"] {
                    let user = User()
                    user.email = username
                    user.token = token as? String
                    user.save()
                    completion(true)
                }
            case .failure(let error):
                log.error(error)

                Helpers.alertWithMessage(title: Helpers.Alerts.error, message: error.localizedDescription, completionHandler: nil)
                completion(false)
            }
        }
    }
    
    func register(username: String, password: String, completion: @escaping (_ success: Bool?) -> Void) {
        let urlString = rootURL + Endpoints.register
        
        let _headers : HTTPHeaders = [Headers.contentType:Headers.x_www_form_urlencoded]
        var params = [String: String]()
        params[Params.username] = username
        params[Params.password] = password
        
        typealias model = PodcastModel
        
        Alamofire.request(urlString, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers: _headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonResponse = response.result.value as! NSDictionary
                
                if let message = jsonResponse["message"] {
                    log.error(message)
                    
                    Helpers.alertWithMessage(title: Helpers.Alerts.error, message: String(describing: message), completionHandler: nil)
                    completion(false)
                    return
                }
                
                if let token = jsonResponse["token"] {
                    let user = User()
                    user.email = username
                    user.token = token as? String
                    user.save()
                    completion(true)
                }
            case .failure(let error):
                log.error(error)
                
                Helpers.alertWithMessage(title: Helpers.Alerts.error, message: error.localizedDescription, completionHandler: nil)
                completion(false)
            }
        }
    }

}

extension API {
    //MARK: Getters
    func getPosts(type: String, createdAtBefore beforeDate: String = "", completion: @escaping () -> Void) {
        
        let urlString = rootURL + Endpoints.posts
        
        var params = [String: String]()
        params[Params.createdAtBefore] = beforeDate
        
        typealias model = PodcastModel
        
        Alamofire.request(urlString, method: .get, parameters: params).responseArray { (response: DataResponse<[model]>) in
            
            switch response.result {
            
            case .success:
                let modelsArray = response.result.value
                guard let array = modelsArray else { return }
                
                for item in array {
                    
//                    let realm = try! Realm()
//                    let existingItem = realm.object(ofType: model.self, forPrimaryKey: item.key)
                    
//                    if item.key != existingItem?.key {
                        item.type = type
                        item.save()
//                    }
//                    else {
                        // Nothing needs be done.
//                    }
                }
            case .failure(let error):
                log.error(error)
            }
            completion()
        }
    }
    
    func getRecommended() {
        
        let urlString = rootURL + Endpoints.recommendations
        
        let user = User.getActiveUser()
        guard let userToken = user.token else { return }
        var params = [String: String]()
        params[Params.bearer] = userToken
        
        typealias model = PodcastModel

        Alamofire.request(urlString, method: .get, parameters: params).responseArray { (response: DataResponse<[model]>) in
            
            switch response.result {
                
            case .success:
                let modelsArray = response.result.value
                guard let array = modelsArray else { return }
                log.info(array)
                for item in array {
                    
                    // Check if Achievement Model already exists
//                    let realm = try! Realm()
//                    let existingItem = realm.object(ofType: model.self, forPrimaryKey: item.key)
//                    
//                    if item.key != existingItem?.key {
                        item.type = API.Types.recommended
                        item.save()
//                    }
//                    else {
                        // Nothing needs be done.
//                    }
                }
            case .failure(let error):
                log.error(error)
                break
            }
        }
    }
}

extension API {
    func createDefaultData() {
        User.createDefault()
    }
    
//    func loadAllObjects() {
//        self.getEvents()
//        self.getPets()
//        self.getShelters()
//    }
//    
//    func loadLoggedInData() {
//        self.getFavorites()
//        self.getFollowingShelters()
//    }
//    
//    func reloadAllObjects() {
//        let realm = try! Realm()
//        try! realm.write {
//            realm.delete(EventModel.all())
//            realm.delete(PetModel.all())
//            realm.delete(ShelterModel.all())
//            realm.delete(UpdatesModel.all())
//        }
//        self.getEvents()
//        self.getPets()
//        self.getShelters()
//    }
}
