//
//  ViewController.swift
//  Vietnam2
//
//  Created by 杉山尋美 on 2017/09/28.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit
import SwiftyDropbox
import SVProgressHUD

class ViewController: UIViewController, WKUIDelegate, UIWebViewDelegate {
  
  @IBOutlet weak var BackButton: UIBarButtonItem!
  
  var webView: UIWebView = UIWebView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.webView.delegate = self
    self.webView.scalesPageToFit = true
    
    self.webView.frame = self.view.bounds
    self.view.addSubview(self.webView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  // SearchWord クラスからBackボタンで戻って来た時再描画
  override func viewDidAppear(_ animated: Bool) {
    showLocalHtml()
  }
  
  
  // ローカルHtmlファイルのweb表示プロシージャ
  func showLocalHtml() {
    
    // Documentファルダにあるmenuファイルのフルパスを取得
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let menuURL = documentURL.appendingPathComponent("wordsmenu2Iphone.htm")
    
    let path = menuURL.path   // String型の Document path
    let url = NSURL(fileURLWithPath: path)
    let urlRequest = NSURLRequest(url: url as URL)
    self.webView.loadRequest(urlRequest as URLRequest)
    
  }
  
  // HTMLで遷移した時の「戻る」ボタン状態と色
  func webViewDidFinishLoad(_ webView: UIWebView) {
    if webView.canGoBack {
      BackButton.isEnabled = true
    } else {
      BackButton.isEnabled = false
    }
  }
  
  // HTMLで遷移した時の「戻る」操作
  @IBAction func Return(_ sender: Any) {
    self.webView.goBack()
  }
  
  
}




