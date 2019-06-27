//
//  RootViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/26/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit

class RootViewController: UIViewController, MainCoordinated  {
	
	private var containerView = UIView()
	private var overlayContainerView = UIView()
	private var tabController: MainTabBarController = MainTabBarController()
	var overlayController: OverlayViewController = OverlayViewController()
	
	weak var mainCoordinator: MainFlowCoordinator?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		overlayController.delegate = self
		configure()
	}
	
	private func add(asChildViewController viewController: UIViewController, container: UIView) {
		// Add Child View Controller
		addChildViewController(viewController)
		container.addSubview(viewController.view)
		
		let height = container.frame.height
		let width = container.frame.width
		viewController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		viewController.didMove(toParentViewController: self)
	}
	
	private func toggleState() {
		overlayContainerView.snp.remakeConstraints { (make) -> Void in
			self.overlayController.expanded ? make.height.equalTo(100) : make.top.equalToSuperview()
			self.overlayController.expanded ? make.bottom.equalTo(tabController.tabBar.snp.top) : make.bottom.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
		}
		
		UIView.animate(withDuration: 0.2, animations: {
			self.view.layoutIfNeeded()
		})
		
		overlayController.expanded = !overlayController.expanded
	}
	
	@objc func didTap() {
		expand()
	}
	
	@objc func didSwipeDown() {
		collapse()
	}
	
	private func collapse() {
		if overlayController.expanded {
			toggleState()
		}
	}
	
	private func expand() {
		if !overlayController.expanded {
			toggleState()
		}
	}
}

extension RootViewController {
	private func configure() {
		
		self.view.backgroundColor = .blue
		
		self.view.addSubview(containerView)
		self.view.addSubview(overlayContainerView)
		self.add(asChildViewController: tabController, container: containerView)
		self.add(asChildViewController: overlayController, container: overlayContainerView)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(RootViewController.didTap))
		overlayContainerView.addGestureRecognizer(tap)
		overlayContainerView.isUserInteractionEnabled = true
		
		let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
		swipeDown.direction = .down
		self.overlayContainerView.addGestureRecognizer(swipeDown)
		
		containerView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		overlayContainerView.snp.makeConstraints { (make) -> Void in
			make.height.equalTo(100.0)
			make.right.equalToSuperview()
			make.left.equalToSuperview()
			make.bottom.equalTo(tabController.tabBar.snp.top)
		}
	}
}

extension RootViewController: OverlayViewDelegate {
	
	func didSelectInfo() {
		guard let vc = tabController.selectedViewController as? UINavigationController else { return }
		//mainCoordinator?.viewController(vc, didSelect: "")
		collapse()
	}
	
	func didTapCollapse() {
		collapse()
	}
}
