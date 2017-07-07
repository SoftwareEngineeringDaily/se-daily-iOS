//
//  CollectionReusableView.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {
    var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame);

        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints{ (make) in
            make.left.right.equalToSuperview().inset(15.calculateWidth())
            make.top.bottom.equalToSuperview().inset(2.calculateHeight())
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 30.calculateWidth())
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    func setupTitleLabel(title: String) {
        titleLabel.text = title
    }
}
