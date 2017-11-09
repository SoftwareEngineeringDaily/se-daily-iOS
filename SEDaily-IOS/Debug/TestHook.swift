//
//  TestHook.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 10/7/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

class TestHook {
    let name: String
    let id: TestHookId

    var reuseId: String {
        return ""
    }
    var order = 0

    init(id: TestHookId, name: String) {
        self.id = id
        self.name = name
    }
}
