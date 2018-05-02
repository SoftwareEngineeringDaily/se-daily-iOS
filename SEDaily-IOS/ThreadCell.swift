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
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    let networkService = API()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let iconSize = UIView.getValueScaledByScreenHeightFor(baseValue: 34)

        upVoteButton.setIcon(icon: .fontAwesome(.angleUp), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .normal)
        upVoteButton.setIcon(icon: .fontAwesome(.angleUp), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .selected)
        
        upVoteButton.setTitleColor(Stylesheet.Colors.secondaryColor, for: .selected)
    }
    
    var thread: ForumThread? {
        didSet {
            
            if let thread = thread {
                
                let author = thread.author
                authorLabel.text = (author.name != nil) ? author.name : author.username
                
                titleLabel.text = thread.title
                commentsCountLabel.text = thread.getCommentsSummary()
                
                dateLabel.text = thread.getDatedCreatedPretty()
                scoreLabel.text = "\(thread.score)"
            }
            
        }
    }

    @IBAction func upvotePressed(_ sender: UIButton) {
        
        guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
            return
        }
        
        
//        sender.isSelected = !upVoteButton.isSelected
        
        // Immediately set UI to upvote
        self.setUpvoteTo(!self.upVoteButton.isSelected)
        if let thread = thread {
            let entityId = thread._id
            
            networkService.upvoteForum(entityId: entityId, completion: { (success, active) in
                guard success != nil else { return }
                if success == true {
                    guard let active = active else { return }
                    self.addScore(active: active)
                }
            })
        }
    }
    
    func setUpvoteTo(_ bool: Bool) {
        self.upVoteButton.isSelected = bool
    }
    
    func addScore(active: Bool) {
        self.setUpvoteTo(active)
        if let thread = thread {
            guard active != false else {
                self.setScoreTo(thread.score - 1)
                return
            }
            self.setScoreTo(thread.score + 1)
        }
    }
    
    func setScoreTo(_ score: Int) {
        guard self.thread?.score != score else { return }
        self.thread?.score = score
        self.scoreLabel.text = String(score)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
