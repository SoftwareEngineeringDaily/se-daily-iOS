//
//  SkeletonIndicator.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 10/10/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import Kingfisher
import Skeleton

/// Skeleton indicator type for use with the collection cells when loading cell images
class SkeletonIndicator: Indicator {
    private let indicatorView: GradientContainerView!
    
    init() {
        self.indicatorView = GradientContainerView()
        self.indicatorView.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin,
            .flexibleTopMargin]
        let baseColor = UIColor(red: 227, green: 232, blue: 239) ?? UIColor.lightGray
        self.indicatorView.gradientLayer.colors = [
            baseColor.cgColor,
            baseColor.brightened(by: 1.04).cgColor,
            baseColor.cgColor]
    }
    
    func startAnimatingView() {
        self.indicatorView.isHidden = false
        self.slide(to: .right)
    }
    
    func stopAnimatingView() {
        self.indicatorView.isHidden = true
        self.stopSliding()
    }
    
    var view: IndicatorView {
        return self.indicatorView
    }
}

extension UIColor {
    func brightened(by factor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * factor, alpha: a)
    }
}

extension SkeletonIndicator: GradientsOwner {
    var gradientLayers: [CAGradientLayer] {
        return [indicatorView.gradientLayer]
    }
}
