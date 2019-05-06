//
//  RelatedLinksViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 1/28/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//


// TODO: Refactor and add link submit feature

import UIKit

class RelatedLinksViewController: UIViewController {
	let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	let networkService: API = API()
	var postId = ""
	var transcriptURL: String?
	@IBOutlet weak var noRelatedLinks: UILabel!
	var links: [RelatedLink] = []
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = L10n.relatedLinks
		
		self.tableView.dataSource = self
		self.tableView.delegate = self
		
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44
		self.tableView.tableFooterView = UIView()
		
		
		// Add activity indicator / spinner
		activityIndicator.center = self.view.center
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		view.addSubview(activityIndicator)
		activityIndicator.startAnimating()
		
		networkService.getRelatedLinks(podcastId: self.postId, onSuccess: { [weak self] relatedLinks in
			self?.links = relatedLinks
			self?.tableView.reloadData()
			self?.activityIndicator.stopAnimating()
			
			//self?.title = "\(relatedLinks.count) \(L10n.relatedLinks)"
			if relatedLinks.count == 0 && self?.transcriptURL == nil {
				self?.tableView.isHidden = true
			}
			}, onFailure: { _ in
				// TODO: show an error to user
				print("error--getting-links")
		})
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

extension RelatedLinksViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard self.transcriptURL != nil else { return self.links.count }
		return self.links.count + 1
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		if transcriptURL != nil {
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = L10n.transcript
			default:
				cell.textLabel?.text = self.links[indexPath.row-1].title
			}
		} else {
			cell.textLabel?.text = self.links[indexPath.row].title
		}
			cell.textLabel?.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
			cell.textLabel?.textColor = Stylesheet.Colors.dark
			cell.selectionStyle = .none
			cell.accessoryType = .disclosureIndicator
		

		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Add http:// prefix to url if it doesn't exist so it can be opened:
		// Could be moved to themodel
		var urlString: String
		if transcriptURL != nil {
			switch indexPath.row {
			case 0:
				urlString = transcriptURL!
			default:
				urlString = links[indexPath.row-1].url
			}
		} else {
			urlString = links[indexPath.row].url
		}
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
