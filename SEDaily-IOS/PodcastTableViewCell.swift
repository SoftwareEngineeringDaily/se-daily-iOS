//
//  PodcastTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 9/8/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import Reusable
import SnapKit
import SwifterSwift
import KTResponsiveUI
import Kingfisher

class PodcastTableViewCell: UITableViewCell, Reusable {
    private var cellLabel: UILabel!
    private var cellImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellImageView = UIImageView(leftInset: 10, height: 75, keepEqual: true)
        cellImageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
        cellImageView.contentMode = .scaleAspectFit
        cellImageView.clipsToBounds = true
        
        cellLabel = UILabel(origin: cellImageView.topRightPoint(), leftInset: 10, width: 250, height: 75)
        cellLabel.textColor = .black
        cellLabel.baselineAdjustment = .alignCenters
        cellLabel.numberOfLines = 0
        
        self.contentView.addSubview(cellImageView)
        self.contentView.addSubview(cellLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func setupCell(title: String, imageURLString: String?) {
        self.cellLabel.text = title
        
        guard let imageURLString = imageURLString else { return }
        if let url = URL(string: imageURLString) {
            self.cellImageView.kf.indicatorType = .activity
            self.cellImageView.kf.setImage(with: url)
        }
    }
}
