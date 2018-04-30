//
//  ThreadHeaderView.swift
//  SEDaily-IOS
//
//  Created by jason on 4/28/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class ThreadHeaderView: UIView {

    @IBOutlet weak var label: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.preferredMaxLayoutWidth = label.bounds.width
    }
    
}
