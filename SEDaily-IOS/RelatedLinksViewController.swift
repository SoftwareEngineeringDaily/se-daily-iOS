//
//  RelatedLinksViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 1/28/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class RelatedLinksViewController: UIViewController {

    let networkService: API = API()
    var postId = ""
    var links: [RelatedLink] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.relatedLinks
 
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        // TODO: add a spinner
        networkService.getRelatedLinks(podcastId: self.postId, onSuccess: { [weak self] relatedLinks in
            self?.links = relatedLinks
            self?.tableView.reloadData()
        }) { _ in
            // TODO: show an error to user
            print("error--getting-links")
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

}

extension RelatedLinksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.links.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        print("row \(indexPath.row)")
        cell.textLabel?.text = self.links[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Add http:// prefix to url if it doesn't exist so it can be opened:
        // Could be moved to themodel
        var urlString = links[indexPath.row].url
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
            UIApplication.shared.open(linkUrl, options: [:], completionHandler: nil)
        } else {
            print("link null")
        }
    }
}
