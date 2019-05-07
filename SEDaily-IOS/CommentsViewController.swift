//
//  CommentsViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 1/31/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import Down
class CommentsViewController: UIViewController {
	
	
	@IBOutlet var headerView: ThreadHeaderView!
	
	@IBOutlet weak var closeStatusAreaButton: UIButton!
	@IBOutlet weak var createCommentHeight: NSLayoutConstraint!
	@IBOutlet weak var createCommentHolder: UIView!
	@IBOutlet weak var composeStatusLabel: UILabel!
	
	@IBOutlet weak var composeStatusHolder: UIStackView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var heightOfReplyInfoHolder: NSLayoutConstraint!
	
	var postButton: UIButton!
	var commentTextView: UITextView!
	var postCommentView: UIView!
	
	
	private let refreshControl = UIRefreshControl()
	var rootEntityId: String?
	var thread: ForumThread?
	
	let networkService = API()
	var comments: [Comment] = [] {
		didSet {
			if comments.count == 0 {
				// Still show if thread is defined because that means we'll have a header:
				if thread != nil {
					tableView.isHidden = false
				} else {
					tableView.isHidden = false //edit
				}
			} else {
				tableView.isHidden = false
			}
		}
	}
	
	// Constraints on Comment Holder
	@IBOutlet weak var bottomCommentTextField: NSLayoutConstraint!
	@IBOutlet weak var topStatusHolder: NSLayoutConstraint!
	@IBOutlet weak var topCreateCommentTextField: NSLayoutConstraint!
	@IBOutlet weak var heightCreateCommentTextField: NSLayoutConstraint!
	@IBOutlet weak var heightReplyInfoHolder: NSLayoutConstraint!
	
