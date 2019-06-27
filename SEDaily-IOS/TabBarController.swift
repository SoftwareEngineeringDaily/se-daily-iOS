//
//  TabBarController.swift
//  ExpandableOverlay
//
//  Created by Dawid Cedrych on 6/18/19.
//  Copyright © 2019 Altalogy. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//let firstNavController = UINavigationController(rootViewController: FirstViewController())
		//let secondNavController = UINavigationController(rootViewController: SecondViewController())
		//self.viewControllers = [firstNavController, secondNavController]
		self.tabBar.isTranslucent = false
	}
	
}
