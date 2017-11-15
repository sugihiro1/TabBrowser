//
//  TabVC.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2017/11/06.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit


// MARK: - タブを保持するコンテナクラス
class TabData
{
  var webView:WKWebView!
  var image:UIImage!
  
  deinit{
    webView = nil
    image = nil
  }
}

var tabDataList:[TabData] = []
var myTabIndexPathRow : Int = 0

class TabVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var collectionView : UICollectionView!
//  var tabDataList:[TabData] = []
//  var myTabIndexPathRow : Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()


    // CollectionViewを作成する
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width:self.view.frame.width/2, height:(self.view.frame.height-64)/2)
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    collectionView = UICollectionView(frame:CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height), collectionViewLayout: layout)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.isPagingEnabled = true
    collectionView.clipsToBounds = true
    
    self.view.addSubview(collectionView)
    
    let addBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(onClickAddBarButton))
    self.navigationItem.setLeftBarButton(addBarButton, animated: true)

  }

  override func viewWillAppear(_ animated: Bool) {
    collectionView.reloadData()
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // DataSourceの件数を返す
    return tabDataList.count
//    return self.tabDataList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell : UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell",
                                                                         for: indexPath) as UICollectionViewCell
    // Cellの再利用
    for subview in cell.contentView.subviews {
      subview.removeFromSuperview()
    }
    
    // タイトルラベル
    let textView = UITextView(frame: CGRect(x:0,y:10,width:cell.frame.width,height:50))
    if(tabDataList[indexPath.row].webView != nil){
      textView.text = tabDataList[indexPath.row].webView.title
    }
    textView.font = UIFont.systemFont(ofSize: CGFloat(10))
    textView.backgroundColor = UIColor.clear
    textView.textColor = UIColor.white
    textView.textAlignment = NSTextAlignment.center
    textView.isEditable = false
    cell.contentView.addSubview(textView)
    
    // UIImageView
    let thumbNailImage = UIImageView(frame: CGRect(x:(cell.frame.width - cell.frame.width*0.75)/2, y:55, width:cell.frame.width*0.75, height:cell.frame.height*0.75))
    thumbNailImage.image = tabDataList[indexPath.row].image
    thumbNailImage.backgroundColor = UIColor.white
    cell.contentView.addSubview(thumbNailImage)
    
    // 削除ボタン
    let btnDeleteImage:UIImage!
    btnDeleteImage = UIImage(named: "closeTab")! as UIImage
    let btnDelete   = UIButton()
    btnDelete.frame = CGRect(x:0, y:0, width:25, height:25)
    btnDelete.layer.position = CGPoint(x: (cell.frame.width - cell.frame.width*0.75)/2, y:55)
    btnDelete.setImage(btnDeleteImage, for: .normal)
    btnDelete.addTarget(self, action: #selector(onClickDelete), for:.touchUpInside)
    btnDelete.tag = indexPath.row
    cell.contentView.addSubview(btnDelete);
    
    return cell
  }


  // MARK: セルタップ時のイベントでタブを選択した時に再度ブラウザ画面を開く処理
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // 選択したタブを保持
    myTabIndexPathRow = indexPath.row

    // ブラウザ画面に遷移
    print(indexPath.row)
    self.navigationController?.pushViewController(BrowserVC(delegate:self ,wKWebView: tabDataList[indexPath.row].webView,url:nil), animated: false)
    return
  }

  // MARK: - // タブ追加ボタンアクション
  @objc func onClickAddBarButton(sender : UIButton) {
    self.createNewTab()
  }
  
  // タブを生成し、テーブルソースにセットして遷移
  func createNewTab(url:String! = nil){
    myTabIndexPathRow = tabDataList.count
    tabDataList.append(TabData())
//    self.myTabIndexPathRow = self.tabDataList.count
//    self.tabDataList.append(TabData())
//    collectionView.reloadData()   // 追加
    self.navigationController?.pushViewController(BrowserVC(delegate:self ,wKWebView: nil,url:url), animated: false)
  }
  

  // MARK: - // タブを閉じるボタンアクション
  @objc func onClickDelete(sender : UIButton){
    // タブを閉じる
    tabDataList.remove(at: sender.tag)
    collectionView.reloadData()
  }

  
  // タブの保存
  public func saveTab(wkWebView:WKWebView){     // この func が呼び出されない。
//    self.tabDataList[self.myTabIndexPathRow].webView = wkWebView
    tabDataList[myTabIndexPathRow].webView = wkWebView
   // すぐ実行すると真っ白な画像が撮れる為 少し間を空けてサムネイル画像を保存
    Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: Selector(("saveTabImageExec")), userInfo: nil, repeats: false)
    print("Saved WebView")
  }

  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}



