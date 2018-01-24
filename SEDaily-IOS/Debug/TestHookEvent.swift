//
//  TestHookEvent.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/15/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

class TestHookEvent: TestHook {
    override var reuseId: String {
        return "TestHookEventCellId"
    }
    var execute: (() -> Void)?
}
