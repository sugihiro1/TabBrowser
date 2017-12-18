//
//  BrowserVc.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2017/11/06.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit
import Kanna
import SwiftyDropbox
import SVProgressHUD

@objc protocol BrowserVcDelegate {
  // デリゲートメソッド定義
  func saveTab(wkWebView:UIWebView)
}



class BrowserVC: UIViewController, UISearchBarDelegate, WKNavigationDelegate, WKUIDelegate {
 
  private var webView: UIWebView!
  private var searchBar:UISearchBar!
  private var reloadBtn:UIBarButtonItem!
  private var stopBtn:UIBarButtonItem!
  private var progressView: UIProgressView!
  
  var timer = Timer()
  var progress: Float = 0.5
  var searchFihished: Bool = false
  
  
  weak var delegate: AnyObject?
  
  init(delegate: AnyObject?, wKWebView:UIWebView!,url:String!) {
    super.init(nibName: nil, bundle: nil)
    self.delegate = delegate
    self.webView = wKWebView
    // ナビゲーションの戻るを非表示
    self.navigationItem.setHidesBackButton(true, animated:false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  required override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    
    // ステータスバーの高さを取得
    let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    // ナビゲーションバーの高さを取得
    let navBarHeight = self.navigationController?.navigationBar.frame.size.height
    
    // ツールバー
    let toolbar = UIToolbar(frame: CGRect(x:0, y:self.view.bounds.size.height - 44, width:self.view.bounds.size.width, height:40.0))
    toolbar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
    toolbar.barStyle = .default
    toolbar.tintColor = UIColor.white
    
    // 戻るボタン
    let backBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    backBtnView.setBackgroundImage(UIImage(named: "back"), for: .normal)
    backBtnView.addTarget(self, action: #selector(onClickBackBarButton), for: .touchUpInside)
    let backBtn = UIBarButtonItem(customView: backBtnView)
    
    // 進むボタン
    let forwardBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    forwardBtnView.setBackgroundImage(UIImage(named: "forward"), for: .normal)
    forwardBtnView.addTarget(self, action: #selector(onClickForwardBarButton), for: .touchUpInside)
    let forwardBtn = UIBarButtonItem(customView: forwardBtnView)
    
    // ブックマークボタン
    let bookmarkBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    bookmarkBtnView.setBackgroundImage(UIImage(named: "bookmark"), for: .normal)
    bookmarkBtnView.addTarget(self, action: #selector(onClickBookmarkBarButton), for: .touchUpInside)
    let bookmarkBtn = UIBarButtonItem(customView: bookmarkBtnView)
    
    // ブックマークボタン長押しのジェスチャー
    let bookmarkLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressBookmark))
    bookmarkLongPressGesture.minimumPressDuration = 1.0// 長押し-最低1秒間は長押しする.
    bookmarkLongPressGesture.allowableMovement = 150// 長押し-指のズレは15pxまで.
    bookmarkBtnView.addGestureRecognizer(bookmarkLongPressGesture)
    
    // タブボタン
    let tabBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
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
    searchBar.placeholder = "検索ワード"
    searchBar.tintColor = UIColor.cyan
    // 余計なボタンは非表示にする.
    searchBar.showsSearchResultsButton = false
    searchBar.showsCancelButton = false
    searchBar.showsBookmarkButton = false
    
    // UINavigationBar上に、UISearchBarを追加
    self.navigationItem.titleView = searchBar
    
    // 検索ボタン
    let reloadBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    reloadBtnView.setTitle("検索", for: .normal)
    reloadBtnView.setTitleColor(UIColor.blue, for: .normal)
    reloadBtnView.addTarget(self, action: #selector(onClickSearchButton), for: .touchUpInside)
    reloadBtn = UIBarButtonItem(customView: reloadBtnView)
    self.navigationItem.rightBarButtonItem = reloadBtn
    
    // ProgressViewを作成する.
    progressView = UIProgressView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width * 2, height:20))
    progressView.progressTintColor = UIColor.green
    progressView.trackTintColor = UIColor.white
    progressView.layer.position = CGPoint(x:0, y:(self.navigationController?.navigationBar.frame.size.height)!)
    progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
    self.navigationItem.titleView?.addSubview(progressView)
    
    if(self.webView == nil){
      // 新規UIWebViewを生成
      webView = UIWebView(frame:CGRect(x:0, y:statusBarHeight+navBarHeight!, width:self.view.bounds.size.width, height:self.view.bounds.size.height-(statusBarHeight+navBarHeight!+40)))
      showLocalHtml("wordsmenu2Iphone.htm")
    }
    
    // Viewに貼り付け
    self.webView.scalesPageToFit = true
    self.view.addSubview(webView)

/*   // WebViewの読み込み状態を監視する
    self.webView.addObserver(self, forKeyPath:"estimatedProgress", options:.new, context:nil)
*/
  }
  
  // ローカルHtmlファイルのweb表示プロシージャ
  func showLocalHtml(_ url: String) {
    // Documentファルダにあるmenuファイルのフルパスを取得
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let menuURL = documentURL.appendingPathComponent(url)
    let path = menuURL.path   // String型の Document path
    let url = NSURL(fileURLWithPath: path)
    let urlRequest = NSURLRequest(url: url as URL)
    self.webView.loadRequest(urlRequest as URLRequest)
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
/*    if webView.canGoBack == true {
      self.webView.goBack()
    }
    while webView.canGoBack == true {
      print(webView.canGoBack)
      self.webView.goBack()
    } */
    
    showLocalHtml("wordsmenu2Iphone.htm")
  }
  
  @objc func longPressBookmark(sender: UILongPressGestureRecognizer){
    // 長押し：ブックマーク追加
  }
  
  // ツールバーのタブボタンをタップした時にTabVcに戻る処理
  @objc func onClickTabBarButton(sender: UIButton) {
    tabDataList[myTabIndexPathRow].webView = self.webView
    saveTabImageExec()
    // すぐ実行すると真っ白な画像が撮れる為 少し間を空けてサムネイル画像を保存
    Thread.sleep(forTimeInterval: 0.7)
    navigationController?.popToViewController(navigationController!.viewControllers[0], animated: false)
  }
  
  // タブのタイトルとイメージを保存
  func saveTabImageExec(){
    let webView = tabDataList[myTabIndexPathRow].webView
    let title = webView!.stringByEvaluatingJavaScript(from: "document.title")
    tabDataList[myTabIndexPathRow].title = title
    
    UIGraphicsBeginImageContextWithOptions(webView!.bounds.size, true, 0);
    webView!.drawHierarchy(in:webView!.bounds, afterScreenUpdates: false);
    let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    tabDataList[myTabIndexPathRow].image = snapshotImage
  }

  @objc func onClickReload(sender : UIButton){
    // ページを再読み込み
    self.webView.reload()
  }
  
  @objc func onClickStop(sender : UIButton){
    // ページを読み込み中止
    self.webView.stopLoading()
  }
  
  @objc func setProgressBar() {
    if progress >= 1 {
      self.timer.invalidate()
      self.progress = 0.5
      progressView.setProgress(progress, animated: false)
      return
    }

    if searchFihished == true {
      progress += 0.01
//      print("progress \(progress)")
      self.progressView.setProgress(1.0, animated: true)
    }
    else {
      progress += 0.001
//      print("progress \(progress)")
      progressView.setProgress(progress, animated: false)
    }
  }
  
  
  @objc func onClickSearchButton () {
    
    // キーボードを閉じる
    searchBar.resignFirstResponder()
    
    // 検索語を設定
    let searchWord: String = searchBar.text!
    
    print(searchWord.count)
    if searchWord.count == 0 {
      print("検索語が入力されていません")
      return
    }

    var searchResult: String = ""
    searchFihished = false

    // 検索結果出力ファイルのHTML文のheader部分
    let searchHeader: String? = "<html><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"><body bgcolor=\"white\" text=\"black\" link=\"blue\" vlink=\"purple\" alink=\"red\"><table style=\"border-color:purple;\" border=\"1\" width=\"900\" cellpadding=\"2\" cellspacing=\"0\">"
    
    timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(setProgressBar), userInfo: nil, repeats: true)
    
    let queue = DispatchQueue(label: "queue")
    
    queue.async{
      searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/htm1/", type: "<tr>")
    }
    queue.async{
      searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/htm2/", type: "<tr>")
    }
    queue.async{
      searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/TuVung/", type: "<p>")
    }
    queue.async{
      searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/BaiNghe/", type: "<p>")
    }

    queue.async{
      // 検索結果のhtmlを書き出す
      let searchResultHtml = searchHeader! + searchResult + "</table></html>"
      let resultFileName = "searchResult.html"
      
      // DocumentディレクトリURLを取得し、htmlFileNameを書き出す
      if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        
        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        let targetFilePath = documentDirectoryFileURL.appendingPathComponent(resultFileName)
        
        // 書き込み
        do {
          try searchResultHtml.write(to: targetFilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
          print("書き込みエラーが発生しました: \(error)")
          return
        }
      }
    }
    
    queue.async{
      self.showLocalHtml("searchResult.html")
      self.searchFihished = true
    }

  }
  
