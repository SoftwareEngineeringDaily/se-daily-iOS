//
//  PostDetailViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 10/18/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

class PodcastDetailViewController: UIViewController {
    
    var model = PodcastViewModel()
    
    lazy var scrollView: UIScrollView = {
        return UIScrollView(frame: self.view.frame)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Stylesheet.Colors.base
        self.view.addSubview(scrollView)
        
        let headerView = HeaderView(width: 375, height: 200)
        headerView.setupHeader(model: model)
        self.scrollView.addSubview(headerView)
        
        let view = PodcastDescriptionView(origin: headerView.bottomLeftPoint(),width: 375, height: 20)
        view.setupView(podcastModel: model)
        scrollView.addSubview(view)
        view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,
                                     constant: UIView.getValueScaledByScreenHeightFor(baseValue: -65)).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
