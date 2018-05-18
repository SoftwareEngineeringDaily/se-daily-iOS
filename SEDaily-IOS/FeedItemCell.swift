//
//  ThreadCell.swift
//  SEDaily-IOS
//
//  Created by jason on 4/27/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class FeedItemCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var subtitleHeightLessThan: NSLayoutConstraint!
    @IBOutlet weak var subtitleHeightGreaterThan: NSLayoutConstraint!
    
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
                _feedItem = thread
                relatedLinkFeedItem = nil
                subtitleLabel.text = ""
                let author = thread.author
                authorLabel.text = (author.name != nil) ? author.name : author.username
                
                titleLabel.text = thread.title
                commentsCountLabel.text = thread.getCommentsSummary()
                
                dateLabel.text = thread.getDateLastActivityPretty()
                
                scoreLabel.text = "\(thread.score)"
                if let upvoted = thread.upvoted {
                    upVoteButton.isSelected = upvoted
                } else {
                    upVoteButton.isSelected = false
                }
            }
        }
    }
    
    var relatedLinkFeedItem: FeedItem? {
        didSet {
            
            if let relatedLinkFeedItem = relatedLinkFeedItem {
                _feedItem = relatedLinkFeedItem.relatedLink
                thread = nil

                titleLabel.text = relatedLinkFeedItem.relatedLink.title
                subtitleLabel.text = ""
                
                scoreLabel.text = "\(relatedLinkFeedItem.relatedLink.score)"
                if let upvoted = relatedLinkFeedItem.relatedLink.upvoted {
                    upVoteButton.isSelected = upvoted
                } else {
                    upVoteButton.isSelected = false
                }

            }
        }
    }
    
    var _feedItem: BaseFeedItem?
    
    @IBAction func upvotePressed(_ sender: UIButton) {        
        guard UserManager.sharedInstance.isCurrentUserLoggedIn() == true else {
            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.youMustLogin, completionHandler: nil)
            return
        }
        
        // Immediately set UI to upvote

        self.setUpvoteTo(!self.upVoteButton.isSelected)
        if let  feedItem = _feedItem {
            let entityId = feedItem._id
            if thread != nil {

                networkService.upvoteForum(entityId: entityId, completion: { (success, active) in
                    guard success != nil else { return }
                    if success == true {
                        guard let active = active else { return }
                        self.thread?.score = self.addScore(active: active)
                        self.thread?.upvoted = active
                    }
                })
            } else if relatedLinkFeedItem != nil {
                networkService.upvoteRelatedLink(entityId: entityId, completion: { (success, active) in
                    guard success != nil else { return }
                    if success == true {
                        guard let active = active else { return }
                        self.relatedLinkFeedItem?.relatedLink.score = self.addScore(active: active)
                         self.relatedLinkFeedItem?.relatedLink.upvoted = active
 
                    }
                })
            }
        }
    }
    
    func setUpvoteTo(_ bool: Bool) {
        _feedItem?.upvoted = bool
        self.upVoteButton.isSelected = bool
    }
    
    func addScore(active: Bool)  -> Int {
        self.setUpvoteTo(active)
        
        if var _feedItem = _feedItem {
            _feedItem.upvoted = active
            guard active != false else {
                return self.setScoreTo(_feedItem.score - 1)
                
            }
            return self.setScoreTo(_feedItem.score + 1)
        }
        return 0
    }
    
    func setScoreTo(_ score: Int) -> Int {
        if var _feedItem = _feedItem {
            guard _feedItem.score != score else { return 0}
            _feedItem.score = score
            self.scoreLabel.text = String(score)
            return score
        }
        return 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
