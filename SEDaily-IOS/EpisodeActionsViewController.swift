////
////  EpisodeActionsViewController.swift
////  SEDaily-IOS
////
////  Created by Dawid Cedrych on 5/1/19.
////  Copyright © 2019 Altalogy. All rights reserved.
////
//

// TODO: BUILD IT FOR REUSE IN VARIOUS CELLS
//import UIKit
//
//class EpisodeActionsViewController: UIViewController {
//
//	let actionStackView: UIStackView = UIStackView()
//	let upvoteButton: UIButton = UIButton()
//	let commentButton: UIButton = UIButton()
//	let bookmarkButton: UIButton = UIButton()
//
//	let upvoteCountLabel: UILabel = UILabel()
//
//	var commentShowCallback: ( ()-> Void) = {}
//
//	let upvoteStackView: UIStackView = UIStackView()
//
//	var viewModel: PodcastViewModel = PodcastViewModel() {
//		willSet {
//			guard newValue != self.viewModel else { return }
//		}
//		didSet {
//			//updateUI()
//		}
//	}
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		setupLayout()
//		setupButtonsTargets()
//	}
//	private func setupButtonsTargets() {
//		upvoteButton.addTarget(self, action: #selector(EpisodeActionsViewController.upvoteTapped), for: .touchUpInside)
//		bookmarkButton.addTarget(self, action: #selector(EpisodeActionsViewController.bookmarkTapped), for: .touchUpInside)
//		commentButton.addTarget(self, action: #selector(EpisodeActionsViewController.commentTapped), for: .touchUpInside)
//	}
//
//	@objc func upvoteTapped() {
//		let impact = UIImpactFeedbackGenerator()
//		impact.impactOccurred()
//
//		//upvoteService?.UIDelegate = self
//		//upvoteService?.upvote()
//	}
//
//	@objc func bookmarkTapped() {
//		let selection = UISelectionFeedbackGenerator()
//		selection.selectionChanged()
//
//		//bookmarkService?.UIDelegate = self
//		//bookmarkService?.setBookmark()
//	}
//
//	@objc func commentTapped() {
//		let notification = UINotificationFeedbackGenerator()
//		notification.notificationOccurred(.success)
//		commentShowCallback()
//
//	}
//}
//
//extension EpisodeActionsViewController {
//	private func setupLayout() {
//		func setupActionButtons() {
//			upvoteButton.setIcon(icon: .ionicons(.iosHeartOutline), iconSize: 25.0, color: Stylesheet.Colors.grey, forState: .normal)
//			upvoteButton.setIcon(icon: .ionicons(.iosHeart), iconSize: 25.0, color: Stylesheet.Colors.base, forState: .selected)
//
//			bookmarkButton.setImage(UIImage(named: "ios-bookmark"), for: .normal)
//			bookmarkButton.setImage(UIImage(named: "ios-bookmark-fill"), for: .selected)
//
//			commentButton.setIcon(icon: .ionicons(.iosChatbubbleOutline), iconSize: 30.0, color: Stylesheet.Colors.grey, forState: .normal)
//			commentButton.setIcon(icon: .ionicons(.iosChatbubble), iconSize: 30.0, color: Stylesheet.Colors.base, forState: .selected)
//
//		}
//		func setupUpvoteStackView() {
//			upvoteStackView.alignment = .center
//			upvoteStackView.axis = .horizontal
//			upvoteStackView.distribution = .fillEqually
//
//			upvoteStackView.addArrangedSubview(upvoteButton)
//			upvoteStackView.addArrangedSubview(upvoteCountLabel)
//		}
//
//		func setupActionStackView() {
//			actionStackView.alignment = .center
//			actionStackView.axis = .horizontal
//			actionStackView.distribution = .fillEqually
//
//			actionStackView.addArrangedSubview(upvoteStackView)
//			actionStackView.addArrangedSubview(commentButton)
//			actionStackView.addArrangedSubview(bookmarkButton)
//
//			view.addSubview(actionStackView)
//		}
//		func setupConstrains() {
//
//			actionStackView.snp.makeConstraints { (make) -> Void in
//				make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue:5.0))
//				make.left.equalToSuperview()
//			}
//
//			upvoteButton.snp.makeConstraints { (make) -> Void in
//				make.right.equalTo(upvoteCountLabel.snp.left)
//			}
//		}
//		setupActionButtons()
//		setupUpvoteStackView()
//		setupActionStackView()
//		setupConstrains()
//	}
//}
