//
//  WebViewController.swift
//  NYTTopStories
//
//  Created by Mark Zhong on 9/13/17.
//  Copyright © 2017 Mark Zhong. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var url: String?
    let waitingView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.width*0.5-20,y: UIScreen.main.bounds.size.height*0.5-40, width: 40, height: 40), type:.ballSpinFadeLoader, color:UIColor.purple)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        webView.delegate = self
        webView.loadRequest(URLRequest(url: URL(string: url!)!))
        waitingView.startAnimating()
        self.view.addSubview(waitingView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.waitingView.stopAnimating()
    }
    
    
    
}
