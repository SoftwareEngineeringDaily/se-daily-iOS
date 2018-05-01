//
//  ThreadCell.swift
//  SEDaily-IOS
//
//  Created by jason on 4/27/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class ThreadCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var thread: ForumThread? {
        didSet {
            titleLabel.text = thread?.title           
            commentsCountLabel.text = thread?.getCommentsSummary()
            if let author = thread?.author {
                authorLabel.text = (author.name != nil) ? author.name : author.username
            }
            dateLabel.text = thread?.getDatedCreatedPretty()
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
