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
    var currentSpinner: UIView?
    var url:URL?
    
    func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("done loading")
        webView.isHidden = false
        if let currentSpinner = currentSpinner {
            removeSpinner(spinner: currentSpinner)
        }
        self.view = webView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
      
        if let url = url {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.uiDelegate = self
            
            webView.navigationDelegate = self
            webView.isHidden = true
            currentSpinner = self.displaySpinner(onView: self.view)
            
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
