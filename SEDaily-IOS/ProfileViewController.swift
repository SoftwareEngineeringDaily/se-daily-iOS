//
//  ProfileViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 5/7/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
	
	var tableView: UITableView = UITableView()
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(tableView)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50.0
		tableView.tableFooterView = UIView()
		tableView.allowsSelection = false
		tableView.separatorColor = .clear
		tableView.backgroundColor = .white
		tableView.register(cellType: ProfileCell.self)
		NotificationCenter.default.addObserver(self, selector: #selector(self.loginObserver), name: .loginChanged, object: nil)
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
		API().loadUserInfo()
	}
	@objc func loginObserver() {
		tableView.reloadData()
	}
}
extension ProfileViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: ProfileCell = tableView.dequeueReusableCell(for: indexPath)
		cell.nameLabel.text = UserManager.sharedInstance.getActiveUser().fullName
		cell.usernameOrEmailLabel.text = UserManager.sharedInstance.getActiveUser().usernameOrEmail
		cell.bioLabel.text = UserManager.sharedInstance.getActiveUser().bio
		cell.linkLabel.text = UserManager.sharedInstance.getActiveUser().website
		cell.setupAvatar(imageURL: URL(string: UserManager.sharedInstance.getActiveUser().avatarURL))
		return cell
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
}


extension ProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
