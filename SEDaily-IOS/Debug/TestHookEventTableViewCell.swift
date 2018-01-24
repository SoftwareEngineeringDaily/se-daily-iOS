//
//  TestHookEventTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/15/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import UIKit

class TestHookEventTableViewCell: UITableViewCell, TestHookTableViewCell {
    @IBOutlet private weak var title: UILabel!
    private var testHookEvent: TestHookEvent?

    func configure(testHook: TestHook) {
        self.title.text = testHook.name

        if let testHookEvent = testHook as? TestHookEvent {
            self.testHookEvent = testHookEvent
        }
    }

    @IBAction func buttonTapped(_ sender: Any) {
        self.testHookEvent?.execute?()
    }
}
