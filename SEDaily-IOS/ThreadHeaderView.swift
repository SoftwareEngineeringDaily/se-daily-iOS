//
//  ThreadHeaderView.swift
//  SEDaily-IOS
//
//  Created by jason on 4/28/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class ThreadHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.width
        
        contentLabel.preferredMaxLayoutWidth = titleLabel.bounds.width
    }
    
}
