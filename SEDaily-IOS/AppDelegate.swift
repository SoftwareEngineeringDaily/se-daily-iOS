//
//  AppDelegate.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/25/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import SwiftyBeaver
let log = SwiftyBeaver.self
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
import Kingfisher
//import Stripe
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	var coordinator: MainFlowCoordinator?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		//        STPPaymentConfiguration.shared().publishableKey = "pk_live_Cfttsv5i5ZG5IBfrmllzNoSA"
		
		Fabric.with([Crashlytics.self])
		setupSwiftyBeaver()
		setupIQKeyboard()
		setupFirstScreen()
		
		// Max size for Kingfisher ImageCache
		let maxByteSize: UInt = 50 * 1024 * 1024
		ImageCache.default.maxDiskCacheSize = maxByteSize
		ImageCache.default.maxMemoryCost = maxByteSize
		
		#if DEBUG
		print("FIREBASE OFF, DEBUG / DEV MODE-------")
		#else
		FirebaseApp.configure()
		#endif
		
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
}

extension AppDelegate {
	// MARK: Setup
	func setupSwiftyBeaver() {
		// Setup swifty beaver
		let console = ConsoleDestination()
		log.addDestination(console) // add to SwiftyBeaver
	}
	
	func setupIQKeyboard() {
		IQKeyboardManager.sharedManager().enable = true
	}
	
	func setupFirstScreen() {
		window = UIWindow(frame: UIScreen.main.bounds)
		let rootVC = RootViewController()
		window!.rootViewController = rootVC
		window!.makeKeyAndVisible()

		// Override point for customization after application launch.
		if let initialViewController = window!.rootViewController as? RootViewController {
			coordinator = MainFlowCoordinator(mainViewController: initialViewController)

		}
	}
}
