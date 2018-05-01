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
    @IBOutlet weak var upvoteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let iconSize = UIView.getValueScaledByScreenHeightFor(baseValue: 34)

        upvoteButton.setIcon(icon: .fontAwesome(.angleUp), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .normal)
        upvoteButton.setIcon(icon: .fontAwesome(.angleUp), iconSize: iconSize, color: Stylesheet.Colors.base, forState: .selected)
    
        upvoteButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .selected)

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

    @IBAction func upvotePressed(_ sender: UIButton) {
        upvoteButton.isSelected = !upvoteButton.isSelected
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
