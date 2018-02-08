//
//  CommentReplyTableViewCell.swift
//  SEDaily-IOS
//
//  Created by jason on 2/2/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class CommentReplyTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var comment: Comment? {
        didSet {
            contentLabel.text = comment?.content
            let prettyDate = comment?.getPostedDate()?.dateString() ?? ""
            dateLabel.text = prettyDate
            if let username = comment?.author.username {
                usernameLabel.text = username
            } else {
                usernameLabel.text = "Anonymous"
            }
            if let imageString = comment?.author.avatarUrl {
                let url = URL(string: imageString)
                avatarImage.kf.setImage(with: url)
            } else {
                avatarImage.image = UIImage(named: "profile-icon-9")
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
