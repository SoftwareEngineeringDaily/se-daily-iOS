//
//  RootViewController.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/26/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import UIKit
import SnapKit

class RootViewController: UIViewController, MainCoordinated, Stateful  {
  
  var stateController: StateController?
  
	private var containerView = UIView()
	private var overlayContainerView = UIView()
	private var tabController: MainTabBarController = MainTabBarController()
	var overlayController: OverlayViewController = OverlayViewController()
	
	weak var mainCoordinator: MainFlowCoordinator?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		overlayController.delegate = self
		configure()
    getRecentlyListenedPodcast()
	}
	
	private func getRecentlyListenedPodcast() {
		
		guard let id = PlayProgressModelController.getRecentlyListenedEpisodeId() else { return }
		let repository = PodcastRepository()
		repository.retrieveRecentlyListened(podcastId: id,
																				onSuccess: { [weak self](podcasts) in
																					podcasts.forEach({ podcast in
                                            guard let strongSelf = self else { return }
																						let viewModel = PodcastViewModel(podcast: podcast)
                                            strongSelf.overlayController.viewModel = viewModel
                                            strongSelf.overlayContainerView.isHidden = false
                                            strongSelf.stateController?.isOverlayShowing = true
                                            strongSelf.stateController?.setCurrentlyPlaying(id: viewModel._id)
																					})},
																				onFailure: { _ in })
	}
	
	
	private func toggleState() {
		overlayContainerView.snp.remakeConstraints { (make) -> Void in
			self.overlayController.expanded ? make.height.equalTo(80) : make.top.equalToSuperview()
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
  
  private func addOverlayViewController(viewModel: PodcastViewModel) {
    view.addSubview(overlayContainerView)
    mainCoordinator?.configure(viewController: overlayController)
    add(asChildViewController: overlayController, container: overlayContainerView)
    
    overlayContainerView.isHidden = true
    stateController?.isOverlayShowing = false

    let tap = UITapGestureRecognizer(target: self, action: #selector(RootViewController.didTap))
    overlayContainerView.addGestureRecognizer(tap)
    overlayContainerView.isUserInteractionEnabled = true
    
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
    swipeDown.direction = .down
    self.overlayContainerView.addGestureRecognizer(swipeDown)
    
    overlayContainerView.snp.makeConstraints { (make) -> Void in
      make.height.equalTo(80.0)
      make.right.equalToSuperview()
      make.left.equalToSuperview()
      make.bottom.equalTo(tabController.tabBar.snp.top)
    }
    
    overlayController.viewModel = viewModel
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
}

extension RootViewController {
  
	private func configure() {
		self.view.backgroundColor = .blue
		self.view.addSubview(containerView)
		self.add(asChildViewController: tabController, container: containerView)
    addOverlayViewController(viewModel: PodcastViewModel())
		
		containerView.snp.makeConstraints { (make) -> Void in
			make.top.equalToSuperview()
			make.right.equalToSuperview()
			make.left.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}
}

extension RootViewController: OverlayControllerDelegate {

  func didSelectInfo(viewModel: PodcastViewModel) {
		guard let viewController = tabController.selectedViewController as? UINavigationController else { return }
    mainCoordinator?.viewController(viewController, with: viewModel)
		collapse()
	}
	
	func didTapCollapse() {
		collapse()
	}
  
  func didTapStop() {
    overlayContainerView.snp.remakeConstraints { (make) -> Void in
      make.height.equalTo(0)
      make.bottom.equalTo(tabController.tabBar.snp.top)
      make.right.equalToSuperview()
      make.left.equalToSuperview()
    }
    
    
    UIView.animate(withDuration: 0.1, animations: {
      self.view.layoutIfNeeded()
    }, completion: { _ in
      self.overlayContainerView.isHidden = true
    })
    
    stateController?.isOverlayShowing = false
    PlayProgressModelController.cleanRecentlyListenedEpisodeId()
  }
  
  func didTapPlay() {

    overlayContainerView.snp.remakeConstraints { (make) -> Void in
      make.height.equalTo(80)
      make.bottom.equalTo(tabController.tabBar.snp.top)
      make.right.equalToSuperview()
      make.left.equalToSuperview()
    }
    self.overlayContainerView.isHidden = false
    UIView.animate(withDuration: 0.1, animations: {
      self.view.layoutIfNeeded()
    }, completion: { _ in  })
    self.overlayController.expanded = false
    stateController?.isOverlayShowing = true
  }
}
