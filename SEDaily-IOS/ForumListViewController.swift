//
//  ForumListViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 4/25/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class ForumListViewController: UIViewController {

    let networkService = API()
    var threads:[ForumThread] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        headerView.backgroundColor = UIColor.cyan
        tableView.tableHeaderView = headerView
    }

    override func viewDidAppear(_ animated: Bool) {
        loadThreads()
    }

    func loadThreads() {
        
        var lastActivityBefore =  ""
        if threads.count > 0 {
            let lastThread = threads[threads.count - 1]
            lastActivityBefore = lastThread.dateLastAcitiy
        }
        
        networkService.getForumThreads(lastActivityBefore: lastActivityBefore, onSuccess: {  [weak self] (threads) in
            
            self?.threads += threads
            self?.tableView.reloadData()
        }) { (error) in
            print("error")
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
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 0)
    }
}

extension ForumListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.threads.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for: indexPath) as? ThreadCell
        let thread = self.threads[indexPath.row]
        cell?.titleLabel.text = thread.title

        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.threads.count-1 { //you might decide to load sooner than -1 I guess...
            loadThreads()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let commentsStoryboard = UIStoryboard.init(name: "Comments", bundle: nil)
        guard let commentsViewController = commentsStoryboard.instantiateViewController(
            withIdentifier: "CommentsViewController") as? CommentsViewController else {
                return
        }
        let thread = threads[indexPath.row]
        commentsViewController.rootEntityId = thread._id
        self.navigationController?.pushViewController(commentsViewController, animated: true)                
    }
}
