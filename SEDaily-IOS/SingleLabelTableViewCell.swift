//
//  SingleLabelTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/28/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Reusable
import KTResponsiveUI
import SwifterSwift
import ActiveLabel

class SingleLabelTableViewCell: UITableViewCell, Reusable {
    lazy var label: ActiveLabel = {
        return ActiveLabel(leftInset: 15, topInset: 15, width: 375 - 30, height: 20)
    }()
    
    let bottomMarginForLabel = UIView.getValueScaledByScreenHeightFor(baseValue: 30)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(label)

//        self.heightAnchor.constraint(equalTo: label.heightAnchor,
//                                     constant: bottomMarginForLabel).isActive = true
//        label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
//        self.contentView.snp.makeConstraints { (make) in
//            make.top.left.right.equalToSuperview()
//            make.bottom.equalToSuperview().priority(99)
//            make.bottom.equalTo(label).priority(100)
//        }
        
        self.backgroundColor = Stylesheet.Colors.offWhite
//        Stylesheet.applyOn(self)
        
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
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    // Setup cell with completion() because we are setting text asynchronously
    func setupCell(model: PodcastViewModel) {
        model.getHTMLDecodedDescription { (returnedString) in
            self.label.text = returnedString
            self.label.sizeToFit()
        }
    }
}
