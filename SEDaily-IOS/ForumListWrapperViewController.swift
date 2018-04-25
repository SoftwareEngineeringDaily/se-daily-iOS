//
//  ForumListWrapperViewController.swift
//  SEDaily-IOS
//
//  Created by jason on 4/25/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit

class ForumListWrapperViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        

        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let commentsStoryboard = UIStoryboard.init(name: "Comments", bundle: nil)
        guard let commentsViewController = commentsStoryboard.instantiateViewController(
            withIdentifier: "CommentsViewController") as? CommentsViewController else {
                return
        }
        
        commentsViewController.rootEntityId = "5ada3725f32a0060919b1089"
        self.navigationController?.pushViewController(commentsViewController, animated: true)
        
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
