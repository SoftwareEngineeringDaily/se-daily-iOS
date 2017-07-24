//
//  AppDelegate.swift
//  SEDaily-IOS
//
//  Created by Craig Holliday on 6/25/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyBeaver
let log = SwiftyBeaver.self
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        migrateRealmDatabaseIfNeeded()
        setupSwiftyBeaver()
        setupIQKeyboard()
        setupFirstScreen()
        API.sharedInstance.createDefaultData()
        
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
        let rootVC = ContainerViewController()
        rootVC.view.backgroundColor = .white
//        let navVC = UINavigationController(rootViewController: rootVC)
//        navVC.view.backgroundColor = .white
//        navVC.navigationBar.isTranslucent = false
//        window!.rootViewController = navVC
        window!.rootViewController = rootVC
        window!.makeKeyAndVisible()
        
        let realm = try! Realm()
        log.info(realm.configuration.fileURL)
    }
    
    func migrateRealmDatabaseIfNeeded() {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true

        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
    }
}

