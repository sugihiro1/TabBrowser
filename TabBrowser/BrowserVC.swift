//
//  BrowserVc.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2017/11/06.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit

class BrowserVC: UIViewController, UISearchBarDelegate, WKNavigationDelegate, WKUIDelegate {
  
  private var webView: WKWebView!
  private var searchBar:UISearchBar!
  private var reloadBtn:UIBarButtonItem!
  private var stopBtn:UIBarButtonItem!
  private var progressView: UIProgressView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // WKWebViewを生成
    webView = WKWebView(frame:CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height - 40))
    
    // フリップで進む・戻るを許可
    webView.allowsBackForwardNavigationGestures = true
    
    // Googleを表示
    let urlString = "http://www.google.com"
    let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
    
    let url = NSURL(string: encodedUrlString!)
    let request = NSURLRequest(url: url! as URL)
    webView.load(request as URLRequest)
    
    // Viewに貼り付け
    self.view.addSubview(webView)
    

    // ツールバー
    let toolbar = UIToolbar(frame: CGRect(x:0, y:self.view.bounds.size.height - 44, width:self.view.bounds.size.width, height:40.0))
    toolbar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
    toolbar.barStyle = .default
    toolbar.tintColor = UIColor.white
    
    // 戻るボタン
    let backBtnView = UIButton(frame: CGRect(x:0, y:0, width:12, height:12))
    backBtnView.setBackgroundImage(UIImage(named: "back"), for: .normal)
    backBtnView.addTarget(self, action: #selector(onClickBackBarButton), for: .touchUpInside)
    let backBtn = UIBarButtonItem(customView: backBtnView)

    // 進むボタン
    let forwardBtnView = UIButton(frame: CGRect(x:0, y:0, width:12, height:12))
    forwardBtnView.setBackgroundImage(UIImage(named: "forward"), for: .normal)
    forwardBtnView.addTarget(self, action: #selector(onClickForwardBarButton), for: .touchUpInside)
    let forwardBtn = UIBarButtonItem(customView: forwardBtnView)
    
    // ブックマークボタン
    let bookmarkBtnView = UIButton(frame: CGRect(x:0, y:0, width:12, height:12))
    bookmarkBtnView.setBackgroundImage(UIImage(named: "bookmark"), for: .normal)
    bookmarkBtnView.addTarget(self, action: #selector(onClickBookmarkBarButton), for: .touchUpInside)
    let bookmarkBtn = UIBarButtonItem(customView: bookmarkBtnView)
    
    // ブックマークボタン長押しのジェスチャー
    let bookmarkLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressBookmark))
    bookmarkLongPressGesture.minimumPressDuration = 1.0// 長押し-最低1秒間は長押しする.
    bookmarkLongPressGesture.allowableMovement = 150// 長押し-指のズレは15pxまで.
    bookmarkBtnView.addGestureRecognizer(bookmarkLongPressGesture)
    
    // タブボタン
    let tabBtnView = UIButton(frame: CGRect(x:0, y:0, width:12, height:12))
    tabBtnView.setBackgroundImage(UIImage(named: "tab"), for: .normal)
    tabBtnView.addTarget(self, action: #selector(onClickTabBarButton), for: .touchUpInside)
    let tabBtn = UIBarButtonItem(customView: tabBtnView)
    
    // スペーサー
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    // ツールバーに追加する.
    toolbar.items = [backBtn, flexibleItem, forwardBtn, flexibleItem, bookmarkBtn, flexibleItem, tabBtn]
    self.view.addSubview(toolbar)

    
    // 検索バーを作成する.
    searchBar = UISearchBar(frame:CGRect(x:0, y:0, width:270, height:80))
    searchBar.delegate = self
    searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 20)
    searchBar.searchBarStyle = UISearchBarStyle.minimal
    searchBar.placeholder = "URLまたは検索ワード"
    searchBar.tintColor = UIColor.cyan
    // 余計なボタンは非表示にする.
    searchBar.showsSearchResultsButton = false
    searchBar.showsCancelButton = false
    searchBar.showsBookmarkButton = false
    
    // UINavigationBar上に、UISearchBarを追加
    self.navigationItem.titleView = searchBar
    
    // Reloadボタン
    let reloadBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    reloadBtnView.setBackgroundImage(UIImage(named: "reload"), for: .normal)
    reloadBtnView.addTarget(self, action: #selector(onClickReload), for: .touchUpInside)
    reloadBtn = UIBarButtonItem(customView: reloadBtnView)
    self.navigationItem.rightBarButtonItem = reloadBtn
    
    // Stopボタン
    let stopdBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    stopdBtnView.setBackgroundImage(UIImage(named: "stop"), for: .normal)
    stopdBtnView.addTarget(self, action: #selector(onClickStop), for: .touchUpInside)
    stopBtn = UIBarButtonItem(customView: stopdBtnView)
    
    // ProgressViewを作成する.
    progressView = UIProgressView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width * 2, height:20))
    progressView.progressTintColor = UIColor.green
    progressView.trackTintColor = UIColor.white
    progressView.layer.position = CGPoint(x:0, y:(self.navigationController?.navigationBar.frame.size.height)!)
    progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
    self.navigationItem.titleView?.addSubview(progressView)
    
    // WebViewの読み込み状態を監視する
    self.webView.addObserver(self, forKeyPath:"estimatedProgress", options:.new, context:nil)

  }
  
  @objc func onClickBackBarButton(sender: UIButton){
    // 前のページ
    self.webView.goBack()
  }
  @objc func onClickForwardBarButton(sender: UIButton){
    // 次のページ
    self.webView.goForward()
  }
  @objc func onClickBookmarkBarButton(sender: UIButton){
    // ブックマークリストを開く
  }
  @objc func longPressBookmark(sender: UILongPressGestureRecognizer){
    // 長押し：ブックマーク追加
  }
  @objc func onClickTabBarButton(sender: UIButton) {
    // タブ一覧
  }
  
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // ソフトウェアキーボードの検索ボタンが押された
    search(urlString: searchBar.text!)
    // キーボードを閉じる
    searchBar.resignFirstResponder()
  }
  
  func search( urlString:String)
  {
    var urlString = urlString
    if(urlString == ""){
      return;
    }
    
    var strUrl: String
    var searchWord:String = ""
    let chkURL = urlString.components(separatedBy: ".")
    if chkURL.count > 1 {
      // URLの場合
      if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
      } else {
        strUrl = "http://"
        strUrl = strUrl.appending(urlString)
      }
    } else {
      // 検索ワード
      urlString = urlString.replacingOccurrences(of: "?", with: " ")
      let words = urlString.components(separatedBy: " ")
      searchWord = words.joined(separator: "+")
      urlString = "https://www.google.co.jp/search?&q=\(searchWord)"
    }
    
    let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
    let url = NSURL(string: encodedUrlString!)
    let request = NSURLRequest(url: url! as URL)
    self.webView.load(request as URLRequest)
  }
  
  // MARK: - プログレスバーの更新(KVO)
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    if(keyPath == "estimatedProgress"){
      let progress : Float = Float(webView.estimatedProgress)
      if(progressView != nil){
        // プログレスバーの更新
        if(progress < 1.0){
          progressView.setProgress(progress, animated: true)
          UIApplication.shared.isNetworkActivityIndicatorVisible = true
          self.navigationItem.rightBarButtonItem = stopBtn
        }else{
          // 読み込み完了
          progressView.setProgress(0.0, animated: false)
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
          self.navigationItem.rightBarButtonItem = reloadBtn
          searchBar.text = webView.url?.absoluteString
        }
      }
    }
  }
  deinit {
    self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
    self.webView.navigationDelegate = nil
    self.webView!.uiDelegate = nil
  }
  
  @objc func onClickReload(sender : UIButton){
    // ページを再読み込み
    self.webView.reload()
  }
  
  @objc func onClickStop(sender : UIButton){
    // ページを読み込み中止
    self.webView.stopLoading()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
