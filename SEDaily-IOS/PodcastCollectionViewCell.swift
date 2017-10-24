//
//  PodcastCollectionViewCell.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/27/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit
import KTResponsiveUI
import Skeleton
import SDWebImage

class PodcastCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var timeDayLabel: UILabel!
    
    var viewModel: PodcastViewModel = PodcastViewModel() {
        willSet {
            guard newValue != self.viewModel else { return }
        }
        didSet {
            self.titleLabel.text = viewModel.podcastTitle
            viewModel.getLastUpdatedAsDateWith { (date) in
                self.setupTimeDayLabel(timeLength: nil, date: date)
            }
            self.setupImageView(imageURL: viewModel.featuredImageURL)
        }
    }
    
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
    
    private func setupImageView(imageURL: URL?) {
        guard let imageURL = imageURL else {
            self.imageView.image = #imageLiteral(resourceName: "SEDaily_Logo")
            return
        }

        imageView.sd_setShowActivityIndicatorView(true)
        imageView.sd_setIndicatorStyle(.gray)
        imageView.sd_setImage(with: imageURL)
    }
    
    private func setupTimeDayLabel(timeLength: Int?, date: Date?) {
        let dateString = date?.dateString() ?? ""
        timeDayLabel.text = dateString
    }
    
    // MARK: Skeleton
    var skeletonImageView: GradientContainerView!
    var skeletonTitleLabel: GradientContainerView!
    var skeletontimeDayLabel: GradientContainerView!
    
    private func setupSkeletonView() {
        self.skeletonImageView = GradientContainerView(frame: self.imageView.frame)
        self.skeletonImageView.cornerRadius = self.imageView.cornerRadius
        self.skeletonImageView.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
        self.contentView.addSubview(skeletonImageView)
        skeletonTitleLabel = GradientContainerView(origin: imageView.bottomLeftPoint(), topInset: 15, width: 158, height: 14)
        self.contentView.addSubview(skeletonTitleLabel)
        skeletontimeDayLabel = GradientContainerView(origin: skeletonTitleLabel.bottomLeftPoint(), topInset: 15, width: 158, height: 14)
        self.contentView.addSubview(skeletontimeDayLabel)
        
        let baseColor = self.skeletonImageView.backgroundColor!
        let gradients = baseColor.getGradientColors(brightenedBy: 1.07)
        self.skeletonImageView.gradientLayer.colors = gradients
        self.skeletonTitleLabel.gradientLayer.colors = gradients
        self.skeletontimeDayLabel.gradientLayer.colors = gradients
    }
    
    func setupSkeletonCell() {
        self.setupSkeletonView()
        self.slide(to: .right)
    }
}

extension PodcastCell: GradientsOwner {
    var gradientLayers: [CAGradientLayer] {
        return [skeletonImageView.gradientLayer,
                skeletonTitleLabel.gradientLayer,
                skeletontimeDayLabel.gradientLayer
        ]
    }
}

extension UIColor {
    func brightened(by factor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * factor, alpha: a)
    }
    
    func getGradientColors(brightenedBy: CGFloat) -> [Any] {
        return [self.cgColor,
                self.brightened(by: brightenedBy).cgColor,
                self.cgColor]
    }
}
