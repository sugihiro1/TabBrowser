//
//  SearchViewController.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2017/12/24.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD


class SearchViewController: UIViewController,  UISearchBarDelegate {
  
//  @IBOutlet weak var searchBar: UISearchBar!
  var searchBar: UISearchBar!
  private var progressView: UIProgressView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
   // 検索バーを作成する.
    searchBar = UISearchBar(frame:CGRect(x:0, y:0, width:300, height:45))
    searchBar.delegate = self
    searchBar.layer.position = CGPoint(x:160, y: 50)
    searchBar.searchBarStyle = UISearchBarStyle.minimal
//    searchBar.placeholder = "検索ワード"
    searchBar.tintColor = UIColor.cyan
    searchBar.showsCancelButton = false
    // 余計なボタンは非表示にする.
    searchBar.showsSearchResultsButton = false
    searchBar.showsBookmarkButton = false
    // View Controller上に、UISearchBarを追加
    self.view.addSubview(searchBar)

    // ツールバー
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
    menuBtnView.setBackgroundImage(UIImage(named: "menu"), for: .normal)
    menuBtnView.addTarget(self, action: #selector(onClickSearchMenuBarButton), for: .touchUpInside)
    let menuBtn = UIBarButtonItem(customView: menuBtnView)

    // ブックマークボタン
    let listBookBtnView = UIButton(frame: CGRect(x:0, y:0, width:24, height:18))
    listBookBtnView.setBackgroundImage(UIImage(named: "book"), for: .normal)
    listBookBtnView.addTarget(self, action: #selector(onClickListBookBarButton), for: .touchUpInside)
    let listBookBtn = UIBarButtonItem(customView: listBookBtnView)
    
    // スペーサー
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)

    // ツールバーに追加する
    toolbar.items = [backBtn, flexibleItem, menuBtn, flexibleItem, listBookBtn]
    self.view.addSubview(toolbar)

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    print("SearchButton clicked")
  }

  @objc func onClickBackBarButton(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    self.dismiss(animated: false, completion: nil)
  }
  
  @objc func onClickSearchMenuBarButton(_ searchBar: UISearchBar) {
    self.slideMenuController()?.openRight()
  }
  
  @objc func onClickListBookBarButton(_ searchBar: UISearchBar) {
    
  }

}
