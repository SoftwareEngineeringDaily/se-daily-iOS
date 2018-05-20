//
//  RelatedLInkWebVC.swift
//  SEDaily-IOS
//
//  Created by jason on 5/18/18.
//  Copyright © 2018 Koala Tea. All rights reserved.
//

import UIKit
import WebKit

class RelatedLInkWebVC: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    var currentSpinner: UIView?

    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        webView.navigationDelegate = self
        print("loading")
        currentSpinner = self.displaySpinner(onView: self.view)
    }
    var url:URL? {
        didSet {
            
        }
    }
    
    func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentSpinner = currentSpinner {
            removeSpinner(spinner: currentSpinner)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            print(url)
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
