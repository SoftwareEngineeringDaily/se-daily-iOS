//
//  ForumListViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 4/25/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class ForumListViewController: UIViewController {

    let networkService = API()


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 0)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        networkService.getForumThreads(onSuccess: {  [weak self] (threads) in
            print("count:")
            print(threads.count)
            print(threads)
        }) { (error) in
            print("error")
        }
        
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