	// This is set when user clicks on reply
	var parentCommentSelected: Comment? {
		didSet {
			guard let parentComment = parentCommentSelected else {
				// Hide
				composeStatusHolder.isHidden = true
				heightOfReplyInfoHolder.constant = 0
				self.view.layoutIfNeeded()
				return
			}
			
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
	
	let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(cellType: CommentCell.self)
		tableView.separatorColor = .clear
		tableView.contentInset = UIEdgeInsets(top: 20,left: 0,bottom: 0,right: 0)
		
		title = L10n.comments
		// Hide the reply area
		composeStatusHolder.isHidden = true
		heightOfReplyInfoHolder.constant = 0
		self.view.layoutIfNeeded()
		
		// Add activity indicator / spinner
		activityIndicator.center = self.view.center
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		view.addSubview(activityIndicator)
		
		
		updateUIBasedOnUser()
	
		
		// Style (x) close button for status area:
		let iconSize = UIView.getValueScaledByScreenHeightFor(baseValue: 20)
		closeStatusAreaButton.setIcon(icon: .fontAwesome(.times), iconSize: iconSize, color: Stylesheet.Colors.offBlack, forState: .normal)
		
		loadComments()
		setupPullToRefresh()
	}
	
	func updateUIBasedOnUser () {
		// Hide if user is not logged in OR if user is limited (no true username)
		if !isFullUser() {
			// TODO: setting the table view footer would make make this much easier.
			// Constraints:
//			bottomCommentTextField.isActive = false
//			topStatusHolder.isActive = false
//			topCreateCommentTextField.isActive = false
//			heightCreateCommentTextField.isActive = false
//			heightReplyInfoHolder.isActive = false
//
//			//
//			createCommentHeight.constant = 0
//			createCommentHolder.isHidden = true
//			self.view.layoutSubviews()
			tableView.tableFooterView = UIView()
			tableView.reloadData()
		} else {
			setupLayout()
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
		// Fetch Weather Data
		loadComments()
	}
	
//	func setupTableHeader (thread: ForumThread) {
//		headerView.thread = thread
//		tableView.tableHeaderView = headerView
//		headerView.setNeedsLayout()
//		headerView.layoutIfNeeded()
//
//		let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
//		var frame = headerView.frame
//		frame.size.height = height
//		headerView.frame = frame
//
//		tableView.tableHeaderView = headerView
//	}
	
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
			composeStatusLabel.text = L10n.thereWasAProblem
			return
		}
		networkService.getComments(rootEntityId: rootEntityId, onSuccess: { [weak self] (comments) in
			guard let flatComments = self?.flattenComments(nestedComments: comments) else {
				self?.composeStatusLabel.text = L10n.thereWasAProblem
				return
			}
			self?.comments = flatComments
			self?.tableView.reloadData()
			self?.activityIndicator.stopAnimating()
			self?.refreshControl.endRefreshing()
			}, onFailure: { [weak self] (_) in
				self?.activityIndicator.stopAnimating()
				self?.composeStatusLabel.text = L10n.thereWasAProblem
		})
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
	
	
	@objc func postCommentTapped() {
		guard let rootEntityId = rootEntityId, let commentContent = commentTextView.text else {
			//composeStatusLabel.text = L10n.thereWasAProblem
			return
		}
		networkService.createComment(rootEntityId: rootEntityId, parentComment: parentCommentSelected, commentContent: commentContent, onSuccess: { [weak self] in
			
			// Reset input field + re-enable button:
			self?.createCommentTextField.text = ""
			self?.createCommentTextField.isUserInteractionEnabled = true
			self?.submitCommentButton.isEnabled = true
			
			self?.composeStatusLabel.text = L10n.succcessfullySubmitted
			self?.parentCommentSelected = nil
			self?.loadComments()
			}, onFailure: { [weak self] (_) in
				self?.composeStatusLabel.text = L10n.thereWasAProblem
				self?.submitCommentButton.isEnabled = true
				self?.createCommentTextField.isUserInteractionEnabled = true
		})
	}
	
	@IBAction func submitCommentPressed(_ sender: UIButton) {
		self.view.endEditing(true) // Hide keyboard
		
		// Show Reply info holder (so we can use it to display statuses)
		composeStatusLabel.text = L10n.submitting
		composeStatusHolder.isHidden = false
		heightOfReplyInfoHolder.constant = 50
		self.view.layoutIfNeeded()
		
		// Disable text field:
		createCommentTextField.isUserInteractionEnabled = false
		submitCommentButton.isEnabled = false
		
		guard let rootEntityId = rootEntityId, let commentContent = commentTextView.text else {
			composeStatusLabel.text = L10n.thereWasAProblem
			return
		}
		networkService.createComment(rootEntityId: rootEntityId, parentComment: parentCommentSelected, commentContent: commentContent, onSuccess: { [weak self] in
			
			// Reset input field + re-enable button:
			self?.createCommentTextField.text = ""
			self?.createCommentTextField.isUserInteractionEnabled = true
			self?.submitCommentButton.isEnabled = true
			
			self?.composeStatusLabel.text = L10n.succcessfullySubmitted
			self?.parentCommentSelected = nil
			self?.loadComments()
			}, onFailure: { [weak self] (_) in
				self?.composeStatusLabel.text = L10n.thereWasAProblem
				self?.submitCommentButton.isEnabled = true
				self?.createCommentTextField.isUserInteractionEnabled = true
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func cancelReplyPressed(_ sender: UIButton) {
		parentCommentSelected = nil
	}
}

extension CommentsViewController: CommentReplyTableViewCellDelegate {
	func replyToCommentPressed(comment: Comment) {
		parentCommentSelected = comment
		createCommentTextField.becomeFirstResponder()
	}
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Sections and rows? comments and replies, neat idea
		return comments.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let comment = comments[indexPath.row]
		
		if comment.parentComment != nil {
			let cell: CommentCell = tableView.dequeueReusableCell(for: indexPath)
			cell.comment = comment
			return cell
		} else {
			let cell: CommentCell = tableView.dequeueReusableCell(for: indexPath)
			//cell?.delegate = self
			//cell?.hideReplyCell = !isFullUser()
			cell.comment = comment
			return cell
		}
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
}


extension CommentsViewController {
	private func setupLayout() {
		postButton = UIButton()
		postCommentView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIView.getValueScaledByScreenWidthFor(baseValue: 375.0), height: UIView.getValueScaledByScreenWidthFor(baseValue: 100.0)))
		postCommentView.backgroundColor = .white
		commentTextView = UITextView(frame: .zero)
		commentTextView.toolbarPlaceholder = "Type here"
		commentTextView.text = "Add a comment..."
		commentTextView.textColor = Stylesheet.Colors.grey
		commentTextView.delegate = self
		commentTextView.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))

		commentTextView.textAlignment = NSTextAlignment.natural
		
		commentTextView.backgroundColor = .white
		postCommentView.addSubview(postButton)
		postButton.setTitle("Post", for: .normal)
		postButton.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
		postButton.setTitleColor(Stylesheet.Colors.base, for: .normal)
		postCommentView.addSubview(commentTextView)
		tableView.tableFooterView = postCommentView

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
		
		postButton.addTarget(self, action: #selector(CommentsViewController.postCommentTapped), for: .touchUpInside)
		
	}
}

extension CommentsViewController: UITextViewDelegate {
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == Stylesheet.Colors.grey {
			textView.text = nil
			textView.textColor = Stylesheet.Colors.dark
		}
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "Add a comment..."
			textView.textColor = Stylesheet.Colors.grey
		}
}
}
