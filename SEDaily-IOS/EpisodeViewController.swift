//
//  EpisodeViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 4/30/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import UIKit
import WebKit

class EpisodeViewController: UIViewController, WKNavigationDelegate {
	
	weak var delegate: PodcastDetailViewControllerDelegate?
	private weak var audioOverlayDelegate: AudioOverlayDelegate?
	
	
	let networkService: API = API()
	
	var viewModel = PodcastViewModel()
	
	var tableView = UITableView()
	
	var upvoteService: UpvoteService?
	var bookmarkService: BookmarkService?
	
	required init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, audioOverlayDelegate: AudioOverlayDelegate?) {
		self.audioOverlayDelegate = audioOverlayDelegate
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.view.addSubview(tableView)
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(cellType: EpisodeHeaderCell.self)
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 50.0
		//tableView.delegate = self
		tableView.dataSource = self
		tableView.tableFooterView = UIView()
		tableView.backgroundColor = .black
		
		// Do any additional setup after loading the view.
	}
	func commentsButtonPressed(_ viewModel: PodcastViewModel) {
		Analytics2.podcastCommentsViewed(podcastId: viewModel._id)
		let commentsStoryboard = UIStoryboard.init(name: "Comments", bundle: nil)
		guard let commentsViewController = commentsStoryboard.instantiateViewController(
			withIdentifier: "CommentsViewController") as? CommentsViewController else {
				return
		}
		if let thread = viewModel.thread {
			commentsViewController.rootEntityId = thread._id
			self.navigationController?.pushViewController(commentsViewController, animated: true)
		}
	}
}

extension EpisodeViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: EpisodeHeaderCell = tableView.dequeueReusableCell(for: indexPath)
	
		cell.selectionStyle = .none
		cell.bookmarkService = bookmarkService
		cell.upvoteService = upvoteService
		
		cell.viewModel = viewModel
		//cell.layoutIfNeeded()
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
}

extension EpisodeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
