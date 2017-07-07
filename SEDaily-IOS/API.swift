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
    }
    
    enum Types {
        static let new = "new"
        static let top = "top"
        static let recommended = "recommended"
    }
    
    enum Params {
        static let email = "email"
        static let password = "password"
        static let bearer = "Bearer"
        static let lastUpdatedBefore = "lastUpdatedBefore"
        static let createdAtBefore = "createdAtBefore"
        static let active = "active"
        static let platform = "platform"
        static let deviceToken = "deviceToken"
        static let accessToken = "accessToken"
        static let type = "type"
    }
}

class API {
    let rootURL: String = "https://software-enginnering-daily-api.herokuapp.com/api";
    
    static let sharedInstance: API = API()
    private init() {}
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
                    
                    let realm = try! Realm()
                    let existingItem = realm.object(ofType: model.self, forPrimaryKey: item.key)
                    
                    if item.key != existingItem?.key {
                        item.type = type
                        item.save()
                    }
                    else {
                        // Nothing needs be done.
                    }
                }
            case .failure(let error):
                log.error(error)
            }
            completion()
        }
    }
    
    func getRecommended() {
        
        let urlString = rootURL + Endpoints.recommendations
        
        var params = [String: String]()
        
        typealias model = PodcastModel
        
        Alamofire.request(urlString, method: .get, parameters: params).responseArray { (response: DataResponse<[model]>) in
            
            switch response.result {
                
            case .success:
                let modelsArray = response.result.value
                
                guard let array = modelsArray else { return }
                
                for item in array {
                    
                    // Check if Achievement Model already exists
                    let realm = try! Realm()
                    let existingItem = realm.object(ofType: model.self, forPrimaryKey: item.key)
                    
                    if item.key != existingItem?.key {
                        item.type = API.Types.recommended
                        item.save()
                    }
                    else {
                        // Nothing needs be done.
                    }
                }
            case .failure(let error):
                log.error(error)
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
