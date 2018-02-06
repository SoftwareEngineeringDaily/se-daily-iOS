//
//  CommentsViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 1/31/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {

    @IBOutlet weak var createCommentHeight: NSLayoutConstraint!
    @IBOutlet weak var createCommentHolder: UIView!
    @IBOutlet weak var composeStatusLabel: UILabel!
    
    @IBOutlet weak var composeStatusHolder: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightOfReplyInfoHolder: NSLayoutConstraint!
    var postId: String? // TODO: make optional so that we can check for it and display error if nil
    let networkService = API()
    var comments: [Comment] = []
    
    // This is set when user clicks on reply
    var parentCommentSelected: Comment?  {
        didSet {
            guard let parentComment = parentCommentSelected else {
                // Hide
                composeStatusHolder.isHidden = true
                heightOfReplyInfoHolder.constant = 0
                self.view.layoutIfNeeded()
                
                return
            }
            
            print("didSet parent comment")
            // Show  the reply area
            if let replyTo = parentComment.author.username {
                composeStatusLabel.text = "Reply to: \(replyTo)"
                
            } else {
                   composeStatusLabel.text = "Reply to: \(parentComment.content)"
            }
            
            composeStatusHolder.isHidden = false
            heightOfReplyInfoHolder.constant = 50
            view.layoutIfNeeded()
        }
    }
    
    @IBOutlet weak var createCommentTextField: UITextField!
    @IBOutlet weak var submitCommentButton: UIButton!
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // Hide the reply area
        composeStatusHolder.isHidden = true
        heightOfReplyInfoHolder.constant = 0
        self.view.layoutIfNeeded()
    
        // Add activity indicator / spinner
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        // Fetch comments
        if let postId = postId {
            networkService.getComments(podcastId: postId, onSuccess: { [weak self] (comments) in
                print("got comments")
                print(comments)
                guard let flatComments = self?.flattenComments(nestedComments: comments) else {
                    print("error flattinging")
                    return
                }
                self?.comments = flatComments
                self?.tableView.reloadData()
                
                self?.activityIndicator.stopAnimating()
            }) { [weak self] (error) in
                print("error")
                self?.composeStatusLabel.text = "There was a problem :("
                print(error)
                
            }
        } else {
            print("postId is null")
        }
        
        // Hide if user is not logged in OR if user is limited (no true username / email/ name)
        // TODO: make sure user has an email & a username to post :(
        if !UserManager.sharedInstance.isCurrentUserLoggedIn() {
            // TODO: hide the reponse area
            createCommentHeight.constant = 0
            createCommentHolder.isHidden = true
            self.view.layoutSubviews()
        }
    
    }

    func flattenComments(nestedComments: [Comment]) -> [Comment] {
        var flatComments: [Comment] = []
        for nestedComment in nestedComments {
            flatComments.append(nestedComment)
            if let replies = nestedComment.replies {
                for reply in replies {
                    flatComments.append(reply)
                }
            }
        }
        return flatComments
    }
    
    @IBAction func submitCommentPressed(_ sender: UIButton) {
        print("submitting")
        
        // Show Reply info holder (so we can use it to display)
        composeStatusLabel.text = "Submitting..."
        composeStatusHolder.isHidden = false
        heightOfReplyInfoHolder.constant = 50
        self.view.layoutIfNeeded()
        
        // Disable text field:
        createCommentTextField.isUserInteractionEnabled = false
        submitCommentButton.isEnabled = false
        
        guard let postId = postId, let commentContent = createCommentTextField.text else { return }
        networkService.createComment(podcastId: postId, parentComment: parentCommentSelected, commentContent: commentContent, onSuccess: { [weak self] in
            print("submitted :)")
            
            // Reset text field + button:
            self?.createCommentTextField.text = ""
            self?.createCommentTextField.isUserInteractionEnabled = true
            self?.submitCommentButton.isEnabled = true
            
            self?.composeStatusLabel.text = "Successfully submitted :)"
        })  { [weak self] (error)  in
            print("error submitting comment")
            self?.composeStatusLabel.text = "There was a problem :("
            self?.submitCommentButton.isEnabled = true
            self?.createCommentTextField.isUserInteractionEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelReplyPressed(_ sender: UIButton) {
        print("cancel reply pressed")
        parentCommentSelected = nil
    }
}

extension CommentsViewController: CommentReplyTableViewCellDelegate {
    func replyToCommentPressed(comment: Comment) {
        parentCommentSelected = comment
        print("set comment")
        print(comment)
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Sections and rows? comments and replies, neat idea
        return comments.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = comments[indexPath.row]
        // TODO: avoid force castt
        if comment.parentComment != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as? CommentReplyTableViewCell
            cell?.contentLabel.text = comment.content
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentTableViewCell
            cell?.delegate = self
            cell?.comment = comment
            return cell!
        }
        
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
