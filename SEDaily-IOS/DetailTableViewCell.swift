//
//  DetailTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/28/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Reusable
import SnapKit
import SwifterSwift

class DetailTableViewCell: UITableViewCell, Reusable {
    let containerView = UIView()
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let ageDescLabel = UILabel()
    let ageLabel = UILabel()
    let breedDescLabel = UILabel()
    let breedLabel = UILabel()
    
    let contactButton = UIButton()
    var buttonStackView = UIStackView()
    var contactButtonLabel = UILabel()
    var contactButtonImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(containerView)
        
        let views = [
            titleLabel,
            descLabel,
            ageDescLabel,
            ageLabel,
            breedDescLabel,
            breedLabel,
            ]
        
        self.containerView.addSubviews(views)
        self.containerView.addSubview(contactButton)
        
        self.backgroundColor = .clear
//        setupConstraints()
//        Stylesheet.applyOn(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override func layoutSubviews() {
        
    }
    
    func setupConstraints() {
        self.contentView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().priority(99)
            make.bottom.equalTo(containerView).priority(100)
        }
        
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        ageDescLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(descLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            
            make.height.equalTo(20.calculateHeight())
        }
        
        ageLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ageDescLabel.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            
            make.height.equalTo(20.calculateHeight())
        }
        
        breedDescLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ageLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            
            make.height.equalTo(20.calculateHeight())
        }
        
        breedLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(breedDescLabel.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            
            make.height.equalTo(20.calculateHeight())
        }
        
        contactButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(breedLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            
            make.height.equalTo(36.calculateHeight())
        }
        
        setupButton()
        
        containerView.snp.makeConstraints { (make) -> Void in
            make.top.left.right.equalToSuperview().inset(13)
            make.bottom.equalTo(contactButton).offset(46)
        }
        
        setupLabels()
    }
    
    func setupButton() {
        self.contactButton.addSubview(buttonStackView)
        self.buttonStackView.addArrangedSubview(contactButtonImageView)
        self.buttonStackView.addArrangedSubview(contactButtonLabel)
        
        contactButton.addTarget(self, action: #selector(self.contactButtonPressed), for: .touchUpInside)
        contactButton.setTitleColor(.lightGray, for: .normal)
        contactButton.setBackgroundColor(color: Stylesheet.Colors.offWhite, forState: .normal)
        
        contactButton.cornerRadius = 6
        
        buttonStackView.alignment = .center
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillProportionally
        
        buttonStackView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        
        contactButtonLabel.text = "Contact"
        contactButtonLabel.textColor = .lightGray
        
        contactButtonImageView.image = #imageLiteral(resourceName: "Mail")
        contactButtonImageView.contentMode = .scaleAspectFit
        
        contactButtonLabel.isUserInteractionEnabled = false
        contactButtonImageView.isUserInteractionEnabled = false
        buttonStackView.isUserInteractionEnabled = false
    }
    
    @objc func contactButtonPressed() {
//        guard let urlString = model.websiteURL, model.websiteURL != "" else {
//            Helpers.alertWithMessage(title: Helpers.Alerts.error, message: Helpers.Messages.noWebsite)
//            return
//        }
//        guard let url = URL(string: urlString) else { return }
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
    }
    
    func setupLabels() {
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.numberOfLines = 1
        
        descLabel.adjustsFontSizeToFitWidth = false
        descLabel.minimumScaleFactor = 0.25
        descLabel.numberOfLines = 0
        
        ageDescLabel.adjustsFontSizeToFitWidth = true
        ageDescLabel.minimumScaleFactor = 0.25
        ageDescLabel.numberOfLines = 1
        
        ageLabel.adjustsFontSizeToFitWidth = true
        ageLabel.minimumScaleFactor = 0.25
        ageLabel.numberOfLines = 1
        
        breedDescLabel.adjustsFontSizeToFitWidth = true
        breedDescLabel.minimumScaleFactor = 0.25
        breedDescLabel.numberOfLines = 1
        
        breedLabel.adjustsFontSizeToFitWidth = true
        breedLabel.minimumScaleFactor = 0.25
        breedLabel.numberOfLines = 1
    }
    
    
    
    func setupCell(_ item: PodcastModel) {
//        self.model = item
//        
//        titleLabel.text = item.getName()
//        descLabel.text = item.getDescription()
//        ageDescLabel.text = item.age
//        ageLabel.text = "Age"
//        breedDescLabel.text = item.breed1
//        breedLabel.text = "Breed"
    }
}
