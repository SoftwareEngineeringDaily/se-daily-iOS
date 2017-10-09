//
//  ObjectExtensions.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 8/3/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension Object {
    @objc func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
    
    func toCompactDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [String:Bool]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index]
                    let key = object.value(forKey: self.objectSchema.primaryKeyProperty!.name)! as! String
                    objects[key] = true
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
}

extension PodcastModel {
    func podcastToDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)

        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            // Remove podcast description because it's too long to send
            if prop.name == "podcastDesc" {
                mutabledic.setValue("", forKey: prop.name)
                continue
            }
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
}
