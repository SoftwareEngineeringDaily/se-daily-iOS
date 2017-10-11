//
//  PostDetailTableViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/28/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Reusable

class PostDetailTableViewController: UITableViewController {
    
    var model: PodcastModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(cellType: SingleLabelTableViewCell.self)

        tableView.allowsSelection = false
        tableView.alwaysBounceVertical = false
        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        let headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 200.calculateHeight()))
        headerView.setupHeader(model: model)
        tableView.tableHeaderView = headerView

        self.tableView.backgroundColor = Stylesheet.Colors.base
        setupTitleView()
    }
    
    func setupTitleView() {
        guard let navigationBarHeight = self.navigationController?.navigationBar.height else { return }
        let height = navigationBarHeight - (4.calculateHeight())
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "Logo_BarButton")
        self.navigationItem.titleView = imageView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as SingleLabelTableViewCell
        
        // Configure the cell...
        cell.setupCell(model: model)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = .zero
        }
        
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins))  {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins))  {
            cell.layoutMargins = .zero
        }
        //        cell.isSelected = (indexPath as NSIndexPath).row == selectedRowIndex
    }
}
