//
//  PodcastDescriptionView.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/18/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import ActiveLabel
import KTResponsiveUI

class PodcastDescriptionView: UIView {

    private lazy var label: ActiveLabel = {
        return ActiveLabel(leftInset: 15, topInset: 15, width: 375 - 30, height: 600)
    }()

    private let bottomMarginForLabel = UIView.getValueScaledByScreenHeightFor(baseValue: 30)

    override func performLayout() {
        self.backgroundColor = Stylesheet.Colors.offWhite

        self.addSubview(label)
        self.height = label.height

        label.numberOfLines = 0
        label.enabledTypes = [.url]
        label.textColor = Stylesheet.Colors.offBlack
        label.handleURLTap { url in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                Tracker.logMovedToWebView(url: url.absoluteString)
            } else {
                UIApplication.shared.openURL(url)
                Tracker.logMovedToWebView(url: url.absoluteString)
            }
        }
    }

    func setupView(podcastModel: PodcastViewModel) {
        podcastModel.getHTMLDecodedDescription { (returnedString) in
            self.label.text = returnedString
            self.label.sizeToFit()
            self.height = self.label.height + self.bottomMarginForLabel
        }
    }
}
