//
//  ContainerViewController.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 7/19/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    private var containerView = UIView()
    private var navController = UINavigationController()
    private var customTabViewController: CustomTabViewController?
    private var audioOverlayViewController: AudioOverlayViewController?

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

    private func setupView() {
        self.customTabViewController = CustomTabViewController(audioOverlayDelegate: self)
        self.view.addSubview(containerView)
        self.audioOverlayViewController = AudioOverlayViewController(audioOverlayDelegate: self)
        self.addChildViewController(self.audioOverlayViewController!)
        self.audioOverlayViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.audioOverlayViewController!.view)

        containerView.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        containerView.backgroundColor = Stylesheet.Colors.white

        self.audioOverlayViewController?.view.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(
                UIView.getValueScaledByScreenHeightFor(
                    baseValue: AudioOverlayViewController.audioControlsViewHeight))
            make.top.equalToSuperview().offset(UIScreen.main.bounds.height)
        }

        let navVC = UINavigationController(rootViewController: customTabViewController!)
        navVC.view.backgroundColor = .white

        self.navController = navVC
    }

    func setContainerViewInset() {
        self.containerView.snp.updateConstraints { (make) -> Void in
            make.bottom.equalToSuperview().inset(
                UIView.getValueScaledByScreenHeightFor(
                    baseValue: AudioOverlayViewController.audioControlsViewHeight))
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
        return .default
    }
}

extension ContainerViewController: AudioOverlayDelegate {
    func animateOverlayIn() {
        self.setContainerViewInset()
        self.audioOverlayViewController?.animateIn()
    }

    func animateOverlayOut() {
        self.audioOverlayViewController?.animateOut()
        self.removeContainerViewInset()
    }

    func playAudio(podcastViewModel: PodcastViewModel) {
        self.audioOverlayViewController?.playAudio(podcastViewModel: podcastViewModel)
    }

    func pauseAudio() {
        self.audioOverlayViewController?.pauseAudio()
    }
	
	func stopAudio() {
		self.audioOverlayViewController?.stopAudio()
	}

    func setCurrentShowingDetailView(podcastViewModel: PodcastViewModel?) {
        self.audioOverlayViewController?.setCurrentShowingDetailView(
            podcastViewModel: podcastViewModel)
    }
	
	func setServices(upvoteService: UpvoteService, bookmarkService: BookmarkService) {
		self.audioOverlayViewController?.setServices(upvoteService: upvoteService, bookmarkService: bookmarkService)
	}
	
}
