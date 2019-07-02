//
//  MainFlowCoordinator.swift
//  SEDaily-IOS
//
//  Created by Dawid Cedrych on 6/26/19.
//  Copyright © 2019 Koala Tea. All rights reserved.
//

import Foundation

import Foundation
import UIKit

protocol Coordinator: AnyObject {
	func configure(viewController: UIViewController)
}

protocol MainCoordinated: AnyObject {
	var mainCoordinator: MainFlowCoordinator? { get set }
}

protocol AudioControllable: AnyObject {
	var audioControlDelegate: EpisodeViewDelegate? { get set }
}

protocol Stateful: AnyObject {
	var stateController: StateController? { get set }
}


class MainFlowCoordinator: NSObject {
	let stateController = StateController()
	let rootViewController: RootViewController
	
	
	init(mainViewController: RootViewController) {
		self.rootViewController = mainViewController
		super.init()
		configure(viewController: mainViewController)
	}
	
	//Here you will pass viewModel as parameter, "info" String now for the exemplary purpose
	func viewController(_ viewController: UINavigationController, with viewModel: PodcastViewModel) {
		if let vc = viewController.visibleViewController as? EpisodeViewController { // a mechanism to prevent pushing the same view controllers
			if vc.viewModel == viewModel {
				return
			}
		}
		let vc = EpisodeViewController()
		vc.viewModel = viewModel
    configure(viewController: vc)
		viewController.pushViewController(vc, animated: true)
	}
}

extension MainFlowCoordinator: Coordinator {
	func configure(viewController: UIViewController) {
		(viewController as? MainCoordinated)?.mainCoordinator = self
		(viewController as? Stateful)?.stateController = stateController
		(viewController as? AudioControllable)?.audioControlDelegate = rootViewController.overlayController
		if let rootController = viewController as? RootViewController {
			rootController.childViewControllers.forEach(configure(viewController:))
		}
		if let tabBarController = viewController as? UITabBarController {
			tabBarController.viewControllers?.forEach(configure(viewController:))
		}
		if let navigationController = viewController as? UINavigationController,
			let rootViewController = navigationController.viewControllers.first {
			configure(viewController: rootViewController)
		}
	}
}
