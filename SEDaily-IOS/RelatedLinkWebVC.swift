//
//  RelatedLinkWebVC.swift
//  SEDaily-IOS
//
//  Created by jason on 5/20/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit




//
//  RelatedLInkWebVC.swift
//  SEDaily-IOS
//
//  Created by jason on 5/18/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import WebKit

class RelatedLinkWebVC: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    var url:URL?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
        self.view = webView
    }
    
    
    @IBAction func openInSafariTapped(_ sender: UIButton) {
        if let linkUrl = url {
            UIApplication.shared.open(linkUrl, options: [:], completionHandler: nil)
        } else {
            print("link null")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
      
        if let url = url {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.uiDelegate = self
            
            webView.navigationDelegate = self
            webView.isHidden = true
            
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
        }
 
        // Do any additional setup after loading the view.
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
