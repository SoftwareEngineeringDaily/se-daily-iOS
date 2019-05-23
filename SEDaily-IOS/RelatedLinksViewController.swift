//
//  RelatedLinksViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 1/28/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class RelatedLinksViewController: UIViewController {
	let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	let networkService: API = API()
	var postId = ""
	var transcriptURL: String?
	let submitButton: UIButton = UIButton()
	
	var shouldShowAdd = true
	
	
	@IBOutlet weak var noRelatedLinks: UILabel!
	var links: [RelatedLink] = []
	@IBOutlet weak var tableView: UITableView!
	
	var addLinkContainer: UIView!
	var addLinkLabel: UILabel!
	var shortDescTextField: UITextField!
	var linkTextField: UITextField!
	var separator: UIView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = L10n.relatedLinks
		
		self.tableView.dataSource = self
		self.tableView.delegate = self
		
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44
		
		setupLayout()
		getRelatedLinks()
		
		// Add activity indicator / spinner
		activityIndicator.center = self.view.center
		activityIndicator.hidesWhenStopped = true
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		view.addSubview(activityIndicator)
		activityIndicator.startAnimating()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func getRelatedLinks() {
		networkService.getRelatedLinks(podcastId: self.postId, onSuccess: { [weak self] relatedLinks in
			self?.links = relatedLinks
			self?.tableView.reloadData()
			self?.activityIndicator.stopAnimating()
			
			//self?.title = "\(relatedLinks.count) \(L10n.relatedLinks)"
			if relatedLinks.count == 0 && self?.transcriptURL == nil {
				self?.tableView.isHidden = true
			}
			}, onFailure: { [weak self] _ in
				self?.showErrorAlert()
		})
	}
	
	@objc func submitTapped() {
		guard let title: String = shortDescTextField.text else { return }
		guard let url: String = linkTextField.text else { return }
		guard !url.isEmpty, !title.isEmpty else {
			Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.fieldEmpty, completionHandler: nil)
			return
		}
		submitButton.isEnabled = false
		networkService.addRelatedLink(podcastId: self.postId, title: title, url: url, onSuccess: { [weak self] in
			self?.getRelatedLinks()
			self?.cleanTextFields()
			self?.submitButton.isEnabled = true
			}, onFailure: { [weak self] _ in
				self?.submitButton.isEnabled = true
				self?.showErrorAlert()
		})
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
		}
	}
}

extension RelatedLinksViewController {
	
}

extension RelatedLinksViewController {
	private func setupLayout() {
		func setupAddLinkContainer() {
			
			addLinkContainer = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 200.0))
			addLinkContainer.backgroundColor = .white
			
			addLinkLabel = UILabel()
			addLinkLabel.text = L10n.newLink
			addLinkLabel.baselineAdjustment = .alignCenters
			addLinkLabel.numberOfLines = 0
			addLinkLabel.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
			addLinkLabel.textColor = Stylesheet.Colors.dark
			
			tableView.tableFooterView = UserManager.sharedInstance.isCurrentUserLoggedIn() ? addLinkContainer : UIView()
			
			separator = UIView()
			separator.backgroundColor = Stylesheet.Colors.light
			
			shortDescTextField = UITextField()
			shortDescTextField.placeholder = L10n.shortTitle
			shortDescTextField.applyStyle()
			
			linkTextField = UITextField()
			linkTextField.placeholder =  L10n.addLink
			linkTextField.applyStyle()
			
			submitButton.setTitle(L10n.submit, for: .normal)
			submitButton.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: UIView.getValueScaledByScreenWidthFor(baseValue: 15))
			submitButton.setTitleColor(Stylesheet.Colors.base, for: .normal)
			
			addLinkContainer.addSubviews([separator, addLinkLabel, shortDescTextField, linkTextField, submitButton])
		}
		
		func setupConstraints() {
			
			separator.snp.makeConstraints { (make) -> Void in
				make.left.right.top.equalToSuperview()
				make.height.equalTo(5.0)
			}
			
			addLinkLabel.snp.makeConstraints { (make) in
				make.top.equalTo(separator.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
			}
			
			shortDescTextField.snp.makeConstraints { (make) in
				make.top.equalTo(addLinkLabel.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
				make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
				make.height.equalTo(40)
				
			}
			
			linkTextField.snp.makeConstraints { (make) in
				make.top.equalTo(shortDescTextField.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
				make.left.equalToSuperview().offset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
				make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 15))
				make.height.equalTo(40)
				
			}
			
			submitButton.snp.makeConstraints { (make) in
				make.top.equalTo(linkTextField.snp_bottom).offset(UIView.getValueScaledByScreenWidthFor(baseValue: 10))
				make.centerX.equalToSuperview()
			}
		}
		setupAddLinkContainer()
		setupConstraints()
		submitButton.addTarget(self, action: #selector(RelatedLinksViewController.submitTapped), for: .touchUpInside)
	}
	
	private func cleanTextFields() {
		shortDescTextField.text = nil
		linkTextField.text = nil
	}
}

extension RelatedLinksViewController {
	private func showErrorAlert() {
		Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.somethingWentWrong, completionHandler: nil)
	}
	private func showEmptyFieldsErrorAlert() {
		Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.fieldEmpty, completionHandler: nil)
	}
}

private extension UITextField {
	func applyStyle() {
		self.borderStyle = .roundedRect
		self.borderColor = Stylesheet.Colors.light
		self.font = UIFont(name: "OpenSans", size: UIView.getValueScaledByScreenWidthFor(baseValue: 13))
	}
}
