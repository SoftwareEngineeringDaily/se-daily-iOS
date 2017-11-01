//
//  FilterObject.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/21/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

struct FilterObject: Codable {
    let type: String
    let tags: [Int]
    var tagsAsString: String {
        get {
            let stringArray = tags.map { String($0) }
            return stringArray.joined(separator: " ")
        }
    }
    let lastDate: String
    let categories: [Int]
    var categoriesAsString: String {
        get {
            let stringArray = categories.map { String($0) }
            return stringArray.joined(separator: " ")
        }
    }
    
    init(type: String = "",
         tags: [Int] = [],
         lastDate: String = "",
         categories: [Int] = []) {
        self.type = type
        self.tags = tags
        self.lastDate = lastDate
        self.categories = categories
    }
}
