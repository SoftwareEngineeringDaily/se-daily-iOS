//
//  CommentsViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 1/31/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import MBProgressHUD


class CommentsViewController: UIViewController {
	
	var tableView: UITableView = UITableView()
	
	var postButton: UIButton!
	var commentTextView: UITextView!
	var postCommentView: UIView!
	var statusLabel: UILabel!
	var cancelReplyButton: UIButton!
	let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	let placeholderText = L10n.commentsPlaceholder
	
	private let refreshControl = UIRefreshControl()
	var rootEntityId: String?
	
	let networkService = API()
	var comments: [Comment] = []
	
	// This is set when user clicks on reply
	var parentCommentSelected: Comment? {
		didSet {
			guard let parentComment = parentCommentSelected else {
				// Hide
				cancelReplyButton.isHidden = true
				statusLabel.text = ""
				return
			}
			cancelReplyButton.isHidden = false
			
			// Show  the reply area
			if let replyTo = parentComment.author.username {
				statusLabel.text = "Reply to: \(replyTo)"
			} else {
				statusLabel.text = "Reply to: \(parentComment.content)"
			}
			
		}
	}
	
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupLayout()
		updateUIBasedOnUser()
		loadComments()
		setupPullToRefresh()
	}
	
	func updateUIBasedOnUser () {
		// Hide if user is not logged in OR if user is limited (no true username)
		if !isFullUser() {
			tableView.tableFooterView = UIView()
			tableView.reloadData()
		} else {
			setupLayoutForUser()
			tableView.reloadData()
		}
	}
	
	func setupPullToRefresh () {
		// Setup pull down to refresh
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl)
		}
		refreshControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
	}
	
	@objc private func refreshListData(_ sender: Any) {
		loadComments()
	}

	
	// Should be in the model but only used by comments for now:
	func isFullUser() -> Bool {
		if !UserManager.sharedInstance.isCurrentUserLoggedIn() {
			return false
		}
		return true
	}
	
	func loadComments() {
		activityIndicator.startAnimating()
		
		guard let rootEntityId = rootEntityId else {
			statusLabel.text = L10n.thereWasAProblem
			return
		}
		networkService.getComments(rootEntityId: rootEntityId, onSuccess: { [weak self] (comments) in
			
			guard let reversedComments = self?.reverseCommentsArray(array: comments) else {
				self?.statusLabel.text = L10n.thereWasAProblem
				return
			}
			guard let flatComments = self?.flattenComments(nestedComments: reversedComments) else {
				self?.statusLabel.text = L10n.thereWasAProblem
				return
			}
			
			self?.comments = flatComments
			self?.tableView.reloadData()
			self?.activityIndicator.stopAnimating()
			self?.refreshControl.endRefreshing()
			}, onFailure: { [weak self] (_) in
				self?.activityIndicator.stopAnimating()
				self?.statusLabel.text = L10n.thereWasAProblem // TODO: This status labels shows only when signed in because belong to footerView
		})
	}
	
	// Edit for not showing deleted
	func flattenComments(nestedComments: [Comment]) -> [Comment] {
		var flatComments: [Comment] = []
		for nestedComment in nestedComments {
			guard !nestedComment.deleted else { continue }
			flatComments.append(nestedComment)
			if let replies = nestedComment.replies {
				for reply in replies {
					guard !reply.deleted else { continue }
					flatComments.append(reply)
				}
			}
		}
		return flatComments
	}
	
	private func reverseCommentsArray(array: [Comment])-> [Comment] {
		let reversed = Array(array.reversed())
		return reversed
	}
	
	@objc func postCommentTapped() {
		self.view.endEditing(true)
		guard let rootEntityId = rootEntityId,
			let commentContent = commentTextView.text,
			commentContent != "",
			commentContent != placeholderText else {
			return
		}
		
		networkService.createComment(rootEntityId: rootEntityId, parentComment: parentCommentSelected, commentContent: commentContent, onSuccess: { [weak self] in
			
			
			self?.commentTextView.text = self?.placeholderText
			self?.commentTextView.isUserInteractionEnabled = true
			self?.postButton.isEnabled = true
			
			self?.statusLabel.text = L10n.succcessfullySubmitted
			self?.parentCommentSelected = nil
			self?.loadComments()
			
			}, onFailure: { [weak self] (_) in
				self?.statusLabel.text = L10n.thereWasAProblem
				self?.postButton.isEnabled = true
				self?.commentTextView.isUserInteractionEnabled = true
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc func cancelReplyTapped(_ sender: UIButton) {
		parentCommentSelected = nil
	}
	
}


extension CommentsViewController: CommentReplyTableViewCellDelegate {
	func replyToCommentPressed(comment: Comment) {
		parentCommentSelected = comment
		commentTextView.becomeFirstResponder()
	}
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return comments.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let comment = comments[indexPath.row]
		
		if comment.parentComment != nil {
			let cell: CommentCell = tableView.dequeueReusableCell(for: indexPath)
			cell.isReplyCell = true
			cell.comment = comment
			cell.callback = { [weak self] user in self?.loadUser(comment: comment) }

			return cell
		} else {
			let cell: CommentCell = tableView.dequeueReusableCell(for: indexPath)
			cell.delegate = self
			cell.replyButton.isHidden = !isFullUser()
			cell.isReplyCell = false
			cell.comment = comment
			cell.callback = { [weak self] user in self?.loadUser(comment: comment) }
			return cell
		}
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
}

extension CommentsViewController {
	private func loadUser(comment: Comment) {
		ProgressIndicator.showBlockingProgress()

		networkService.getUser(userId: comment.author._id!) { user in
			guard let user = user else {
				ProgressIndicator.hideBlockingProgress()
				return }
			
			let vc: ProfileViewController = ProfileViewController()
			vc.user = user
			self.navigationController?.pushViewController(vc, animated: true)
			ProgressIndicator.hideBlockingProgress()
		}
	}
}

extension CommentsViewController {
	private func setupLayout() {
		func setupTableView() {
			tableView.dataSource = self
			tableView.delegate = self
			tableView.register(cellType: CommentCell.self)
			view.addSubview(tableView)
			
			tableView.separatorColor = .clear
			tableView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
			tableView.snp.makeConstraints { (make) -> Void in
				make.top.equalToSuperview()
				make.bottom.equalToSuperview()
				make.right.equalToSuperview()
				make.left.equalToSuperview()
			}
			self.view.layoutIfNeeded()
		}
		
		func setupActivityIndicator() {
			activityIndicator.center = self.view.center
			activityIndicator.hidesWhenStopped = true
			activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
			view.addSubview(activityIndicator)
		}
		
		title = L10n.comments
		setupTableView()
		setupActivityIndicator()
	}
}

extension CommentsViewController {
	private func setupLayoutForUser() {
		postButton = UIButton()
		postCommentView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIView.getValueScaledByScreenWidthFor(baseValue: 375.0), height: UIView.getValueScaledByScreenWidthFor(baseValue: 100.0)))
		postCommentView.backgroundColor = .white
		
		commentTextView = UITextView(frame: .zero)
		commentTextView.toolbarPlaceholder = L10n.typeHere
		commentTextView.text = placeholderText
		commentTextView.textColor = Stylesheet.Colors.grey
		commentTextView.delegate = self
		commentTextView.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
		commentTextView.textAlignment = NSTextAlignment.natural
		commentTextView.backgroundColor = .white
		
		postCommentView.addSubview(postButton)
		postButton.setTitle(L10n.post, for: .normal)
		postButton.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
		postButton.setTitleColor(Stylesheet.Colors.base, for: .normal)
		
		postCommentView.addSubview(commentTextView)
		
		tableView.tableFooterView = postCommentView
		
		statusLabel = UILabel()
		statusLabel.text = ""
		statusLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 10))
		statusLabel.textColor = Stylesheet.Colors.grey
		
		cancelReplyButton = UIButton()
		postCommentView.addSubview(cancelReplyButton)
		cancelReplyButton.setTitleColor(.red, for: .normal)
		cancelReplyButton.titleLabel?.font = UIFont(name: "OpenSans-SemiBold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 10))
		cancelReplyButton.setTitle(L10n.cancelReplyButtonTitle, for: .normal)
		cancelReplyButton.titleLabel?.textColor = .red
		cancelReplyButton.isHidden = true
		
		postCommentView.addSubview(statusLabel)
		
		commentTextView.snp.makeConstraints { (make) -> Void in
			make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
			make.right.equalTo(postButton.snp_left).offset(UIView.getValueScaledByScreenWidthFor(baseValue: -10))
			make.top.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
			make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
		}
		postButton.snp.makeConstraints { (make) -> Void in
			make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
			make.top.equalTo(commentTextView)
		}
		
		statusLabel.snp.makeConstraints { (make) -> Void in
			make.left.equalTo(commentTextView)
			make.bottom.equalTo(commentTextView.snp_top)
		}
		cancelReplyButton.snp.makeConstraints { (make) -> Void in
			make.left.equalTo(statusLabel.snp_right).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
			make.centerY.equalTo(statusLabel.snp_centerY)
		}
		
		postButton.addTarget(self, action: #selector(CommentsViewController.postCommentTapped), for: .touchUpInside)
		postButton.isEnabled = false
		cancelReplyButton.addTarget(self, action: #selector(CommentsViewController.cancelReplyTapped), for: .touchUpInside)
	}
}

extension CommentsViewController: UITextViewDelegate {
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == Stylesheet.Colors.grey {
			postButton.isEnabled = true
			textView.text = nil
			textView.textColor = Stylesheet.Colors.dark
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			postButton.isEnabled = false
			textView.text = placeholderText
			textView.textColor = Stylesheet.Colors.grey
		}
	}
}
