//
//  ForumListViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 4/25/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import Firebase

class ForumListViewController: UIViewController {

    let networkService = API()
    var threads: [Any] = []
    private let refreshControl = UIRefreshControl()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self               
        
        // Setup pull down to refresh
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshForumData(_:)), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        loadThreads()
        Analytics2.forumViewed()
    }
    @objc private func refreshForumData(_ sender: Any) {
        // Fetch Weather Data
        loadThreads(refreshing: true)
    }
    
    func loadThreads(refreshing: Bool = false) {
        
        var lastActivityBefore =  ""
        if threads.count > 0  && refreshing == false {
            let lastThread = threads[threads.count - 1]
            if  let thread = lastThread as? ForumThread {
                lastActivityBefore = thread.dateLastAcitiy
            }
        }
        
        networkService.getForumThreads(lastActivityBefore: lastActivityBefore, onSuccess: {  [weak self] (threads) in
            if refreshing {
                self?.threads = []
            }
            
            self?.threads += threads
            self?.tableView.reloadData()
            if refreshing {
                self?.refreshControl.endRefreshing()
            }
        }, onFailure: { (_ ) in
            print("error")
        })
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
        self.tabBarItem = UITabBarItem(title: L10n.tabBarForum, image: #imageLiteral(resourceName: "bubbles"), selectedImage: #imageLiteral(resourceName: "bubbles_selected"))
    }
}

extension ForumListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.threads.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let thread = self.threads[indexPath.row] as? ForumThread {
            let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for: indexPath) as? ForumThreadCell
            cell?.thread = thread
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell
            cell?.textLabel?.text = "wassaaaaaaaaaaaaaaaaaAAAAAAAAAAAA"
            print("WASSSSSSSSSSSSAAAAAAAAA-----------")
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.threads.count-1 { //you might decide to load sooner than -1 I guess...
            loadThreads()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let commentsStoryboard = UIStoryboard.init(name: "Comments", bundle: nil)
        guard let commentsViewController = commentsStoryboard.instantiateViewController(
            withIdentifier: "CommentsViewController") as? CommentsViewController else {
                return
        }
//        let thread = threads[indexPath.row]
//        commentsViewController.rootEntityId = thread._id
//        commentsViewController.thread = thread
//        self.navigationController?.pushViewController(commentsViewController, animated: true)
    }
}
