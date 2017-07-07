//
//  AudioViewManager.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/29/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwiftIcons

class AudioViewManager: NSObject {
    static let shared: AudioViewManager = AudioViewManager()
    private override init() {}
    
    var audioView = AudioView()
    
    func presentAudioView() {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            guard !(topController is UIAlertController) else {
                // There's already a alert preseneted
                return
            }

            self.setupView(over: topController)
        }
    }
    
    func setupView(over vc: UIViewController) {
        vc.view.addSubview(audioView)
        
        audioView.width = UIScreen.main.bounds.width
        audioView.height = 110.calculateHeight()
        audioView.center.x = vc.view.center.x
        audioView.frame.origin.y = UIScreen.main.bounds.height

        audioView.animateIn()
        audioView.setupNotificationObserver()
    }
    
    func startActivityIndicator() {
        audioView.startActivityIndicator()
    }
    
    func stopActivityIndicator() {
        audioView.stopActivityIndicator()
    }
    
    public func setText(text: String?) {
        audioView.setText(text: text)
    }
}
