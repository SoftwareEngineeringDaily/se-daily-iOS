//
//  TestHookBoolTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 12/15/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import UIKit

class TestHookBoolTableViewCell: UITableViewCell, TestHookTableViewCell {
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var boolSwitch: UISwitch!

    private weak var testHookBool: TestHookBool?

    @IBAction func valueChanged(_ sender: Any) {
        self.testHookBool?.value = self.boolSwitch.isOn
    }

    func configure(testHook: TestHook) {
        self.title.text = testHook.name

        if let testHookBool = testHook as? TestHookBool {
            self.testHookBool = testHookBool
            self.boolSwitch.isOn = testHookBool.value
        }
    }
}
