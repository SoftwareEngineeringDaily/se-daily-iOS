//
//  RelatedLinkTableViewCell.swift
//  SEDaily-IOS
//
//  Created by jason on 5/17/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class RelatedLinkTableViewCell: UITableViewCell {
    @IBOutlet weak var urlLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var relatedLink: RelatedLink? {
        didSet {
            if let relatedLink = relatedLink {
                titleLabel.text = relatedLink.title
                urlLabel.text = relatedLink.url
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
