//
//  ProgressIndicator.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 11/23/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Foundation
import MBProgressHUD

class ProgressIndicator {
    static func showBlockingProgress() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            MBProgressHUD.showAdded(to: window, animated: true)
        }
    }

    static func hideBlockingProgress() {
        if let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window {
            MBProgressHUD.hide(for: window, animated: true)
        }
    }
}
