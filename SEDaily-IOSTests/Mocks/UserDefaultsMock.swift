//
//  UserDefaultsMock.swift
//  SEDaily-IOSTests
//
//  Created by Berk Mollamustafaoglu on 26/11/2017.
//
//

import Foundation
@testable import SEDaily_IOS

class UserDefaultsMock: UserDefaultsProtocol {
    
    var dict: [String: Any]
    
    init(dict: [String: Any]) {
        self.dict = dict
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        if let validValue = value {
            dict[defaultName] = validValue
        }
    }
    
    func data(forKey defaultName: String) -> Data? {
        let dataObj = dict[defaultName] as? Data
        return dataObj
    }
    
}


