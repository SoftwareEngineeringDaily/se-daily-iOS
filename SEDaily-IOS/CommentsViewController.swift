//
//  CommentsViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 1/31/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {

    @IBOutlet weak var replyInfoHolder: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightOfReplyInfoHolder: NSLayoutConstraint!
    var postId: String? // TODO: make optional so that we can check for it and display error if nil
    let networkService = API()
    var comments: [Comment] = []
//    var parentCommentId: String?
    // This is set when user clicks on reply
    var parentCommentSelected: Comment?  // Maybe just use this...
    
    @IBOutlet weak var commentITextField: UITextField!
    @IBOutlet weak var submitCommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // Hide the reply area
        replyInfoHolder.isHidden = true
        heightOfReplyInfoHolder.constant = 0
        self.view.layoutIfNeeded()
        
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
                
            }) { (error) in
                print("error")
                print(error)
            }
        } else {
            print("postId is null")
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
        
        replyInfoHolder.isHidden = false
        heightOfReplyInfoHolder.constant = 50
        self.view.layoutIfNeeded()
        
        guard let postId = postId, let commentContent = commentITextField.text else { return }
        networkService.createComment(podcastId: postId, parentCommentId: nil, commentContent: commentContent, onSuccess: {
            print("submitted :)")
        }) { (error) in
            print("error submitting comment")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
            cell?.contentLabel?.text = comment.content
            return cell!
        }
        
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
