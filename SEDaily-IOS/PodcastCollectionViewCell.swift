//
//  PodcastCollectionViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
import Kingfisher
import KTResponsiveUI

class PodcastCollectionViewCell: UICollectionViewCell {
    
    var podcastModel: PodcastModel!
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        
        self.contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 2.calculateWidth()
        
        contentView.layer.shadowColor = UIColor.lightGray.cgColor
        contentView.layer.shadowOpacity = 0.75
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1.calculateHeight())
        contentView.layer.shadowRadius = 2.calculateWidth()
        
        let topBottomInset = 5.0.calculateHeight()
        let amountToSubtract = topBottomInset * 2
        
        let twoThirds: CGFloat = (2.0/3.0)
        
        imageView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().inset(topBottomInset)
            make.left.right.equalToSuperview().inset(10.calculateWidth())
            make.height.equalTo(((self.height * twoThirds) - amountToSubtract))
        }
        
        imageView.contentMode = .scaleAspectFit
        
        let oneThird: CGFloat = (1.0/3.0)
        
        titleLabel.snp.makeConstraints{ (make) in
            make.bottom.equalToSuperview().inset(topBottomInset)
            make.left.right.equalToSuperview().inset(10.calculateWidth())
            make.height.equalToSuperview().multipliedBy(oneThird)
            make.height.equalTo(((self.height * oneThird) - amountToSubtract))
        }

        titleLabel.font = UIFont.systemFont(ofSize: 16.calculateWidth())
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = Stylesheet.Colors.offBlack
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func setupCell(model: PodcastModel) {
        self.podcastModel = model
        guard let name = model.podcastName else { return }
        titleLabel.text = name
        
        guard let imageURLString = model.imageURLString else {
            self.imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
            return
        }
        if let url = URL(string: imageURLString) {
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: url)
        }
    }
}

class PodcastCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var timeDayLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let newContentView = UIView(width: 158, height: 250)
        self.contentView.frame = newContentView.frame
        
        imageView = UIImageView(leftInset: 0, topInset: 4, width: 158)
        self.contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.cornerRadius = UIView.getValueScaledByScreenHeightFor(baseValue: 6)
        
        titleLabel = UILabel(origin: imageView.bottomLeftPoint(), topInset: 15, width: 158, height: 50)
        self.contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 16))
        
        timeDayLabel = UILabel(origin: titleLabel.bottomLeftPoint(), topInset: 8, width: 158, height: 14)
        self.contentView.addSubview(timeDayLabel)
        timeDayLabel.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 12))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func setupCell(imageURLString: String?, title: String?, timeLength: Int?, date: Date?) {
        self.setupImageView(imageURLString: imageURLString)
        titleLabel.text = title ?? ""
        setupTimeDayLabel(timeLength: timeLength, date: date)
    }
    
    func setupImageView(imageURLString: String?) {
        guard let imageURLString = imageURLString else {
            self.imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
            return
        }
        if let url = URL(string: imageURLString) {
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: url)
        }
    }
    
    func setupTimeDayLabel(timeLength: Int?, date: Date?) {
        let timeString = Helpers.createTimeString(time: (Float(timeLength ?? 0)))
        let dateString = date?.dateString() ?? ""
        guard timeString != "0:00" else {
            timeDayLabel.text = dateString
            return
        }
        timeDayLabel.text = timeString + " \u{2022} " + dateString
    }
}

extension PodcastCell {
    func setupSkeletonCell() {
        
    }
}
