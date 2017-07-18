//
//  PodcastCollectionViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit
import KoalaTeaFlowLayout
import RealmSwift
import Kingfisher

class PodcastCollectionViewCell: UICollectionViewCell {
    
    var model: PodcastModel!
    
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
        self.model = model
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
