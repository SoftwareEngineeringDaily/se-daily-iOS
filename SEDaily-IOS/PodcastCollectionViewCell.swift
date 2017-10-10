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

class PodcastCollectionViewCell: UICollectionViewCell {
    
    private var podcastModel: PodcastModel!
    private var skeletonIndicator: SkeletonIndicator
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        self.skeletonIndicator = SkeletonIndicator()
        super.init(frame: frame)
    
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.titleLabel)
        
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 2.calculateWidth()
        self.contentView.layer.shadowColor = UIColor.lightGray.cgColor
        self.contentView.layer.shadowOpacity = 0.75
        self.contentView.layer.shadowOffset = CGSize(width: 0, height: 1.calculateHeight())
        self.contentView.layer.shadowRadius = 2.calculateWidth()
        
        let topBottomInset = 5.0.calculateHeight()
        let amountToSubtract = topBottomInset * 2
        let twoThirds: CGFloat = (2.0/3.0)
        
        self.imageView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().inset(topBottomInset)
            make.left.right.equalToSuperview().inset(10.calculateWidth())
            make.height.equalTo(((self.height * twoThirds) - amountToSubtract))
        }
        
        self.imageView.contentMode = .scaleAspectFit
        
        let oneThird: CGFloat = (1.0/3.0)
        
        self.titleLabel.snp.makeConstraints{ (make) in
            make.bottom.equalToSuperview().inset(topBottomInset)
            make.left.right.equalToSuperview().inset(10.calculateWidth())
            make.height.equalTo(((self.height * oneThird) - amountToSubtract))
        }

        self.titleLabel.font = UIFont.systemFont(ofSize: 16.calculateWidth())
        self.titleLabel.adjustsFontSizeToFitWidth = false
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.titleLabel.minimumScaleFactor = 0.25
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = Stylesheet.Colors.offBlack
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func setupCell(model: PodcastModel) {
        self.podcastModel = model
        guard let name = model.podcastName else {
            return
        }
        
        titleLabel.text = name
        
        guard let imageURLString = model.imageURLString else {
            self.imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
            return
        }
        
        if let url = URL(string: imageURLString) {
            self.imageView.kf.indicatorType = .custom(indicator: self.skeletonIndicator)
            self.imageView.kf.setImage(with: url)
        }
    }
}

class PodcastCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var timeDayLabel: UILabel!
    private var skeletonIndicator: SkeletonIndicator
    
    override init(frame: CGRect) {
        self.skeletonIndicator = SkeletonIndicator()
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
            self.imageView.kf.indicatorType = .custom(indicator: self.skeletonIndicator)
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
