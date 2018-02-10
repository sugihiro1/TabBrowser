//
//  SearchViewController.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2017/12/24.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit
import Kanna
import SVProgressHUD
import SlideMenuControllerSwift

class SearchViewController: UIViewController,  UISearchBarDelegate, UIViewControllerTransitioningDelegate  {
  
  var window: UIWindow?
  var webView: UIWebView!
  
  var timer = Timer()
  var progress: Float = 0.5
  var searchFihished: Bool = false
  
  var searchBar: UISearchBar!
  var searchBtn: UIBarButtonItem!
  var progressView: UIProgressView!
  
  let userDefaults0 = UserDefaults.standard
  let userDefaults1 = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let aaa = userDefaults0.object(forKey: "sw0") {
      swIsOnArray0 = aaa as! Array<Bool>
    }
    
    if let aaa = userDefaults0.object(forKey: "sw1") {
      swIsOnArray1 = aaa as! Array<Bool>
    }
    
    // 検索バーを作成
    searchBar = UISearchBar(frame:CGRect(x:0, y:0, width:300, height:35))
    searchBar.delegate = self
    searchBar.layer.position = CGPoint(x:160, y: 45)
    searchBar.searchBarStyle = UISearchBarStyle.minimal
    // searchBar.placeholder = "検索ワード"
    searchBar.tintColor = UIColor.cyan
    // 余計なボタンは非表示にする.
    searchBar.showsSearchResultsButton = false
    searchBar.showsCancelButton = false
    searchBar.showsBookmarkButton = false
    self.view.addSubview(searchBar)
    
    // 検索ボタンを作成
    let searchBtnView = UIButton(frame: CGRect(x:0, y:0, width:50, height:24))
    searchBtnView.layer.position = CGPoint(x:340, y: 45)
    searchBtnView.setTitle("検索", for: .normal)
    searchBtnView.setTitleColor(UIColor.blue, for: .normal)
    searchBtnView.addTarget(self, action: #selector(onClickSearchButton), for: .touchUpInside)
    self.view.addSubview(searchBtnView)
    //    searchBtn = UIBarButtonItem(customView: searchBtnView)
    
    // ProgressViewを作成
    progressView = UIProgressView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width * 2, height:20))
    progressView.progressTintColor = UIColor.green
    progressView.trackTintColor = UIColor.white
    progressView.layer.position = CGPoint(x:0, y:68)
    progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
    self.view.addSubview(progressView)


    // webViewを作成
    webView = UIWebView(frame:CGRect(x:0, y:77, width:self.view.bounds.size.width, height:self.view.bounds.size.height-122))
