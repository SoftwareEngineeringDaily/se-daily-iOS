//
//  SingleLabelTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/28/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Reusable
import SnapKit
import SwifterSwift
import ActiveLabel

class SingleLabelTableViewCell: UITableViewCell, Reusable {
    let label = ActiveLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(label)
        
        self.contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(99)
            make.bottom.equalTo(label).priority(100)
        }
        
        self.label.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(15.calculateHeight())
            make.left.right.equalToSuperview().inset(15.calculateWidth())
        }

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
    
    func setupCell(model: PodcastModel) {
        label.text = model.getDescription()
    }
}
