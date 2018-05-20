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

    override func loadView() {
        super.loadView()
        print("Start loading")
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
        webView.navigationDelegate = self
        print("loading")
    }
    var url:URL? {
        didSet {
            
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Done loading")
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
