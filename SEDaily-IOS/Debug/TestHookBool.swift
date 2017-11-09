//
//  TestHookBool.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/15/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

class TestHookBool: TestHook {
    override var reuseId: String {
        return "TestHookBoolCellId"
    }

    private var _defaultValue = false

    var value: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.id.rawValue)
        }

        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: self.id.rawValue)
        }
    }

    var defaultValue: Bool {
        get {
            return self._defaultValue
        }
        set(newDefaultValue) {
            self._defaultValue = newDefaultValue
            if UserDefaults.standard.object(forKey: self.id.rawValue) == nil {
                UserDefaults.standard.set(newDefaultValue, forKey: self.id.rawValue)
            }
        }
    }
}
