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
		tableView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
	}
	
}
extension ProfileViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: ProfileCell = tableView.dequeueReusableCell(for: indexPath)
		cell.nameLabel.text = "Dawid Cedrych"
		cell.bioLabel.text = "Technology, Design, Future | Co-founder of @Altalogy iOS Dev | Don’t build things that quickly fade into irrelevance."
		cell.linkLabel.text = "www.altalogy.com"
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
