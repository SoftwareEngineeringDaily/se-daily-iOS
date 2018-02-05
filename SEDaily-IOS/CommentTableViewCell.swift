//
//  CommentTableViewCell.swift
//  SEDaily-IOS
//
//  Created by jason on 2/2/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

protocol  CommentReplyTableViewCellDelegate: class {
    func replyToCommentPressed()
}

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    weak var delegate: CommentReplyTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func replyButtonPressed(_ sender: UIButton) {
        delegate?.replyToCommentPressed()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
