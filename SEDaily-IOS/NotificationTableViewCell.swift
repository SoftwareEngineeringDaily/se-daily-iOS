//
//  NotificationTableViewCell.swift
//  SEDaily-IOS
//
//  Created by Keith Holliday on 4/2/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import Reusable
import SnapKit
import SwifterSwift
import KTResponsiveUI
import Kingfisher

class NotificationTableViewCell: UITableViewCell, Reusable {
    public var cellLabel: UILabel!
    private var cellImageView: UIImageView!
    public var cellToggle: UISwitch!
    
    var viewModel: PodcastViewModel = PodcastViewModel() {
        willSet {
            guard newValue != self.viewModel else { return }
        }
        didSet {
            self.cellLabel.text = viewModel.podcastTitle
            
            if let url = viewModel.featuredImageURL {
                cellImageView.kf.setImage(with: url)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        cellImageView = UIImageView(leftInset: 10, topInset: 5, height: 75)
        cellImageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
        cellImageView.contentMode = .scaleAspectFit
        cellImageView.clipsToBounds = true
        cellImageView.kf.indicatorType = .activity

        cellLabel = UILabel(origin: cellImageView.topRightPoint(), leftInset: 10, width: 210, height: 75)
        cellLabel.textColor = .black
        cellLabel.baselineAdjustment = .alignCenters
        cellLabel.numberOfLines = 0

        cellToggle = UISwitch(origin: cellLabel.topRightPoint(), leftInset: 10, topInset: 22, width: 20)

        self.contentView.addSubview(cellImageView)
        self.contentView.addSubview(cellLabel)
        self.contentView.addSubview(cellToggle)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
}
