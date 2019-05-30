//
//  FeedListViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 4/25/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class FeedListViewController: UIViewController {

    let networkService = API()
    var threads: [Any] = []
    var lastThread:ForumThread?
    weak var audioOverlayDelegate: AudioOverlayDelegate?

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
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    func removeSpinner(spinner: UIView) {
        
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadThreads()
        Analytics2.feedViewed()
        Tracker.logFeedViewed()
    }
    @objc private func refreshForumData(_ sender: Any) {
        // Fetch Weather Data
        loadThreads(refreshing: true)
    }

    func loadThreads(refreshing: Bool = false) {
        
        var lastActivityBefore =  ""
        
        var spinner: UIView?
        if threads.count > 0  && refreshing == false {
            // TODO: find last thread:
            
            if  let thread = self.lastThread {
                lastActivityBefore = thread.dateLastAcitiy
            }
        } else {
            // First go:
            if refreshing == false {
                spinner = self.displaySpinner(onView: self.view)
            }
        }
        
        networkService.getFeed(lastActivityBefore: lastActivityBefore, onSuccess: {  [weak self] (threads, lastForumThread) in
            if refreshing {
                self?.threads = []
            }
            if let spinner = spinner {
                    self?.removeSpinner(spinner: spinner)
            }
            
            self?.lastThread = lastForumThread
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
        self.tabBarItem = UITabBarItem(title: L10n.tabBarFeed, image: #imageLiteral(resourceName: "activity_feed"), selectedImage: #imageLiteral(resourceName: "activity_feed_selected"))
    }
}

extension FeedListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.threads.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let thread = self.threads[indexPath.row] as? ForumThread {
            let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for: indexPath) as? FeedItemCell
            cell?.thread = thread
            return cell!
        } else {

            let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for: indexPath) as? FeedItemCell
            if let feedItem = self.threads[indexPath.row] as? FeedItem {
                cell?.relatedLinkFeedItem = feedItem
            }
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: "relatedLinkCell", for: indexPath) as? RelatedLinkTableViewCell
//                if let feedItem = self.threads[indexPath.row] as? FeedItem {
//                    cell?.relatedLink = feedItem.relatedLink
//                }
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.threads.count-1 { //you might decide to load sooner than -1 I guess...
            loadThreads()
        }
    }
    
    func presentThreadComments(_ thread: ForumThread) {
        let commentsStoryboard = UIStoryboard.init(name: "Comments", bundle: nil)
        guard let commentsViewController = commentsStoryboard.instantiateViewController(
            withIdentifier: "CommentsViewController") as? CommentsViewController else {
                return
        }
        //commentsViewController.rootEntityId = thread._id
        //commentsViewController.thread = thread
        self.navigationController?.pushViewController(commentsViewController, animated: true)
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        
        if let thread = self.threads[indexPath.row] as? ForumThread {
            if let liteEpisodeModel = thread.podcastEpisode {
                let spinner = self.displaySpinner(onView: self.view)
                networkService.getPost(podcastId: liteEpisodeModel._id) { (succeeded, fullPodcast) in
                    self.removeSpinner(spinner: spinner)

                    if succeeded && fullPodcast != nil {
                        if let audioOverlayDelegate = self.audioOverlayDelegate {
                            let vc = PodcastDetailViewController(nibName: nil, bundle: nil, audioOverlayDelegate: audioOverlayDelegate)
                            // TODO: check for safety:
                            vc.model =  PodcastViewModel(podcast: fullPodcast!)
                            //                    vc.delegate = self
                            //                    vc.audioOverlayDelegate = self.audioOverlayDelegate
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        self.presentThreadComments(thread)
                    }
                    
                }
            } else {
               presentThreadComments(thread)
            }
        } else if let feedItem = self.threads[indexPath.row] as? FeedItem {
            // TODO: move to model
            var urlString = feedItem.relatedLink.url
            let urlPrefix = urlString.prefix(4)
            if urlPrefix != "http" {
                // Defaulting to http:
                if urlPrefix.prefix(3) == "://" {
                    urlString = "http\(urlString)"
                } else {
                    urlString = "http://\(urlString)"
                }
            }
            
            // Open the link:
            if let linkUrl = URL(string: urlString) {
                let vc = RelatedLinkWebVC()
                vc.url = linkUrl
                self.navigationController?.pushViewController(vc, animated: true)

            } else {
                print("link null")
            }
        }
    }
  
}
