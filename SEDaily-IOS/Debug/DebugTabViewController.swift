//
//  DebugTabViewController.swift
//  SEDaily-IOS
//
//  Created by Justin Lam on 10/6/17.
//  Copyright © 2017 Koala Tea. All rights reserved.
//

import UIKit

protocol TestHookTableViewCell {
    func configure(testHook: TestHook)
}

class DebugTabViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tabBarItem = UITabBarItem(title: "Debug", image: nil, selectedImage: nil)
        self.tabBarItem.setIcon(icon: .fontAwesome(.bug))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        let useStagingEndpoint = TestHookBool(
            id: .useStagingEndpoint,
            name: "Use Staging Endpoint")
        useStagingEndpoint.defaultValue = false
        TestHookManager.add(testHook: useStagingEndpoint)

        let clearAlreadyLoadedToday = TestHookEvent(
            id: .clearAlreadyLoadedToday,
            name: "Clear Already Loaded Today")
        clearAlreadyLoadedToday.execute = {
            PodcastRepository.clearLoadedToday()
        }
        TestHookManager.add(testHook: clearAlreadyLoadedToday)

        let viewDiskTestHook = TestHookEvent(
            id: .viewDisk,
            name: "View Disk")
        viewDiskTestHook.execute = {
            PodcastDataSource.getAll(diskKey: .PodcastFolder, completion: { (podcast) in
                print(podcast ?? "")
            })
        }
        TestHookManager.add(testHook: viewDiskTestHook)
    }
}

extension DebugTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TestHookManager.testHooksArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let testHook = TestHookManager.testHooksArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: testHook.reuseId, for: indexPath)
        cell.selectionStyle = .none
        if let testHookTableViewCell = cell as? TestHookTableViewCell {
            testHookTableViewCell.configure(testHook: testHook)
            return cell
        }
        fatalError("No supported table view cell")
    }
}
