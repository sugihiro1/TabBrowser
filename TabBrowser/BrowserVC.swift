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
import SlideMenuControllerSwift

/*
@objc protocol BrowserVcDelegate {
  // デリゲートメソッド定義
  func saveTab(wkWebView:UIWebView)
}
*/

var browserVC: UIViewController?

class BrowserVC: UIViewController, UISearchBarDelegate, WKNavigationDelegate, WKUIDelegate, FontResizeDelegate {

// class BrowserVC: UIViewController, UISearchBarDelegate, WKNavigationDelegate, WKUIDelegate {

  private var webView: UIWebView!
  private var searchBar:UISearchBar!
  private var searchBtn:UIBarButtonItem!
  private var leftMenuBtn:UIBarButtonItem!
  private var rightMenuBtn:UIBarButtonItem!
  private var stopBtn:UIBarButtonItem!
  private var progressView: UIProgressView!
  
  var searchFileName: String = ""
  var anchorHTML: String = ""
  var jump: String = ""
  var zoom: String = ""

  var timer = Timer()
  var progress: Float = 0.5
  var searchFihished: Bool = false
  
  weak var delegate: AnyObject?

  init(delegate: AnyObject?, wKWebView:UIWebView!, url:String!) {
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

  // userDefaultsインスタンス生成
  let userDefaults2 = UserDefaults.standard

  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    // userDefaults読み込み
    if let aaa = userDefaults2.integer(forKey: "sw2") as Optional{
      segment1index = aaa
    }
    /* navigationバー　設定*/
    // file検索バーを作成
    searchBar = UISearchBar(frame:CGRect(x:0, y:0, width:270, height:80))
    searchBar.delegate = self
    searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: 10)
    searchBar.searchBarStyle = UISearchBarStyle.minimal
    searchBar.placeholder = "検索ワード"
    searchBar.tintColor = UIColor.cyan
    // 余計なボタンは非表示にする.
    searchBar.showsSearchResultsButton = false
    searchBar.showsCancelButton = false
    searchBar.showsBookmarkButton = false
    // UINavigationBar上に、UISearchBarを追加
    self.navigationItem.titleView = searchBar
    
/*    // 検索ボタンを作成
    let searchBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    searchBtnView.setTitle("検索", for: .normal)
    searchBtnView.setTitleColor(UIColor.blue, for: .normal)
    searchBtnView.addTarget(self, action: #selector(onClickSearchButton), for: .touchUpInside)
    searchBtn = UIBarButtonItem(customView: searchBtnView)
    self.navigationItem.rightBarButtonItem = searchBtn
*/
    // 右メニュー（セットアップ）ボタンを作成
    let rightMenuBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    rightMenuBtnView.setImage(UIImage(named: "menu2"), for: .normal)
    rightMenuBtnView.setTitleColor(UIColor.blue, for: .normal)
    rightMenuBtnView.addTarget(self, action: #selector(onClickSetUpBarButton), for: .touchUpInside)
    rightMenuBtn = UIBarButtonItem(customView: rightMenuBtnView)
    self.navigationItem.rightBarButtonItem = rightMenuBtn

    // 左メニューボタンを作成
    let leftMenuBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:24))
    leftMenuBtnView.setTitle("＜", for: .normal)
    leftMenuBtnView.setTitleColor(UIColor.blue, for: .normal)
    leftMenuBtnView.addTarget(self, action: #selector(onClickLeftMenuBarButton), for: .touchUpInside)
    leftMenuBtn = UIBarButtonItem(customView: leftMenuBtnView)
    self.navigationItem.leftBarButtonItem = leftMenuBtn
    
    /* ツールバー 設定*/
    let toolbar = UIToolbar(frame: CGRect(x:0, y:self.view.bounds.size.height - 44, width:self.view.bounds.size.width, height:40.0))
    toolbar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
//    toolbar.barStyle = .default
//    toolbar.barTintColor = UIColor.white
//    toolbar.barTintColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0
    toolbar.barTintColor = UIColor(white: 1.0, alpha: 0.0)

    // 戻るボタンを作成
    let backBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    backBtnView.setBackgroundImage(UIImage(named: "back3"), for: .normal)
    backBtnView.addTarget(self, action: #selector(onClickBackBarButton), for: .touchUpInside)
    let backBtn = UIBarButtonItem(customView: backBtnView)
    
    // 進むボタンを作成
    let forwardBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    forwardBtnView.setBackgroundImage(UIImage(named: "forward3"), for: .normal)
    forwardBtnView.addTarget(self, action: #selector(onClickForwardBarButton), for: .touchUpInside)
    let forwardBtn = UIBarButtonItem(customView: forwardBtnView)
    
    // ホームボタンを作成
    let homeBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    homeBtnView.setBackgroundImage(UIImage(named: "home"), for: .normal)
    homeBtnView.addTarget(self, action: #selector(onClickHomeBarButton), for: .touchUpInside)
    let homeBtn = UIBarButtonItem(customView: homeBtnView)
    
    // ホームボタン長押しのジェスチャー
    let homeLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHomeBarBtn))
    homeLongPressGesture.minimumPressDuration = 1.0// 長押し-最低1秒間は長押しする.
    homeLongPressGesture.allowableMovement = 150// 長押し-指のズレは15pxまで.
    homeBtnView.addGestureRecognizer(homeLongPressGesture)
    
    // タブボタンを作成
    let tabBtnView = UIButton(frame: CGRect(x:0, y:0, width:10, height:18))
    tabBtnView.setBackgroundImage(UIImage(named: "tab3"), for: .normal)
    tabBtnView.addTarget(self, action: #selector(onClickTabBarButton), for: .touchUpInside)
    let tabBtn = UIBarButtonItem(customView: tabBtnView)
    
    /*
    // メニューボタン
    let menuBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    menuBtnView.setBackgroundImage(UIImage(named: "menu"), for: .normal)
    menuBtnView.addTarget(self, action: #selector(onClickSearchMenuBarButton), for: .touchUpInside)
    let menuBtn = UIBarButtonItem(customView: menuBtnView)
    */
    
    // スペーサーを作成
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    // ツールバーに追加する.
    toolbar.items = [backBtn, flexibleItem, forwardBtn, flexibleItem, homeBtn, flexibleItem, tabBtn]
    self.view.addSubview(toolbar)
    
    /* WebViewを作成 */
    // ナビゲーションバー、ステータスバーの高さを取得
    let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    let navBarHeight = self.navigationController?.navigationBar.frame.size.height

    if(self.webView == nil){
      // 新規UIWebViewを生成
//      webView = UIWebView(frame:CGRect(x:0, y:statusBarHeight+navBarHeight!, width:self.view.bounds.size.width, height:self.view.bounds.size.height-(statusBarHeight+navBarHeight!+40)))
 
      webView = UIWebView(frame:CGRect(x:0, y:statusBarHeight, width:self.view.bounds.size.width, height:self.view.bounds.size.height-(statusBarHeight+40)))
      
      showLocalHtml("wordsmenu2Iphone.htm")
    }
    self.webView.scalesPageToFit = true
    self.view.addSubview(webView)
    
    // WebViewの読み込み状態を監視する
    // self.webView.addObserver(self, forKeyPath:"estimatedProgress", options:.new, context:nil)

  }
  
  // ローカルHtmlファイルのweb表示
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

  /* 下部ツールバー上の各ボタンがクリックされた時のプロシージャ */
  @objc func onClickBackBarButton(sender: UIButton){
    // 前のページ
    self.webView.goBack()
  }
  @objc func onClickForwardBarButton(sender: UIButton){
    // 次のページ
    self.webView.goForward()
  }
  
  @objc func onClickHomeBarButton(sender: UIButton){
    // ホーム画面へ戻る
    if self.webView.scalesPageToFit == false {
      self.webView.scalesPageToFit = true
    }
    showLocalHtml("wordsmenu2Iphone.htm")
  }
 
  /*
  @objc func onClickSearchMenuBarButton (sender: UIButton){
    // 検索画面へ遷移
    let storyboard = UIStoryboard(name: "Search", bundle: nil)
    let searchViewController = storyboard.instantiateViewController(withIdentifier: "Search")
    self.present(searchViewController,animated: false, completion: nil)
  }
  */
  
  // ホームボタン長押しされた時のプロシージャ
  @objc func longPressHomeBarBtn(sender: UILongPressGestureRecognizer){
    fontResize()
  }
  
  func fontResize () {
    zoom = segment1value[segment1index]
    anchorHTML = "<html><head><meta charset=utf-8\"></head><body onload=location.href=\"htm2/" + searchFileName + "?jump=" + jump + "&zoom=" + zoom + "\"></body></html>"
    // WebViewに表示
    showFileSearchResult()
  }
  
  // タブボタンがクリックされた時のプロシージャ
  @objc func onClickTabBarButton(sender: UIButton) {
    // TabVcに移る
    tabDataList[myTabIndexPathRow].webView = self.webView
    saveTabImageExec()
    // すぐ実行すると真っ白な画像が撮れる為 少し間を空けてサムネイル画像を保存
    Thread.sleep(forTimeInterval: 0.3)
    navigationController?.popToViewController(navigationController!.viewControllers[0], animated: false)
    
//    self.present(viewController!, animated: false, completion: nil)
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

  /* Navigationバー上の各ボタンクリック時のプロシージャ */
  /* 上部ツールバー上の各ボタンクリック時のプロシージャ */
  
  // 左メニューボタン クリック
  @objc func onClickLeftMenuBarButton(sender: UIButton){
    //    self.slideMenuController()?.openLeft()
  }
  
  // 右メニュー（セットアップ）ボタン クリック
  @objc func onClickSetUpBarButton (sender: UIButton){
    // SetUpController をモーダル表示する
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let setUpController = storyboard.instantiateViewController(withIdentifier: "SetUp")
    setUpController.modalPresentationStyle = .custom
    setUpController.transitioningDelegate = self as? UIViewControllerTransitioningDelegate
    present(setUpController, animated: true, completion: nil)
  }

  // File検索ボタン クリック
  @objc func onClickSearchButton () {
    // キーボードを閉じる
    searchBar.resignFirstResponder()
    performFileSearch()
    
  }

  //キーボードの検索キーボタン押下
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    performFileSearch()
  }
  
  func performFileSearch() {
    // Documentディレクトリの対象フォルダ内のファイルをlocalFileListに収容
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var localFileList: [String] {
      do {
        return try FileManager.default.contentsOfDirectory(atPath: documentPath+"/htm2")
      } catch {
        // 対象フォルダが存在しない場合
        return []
      }
    }
    
    let str = searchBar.text!.lowercased()
    if str.prefix(1) == "đ" {
      searchFileName = "d0" + str.suffix(str.count - 1) + ".htm"
    } else {
      searchFileName = str + ".htm"
    }
    // 検索ファイル名がlocalFileListに存在するかチェック
    
    if localFileList.index(of: searchFileName) != nil {
      // 存在した場合
//      fileName = searchFileName
      jump = ""
      zoom = segment1value[segment1index]
    
    } else {
      // 存在しなかった場合
      if str.prefix(1) == "đ" {
        searchFileName = "d0.htm"
      } else {
        searchFileName = str.prefix(1) + ".htm"
      }
      jump = str
      zoom = segment1value[segment1index]
    }

    anchorHTML = "<html><head><meta charset=utf-8\"></head><body onload=location.href=\"htm2/" + searchFileName + "?jump=" + jump + "&zoom=" + zoom + "\"></body></html>"

    // WebViewに表示
    showFileSearchResult()
  }
  
  // anchorHTMLを anchor.htm に書き込み、WebViewに表示
  func showFileSearchResult() {
    if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
      // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
      let targetFilePath = documentDirectoryFileURL.appendingPathComponent("anchor.htm")

      // 書き込み
      do {
        try anchorHTML.write(to: targetFilePath, atomically: true, encoding: String.Encoding.utf8)
      } catch let error as NSError {
        print("書き込みエラーが発生しました: \(error)")
        return
      }
      
      // 表示
      let path = targetFilePath.path   // String型の Document path
      let url = NSURL(fileURLWithPath: path)
      let urlRequest = NSURLRequest(url: url as URL)
      self.webView.scalesPageToFit = false
      self.webView.loadRequest(urlRequest as URLRequest)
    }
  }
}


