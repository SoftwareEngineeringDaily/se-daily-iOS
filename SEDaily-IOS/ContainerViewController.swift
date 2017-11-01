//
//  ContainerViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 7/19/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var containerView = UIView()

    private var navController = UINavigationController()
    private var tabController = CustomTabViewController()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func navButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.add(asChildViewController: navController)
    }
    
    // MARK: - View Methods
    
    private func setupView() {
        self.view.addSubview(containerView)
        
        containerView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        containerView.backgroundColor = Stylesheet.Colors.white
        
        let navVC = UINavigationController(rootViewController: tabController)
        navVC.view.backgroundColor = .white

        self.navController = navVC
    }
    
    func setContainerViewInset() {
        self.containerView.snp.updateConstraints { (make) -> Void in
            make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: 110))
        }
        
        self.view.layoutIfNeeded()
    }
    
    func removeContainerViewInset() {
        containerView.snp.updateConstraints { (make) -> Void in
            make.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    

    // MARK: - Helper Methods
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        let height = containerView.height
        let width = containerView.width
        viewController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    private func removeAllViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    // Have to set preferredStatusBarStyle here on first view controller
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
