//
//  TestHookManager.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/15/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation

enum TestHookId: String {
    case useStagingEndpoint
    case viewDisk
    case getPodcastBookmarks
    case clearAlreadyLoadedToday
}

class TestHookManager {
    private(set) static var testHooksMap = [TestHookId: TestHook]()
    private(set) static var testHooksArray = [TestHook]()
    private static var order = 0

    private init() {
    }

    static func add(testHook: TestHook) {
        testHook.order = order
        order += 1
        TestHookManager.testHooksMap[testHook.id] = testHook

        TestHookManager.testHooksArray = Array(TestHookManager.testHooksMap.values)
        TestHookManager.testHooksArray.sort { $0.order < $1.order }
    }

    static func testHookBool(id: TestHookId) -> TestHookBool? {
        return TestHookManager.testHooksMap[id] as? TestHookBool
    }

    static func testHookEvent(id: TestHookId) -> TestHookEvent? {
        return TestHookManager.testHooksMap[id] as? TestHookEvent
    }
}