//    webView.backgroundColor = UIColor.green
//   webView.scalesPageToFit = true
    self.view.addSubview(webView)
 
    
    // ツールバーを作成する
    let toolbar = UIToolbar(frame: CGRect(x:0, y:self.view.bounds.size.height - 44, width:self.view.bounds.size.width, height:40.0))
    toolbar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
    toolbar.barStyle = .default
    toolbar.barTintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    
    // 戻るボタン
    let backBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    backBtnView.setBackgroundImage(UIImage(named: "back3"), for: .normal)
    backBtnView.addTarget(self, action: #selector(onClickBackBarButton), for: .touchUpInside)
    let backBtn = UIBarButtonItem(customView: backBtnView)
    
    // メニューボタン
    let menuBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    menuBtnView.setBackgroundImage(UIImage(named: "menu2"), for: .normal)
    menuBtnView.addTarget(self, action: #selector(onClickSearchMenuBarButton), for: .touchUpInside)
    let menuBtn = UIBarButtonItem(customView: menuBtnView)

    // メニューボタン長押しのジェスチャー
    let menuLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressSearchMenuBarBtn))
    menuLongPressGesture.minimumPressDuration = 1.0// 長押し-最低1秒間は長押しする.
    menuLongPressGesture.allowableMovement = 150// 長押し-指のズレは15pxまで.
    menuBtnView.addGestureRecognizer(menuLongPressGesture)
    
    // ブックマークボタン（検索ヒストリー）
    let listBookBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    listBookBtnView.setBackgroundImage(UIImage(named: "book"), for: .normal)
    listBookBtnView.addTarget(self, action: #selector(onClickListBookBarButton), for: .touchUpInside)
    let listBookBtn = UIBarButtonItem(customView: listBookBtnView)
    
    // スペーサー
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    // ツールバーに追加する
    toolbar.items = [backBtn, flexibleItem, menuBtn, flexibleItem, listBookBtn]
    self.view.addSubview(toolbar)
    
    // 0.1秒後に右メニューを下から出す
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showRightMenu), userInfo: nil, repeats: false)
    
  }
  
  func showLocalHtml(_ url: String) {
    // Documentフォルダにあるmenuファイルのフルパスを取得
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let menuURL = documentURL.appendingPathComponent(url)
    let path = menuURL.path   // String型の Document path
    let url = NSURL(fileURLWithPath: path)
    let urlRequest = NSURLRequest(url: url as URL)
    self.webView.loadRequest(urlRequest as URLRequest)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // 「戻る」ボタン
  @objc func onClickBackBarButton(sender: UIButton) {
    searchBar.endEditing(true)
    self.dismiss(animated: false, completion: nil)
  }
  
  // ブックマークボタン（検索ヒストリー）
  @objc func onClickListBookBarButton(sender: UIButton) {
  }
  
  // 検索メニュームボタン長押し
  @objc func longPressSearchMenuBarBtn(sender: UILongPressGestureRecognizer){
    // Web画面をscalableにする
    self.webView.scalesPageToFit = true
    self.webView.reload()
  }
  
  // 検索メニュームボタン
  @objc func onClickSearchMenuBarButton(sender: UIButton) {
    popupRigntMenu()
  }
  
  @objc func showRightMenu() {
    popupRigntMenu()
  }
  
  func popupRigntMenu() {
    // RightMenuController をモーダル表示する
    let storyboard = UIStoryboard(name: "Search", bundle: nil)
    let rightMenuController = storyboard.instantiateViewController(withIdentifier: "Right")
    rightMenuController.modalPresentationStyle = .custom
    rightMenuController.transitioningDelegate = self
    present(rightMenuController, animated: true, completion: nil)
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

  // 検索ボタン クリック
  @objc func onClickSearchButton() {
    searchBar.resignFirstResponder()  // キーボードを閉じる
    performSearch ()
  }
  
  //キーボードの検索キーボタン押下
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    performSearch()
  }
  
  func performSearch () {
    
    // 画面のscalabilityをfalseに戻しておく
    self.webView.scalesPageToFit = false
    
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
      if swIsOnArray0[0] == true {
        searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/htm1/", type: "<tr>")
      }
    }
    queue.async{
      if swIsOnArray0[1] == true {
        searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/htm2/", type: "<tr>")
      }
    }
    queue.async{
      if swIsOnArray0[2] == true {
        searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/TuVung/", type: "<p>")
      }
    }
    queue.async{
      if swIsOnArray0[3] == true {
        searchResult = searchResult + self.searchWordAction(searchWord, subDir: "/BaiNghe/", type: "<p>")
      }
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
    
    // 単語htmlファイルがあるDocumentディレクトリーのパスを取得
    let currentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    // ディレクトリ内の単語htmlファイルをリストアップし、wordFiles[]配列に収納
    var wordFiles: [String] {
      do {
        return try FileManager.default.contentsOfDirectory(atPath: currentDir + subDir)
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
          if body!.range(of: searchWord) != nil { // -> true
            
            // 検索語を含むファイルの処理
            // <tr>タグごとに検索語をチェック、含んで入ればその<tr>タグのouterHTMLをtargetHtmlに追記する
            var duplicate: Bool = false
            for node in doc.css("tr") {
              trText = node.toHTML!
              if trText?.range(of: searchWord) != nil {
                trText = trText?.replacingOccurrences(of: searchWord, with: "<span style=\"background-color:yellow;\">" + searchWord + "</span>")
                
                if subDir == "/htm2/" && swIsOnArray1[1] == true{
                  duplicate = checkDuplication(trText: trText!, searchResult: searchResult)
                  print(duplicate)
                
                  if duplicate == false {
                    searchResult = searchResult + trText!
                  }
                } else {
                  searchResult = searchResult + trText!
                }
              }
            }
          }else{
          }
          
        } else if type == "<p>" {
          for node in doc.css("p") {
            divText = node.toHTML!
            if divText?.range(of: searchWord) != nil {
              divText = divText?.replacingOccurrences(of: searchWord, with: "<span style=\"background-color:yellow;\">" + searchWord + "</span>")
              searchResult = searchResult + "<tr><td colspan=\"4\">" + divText! + "</td></tr>"
            } else {
            }
          }
          
        }
      }
    }
    
    print("\(subDir) searched")
    return searchResult
    
  }
    
  func checkDuplication(trText: String, searchResult: String) -> Bool{
     print(searchResult)
     print("\n")
     print(trText)
    if searchResult.range(of: trText) != nil {
      return true
    } else {
      return false
    }
  }
  
}



