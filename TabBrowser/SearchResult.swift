//
//  SearchResult.swift
//  Vietnam2
//
//  Created by 杉山尋美 on 2017/10/01.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit


class SearchResult: UIViewController, WKUIDelegate {
  
  var webView: WKWebView!
  
  override func loadView() {
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.uiDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let fileName = "searchResult.html"
    let dirDocument = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let htmlFile = dirDocument + "/" + fileName
    
    //    以下では、シミュレータには表示されるが、実機には表示されない
    //    let htmlRequest = URLRequest(url: URL(fileURLWithPath: htmlFile))
    //    webView.load(htmlRequest)
    
    // 実機にも表示されるためには、以下のようにする必要あり。
    let htmlFileURL = URL(fileURLWithPath: htmlFile)
    webView.loadFileURL(htmlFileURL, allowingReadAccessTo:htmlFileURL)
    
/*
    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
      let pathFileNname = dir.appendingPathComponent(fileName)
      do {
        let text = try String( contentsOf: pathFileNname, encoding: String.Encoding.utf8 )
        //        print("Printing searchResult.html")
        //        print(text)
      } catch {
        print("ファイルが見つかりません")
      }
    }
*/
    
  }
 
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
