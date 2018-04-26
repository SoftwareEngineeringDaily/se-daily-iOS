//
//  ForumListViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 4/25/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class ForumListViewController: UIViewController {

    
//    override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        print("----------loading")
//        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        self.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
//        print("loaded tabbar")
//
//    }
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        self.init(nibName: nibNameOrNil, bundle: )
//        self.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
//    }
//

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 0)

    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func clickedMe(_ sender: UIButton) {
        print("clicked me")
        dismiss(animated: true) {
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