extension ViewController: UIViewControllerTransitioningDelegate {
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    return CustomPresentationController(presentedViewController: presented, presenting: presenting)
  }
}



class CustomPresentationController: UIPresentationController {
  
  // 呼び出し元の View Controller の上に重ねるオーバーレイ View
  var overlay: UIView!
  
  // 表示トランジション開始前に呼ばれる
  override func presentationTransitionWillBegin() {
    let containerView = self.containerView!
    
    self.overlay = UIView(frame: containerView.bounds)
    self.overlay.gestureRecognizers = [UITapGestureRecognizer(target: self, action: Selector(("overlayDidTouch:")))]
    self.overlay.backgroundColor = UIColor.black
    self.overlay.alpha = 0.0
    containerView.insertSubview(self.overlay, at: 0)
    
    // トランジションを実行
    presentedViewController.transitionCoordinator?.animate(alongsideTransition: {
      [unowned self] context in
      self.overlay.alpha = 0.5
      }, completion: nil)
  }
  
  // 非表示トランジション開始前に呼ばれる
  override func dismissalTransitionWillBegin() {
    self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: {
      [unowned self] context in
      self.overlay.alpha = 0.0
      }, completion: nil)
  }
  
  // 非表示トランジション開始後に呼ばれる
  override func dismissalTransitionDidEnd(_ completed: Bool) {
    if completed {
      self.overlay.removeFromSuperview()
    }
  }
  
  // 子のコンテナのサイズを返す
  func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    return CGSize(width: parentSize.width / 2, height: parentSize.height)
  }
  
  // 呼び出し先の View Controller の Frame を返す
  func frameOfPresentedViewInContainerView() -> CGRect {
    var presentedViewFrame = CGRect()
    let containerBounds = containerView!.bounds
    presentedViewFrame.size = self.sizeForChildContentContainer(container: self.presentedViewController, withParentContainerSize: containerBounds.size)
    presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
    presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
    return presentedViewFrame
  }
  
  // レイアウト開始前に呼ばれる
  override func containerViewWillLayoutSubviews() {
    overlay.frame = containerView!.bounds
    self.presentedView!.frame = self.frameOfPresentedViewInContainerView()
  }
  
  // レイアウト開始後に呼ばれる
  override func containerViewDidLayoutSubviews() {
  }
  
  // オーバーレイの View をタッチしたときに呼ばれる
  func overlayDidTouch(sender: AnyObject) {
    self.presentedViewController.dismiss(animated: true, completion: nil)
  }
  
}



