//
//  ShareButton.swift
//  SEDaily-IOS
//
//  Created by Joseph Carson on 1/9/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import Foundation
import SwiftyBeaver
import UIKit

class ShareButtonViewController: UIViewController {
    
    // The object to share.
    public var shareObj: Any?
    
    @objc override func loadView() {
        
        let button = UIButton()
        button.addTarget(self, action: #selector(self.shareButtonPressed), for: .touchUpInside)
        button.setTitle("Share", for: .normal)
        button.setBackgroundColor(color: Stylesheet.Colors.shareButtonDefault, forState: .normal)
        button.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 4)
        
        view = button
    }
    
    @objc func shareButtonPressed() {
        SwiftyBeaver.info("Share UI Button Pressed")
        let shareUI = SharePodcastViewController(activityItems: [shareObj!], applicationActivities: nil)
        
        shareUI.modalPresentationStyle = .popover
        shareUI.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) -> Void in
            SwiftyBeaver.info("Share UI Complete error: \(String(describing: activityError))")
        }
        
        let pop = shareUI.popoverPresentationController
        pop!.sourceView = self.view
        self.present(shareUI, animated: true, completion: nil)
    }
}