  // 検索の実行
  func searchWordAction(_ searchWord: String, subDir: String, type: String) -> String {
    
 //    SVProgressHUD.show()
    
    // 単語htmlファイルがあるDocumentディレクトリーのパスを取得
    let currentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    // ディレクトリ内の単語htmlファイルをリストアップし、wordFiles[]配列に収納
    var wordFiles: [String] {
      do {
        return try FileManager.default.contentsOfDirectory(atPath: currentDir + subDir)
        //        return try FileManager.default.contentsOfDirectory(atPath: currentDir + "/htm1/")
      } catch {
        return []
      }
    }
    
    var searchResult: String = ""
    var textData: String? // 単語hmtlファイルのテキストデータ
    var trText: String? // <tr>...</tr>タグに挟まれたデータ
    var divText: String? // <div>...</tr>タグに挟まれたデータ
    
    // 単語htmlファイルがあるDocumentディレクトリーのパスを取得
    let dirDocument = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first
    
    // 配列内のhtmlファイルを順次処理する
    for i in 0 ..< wordFiles.count {
      
      // htmlファイルを順次テキストデータとして読み込む
      let pathFileName = dirDocument!.appendingPathComponent(subDir + wordFiles[i] )
//      print("pathFileName \(pathFileName)")
      do {
        textData = try String(contentsOf: pathFileName, encoding: String.Encoding.utf8 )
      } catch {
      }
      
      if let doc = try? HTML(html: textData!, encoding: .utf8) {
        
        if type == "<tr>" {
          let body = doc.css("body").first!.toHTML
          
          // htmlファイルが検索語を含むかどうか判定
          if let range = body!.range(of: searchWord){ // -> true
            
            // 検索語を含むファイルの処理
            // <tr>タグごとに検索語をチェック、含んで入ればその<tr>タグのouterHTMLをtargetHtmlに追記する
            for node in doc.css("tr") {
              trText = node.toHTML!
              if let range = trText?.range(of: searchWord) {
                trText = trText?.replacingOccurrences(of: searchWord, with: "<span style=\"background-color:yellow;\">" + searchWord + "</span>")
                searchResult = searchResult + trText!
              } else {
              }
            }
          }else{
          }
          
        } else if type == "<p>" {
          for node in doc.css("p") {
            divText = node.toHTML!
            if let range = divText?.range(of: searchWord) {
              divText = divText?.replacingOccurrences(of: searchWord, with: "<span style=\"background-color:yellow;\">" + searchWord + "</span>")
              searchResult = searchResult + "<tr><td colspan=\"4\">" + divText! + "</td></tr>"
            } else {
            }
          }
          
        }
      }
    }
    
 //   SVProgressHUD.dismiss()
    
    print("\(subDir) searched")
    return searchResult
    
  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}


