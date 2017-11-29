//
//  TabVC.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2017/11/06.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import WebKit
import SwiftyDropbox
import SVProgressHUD


// MARK: - タブを保持するコンテナクラス
class TabData
{
  var webView:UIWebView!
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

    let downloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.organize, target: self, action: #selector(onClickDownloadButton))
    self.navigationItem.setRightBarButton(downloadButton, animated: true)
    
    self.createNewTab()
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
//      textView.text = tabDataList[indexPath.row].webView.title
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

/*
  // タブの保存
  public func saveTab(wkWebView:WKWebView){     // この func が呼び出されない。
//    self.tabDataList[self.myTabIndexPathRow].webView = wkWebView
    tabDataList[myTabIndexPathRow].webView = wkWebView
   // すぐ実行すると真っ白な画像が撮れる為 少し間を空けてサムネイル画像を保存
    Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: Selector(("saveTabImageExec")), userInfo: nil, repeats: false)
    print("Saved WebView")
  }
*/
  
  // Dropboxから単語htmlファイルをダウンロードするプロシージャ
  @objc func onClickDownloadButton() {
    
    // ログインしていなければ、まずログインする
    if DropboxClientsManager.authorizedClient == nil {
      
      DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                    controller: self,
                                                    openURL: { (url: URL) -> Void in
                                                      UIApplication.shared.open(url, options: [:], completionHandler: nil)
      })
    } else {
      
      
      // 全ファイルダウンロード
      let queue = DispatchQueue(label: "queue")
      
      queue.async {
        print("Will download root dir \(Date())")
        self.downloadAll("/Vietnam/VietmenuIphone/", DocumentDir: "/")
      }
      
      
      queue.async {
        print("Will download htm1 \(Date())")
        self.downloadAll("/Vietnam/Words1/htm1/", DocumentDir: "htm1")
      }
      
      
      queue.async {
        print("Will download htm1/images \(Date())")
        self.downloadAll("/Vietnam/Words1/htm1Images/", DocumentDir: "htm1Images")
      }
      
      
      queue.async {
        print("Will download TuVung \(Date())")
        self.downloadAll("/Vietnam/Words1/TuVung/", DocumentDir: "TuVung")
      }
      
      
      queue.async {
        print("Will download htm2 \(Date())")
        self.downloadAll("/Vietnam/Words2/htm2/", DocumentDir: "htm2")
      }
      
      queue.async {
        print("Will download BaiNghe \(Date())")
        self.downloadAll("/Vietnam/Bai Nghe/Words/", DocumentDir: "BaiNghe")
      }
      
      queue.async {
        print("Will download BaiNghe images\(Date())")
        self.downloadAll("/Vietnam/Bai Nghe/BaiNgheImages/", DocumentDir: "BaiNgheImages")
      }
      
    }
  }
  
  
  // Dropboxよりダウンロード
  func downloadAll(_ DropboxDir: String, DocumentDir: String)  {
    
    // Documentフォルダのパス取得
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let downloadDataURL = documentURL.appendingPathComponent(DocumentDir)
    
    // Documentディレクトリの対象フォルダ内のファイルをlocalFileListに収容
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var localFileList: [String] {
      do {
        return try fileManager.contentsOfDirectory(atPath: documentPath+"/"+DocumentDir)
      } catch {
        // 対象フォルダが存在しない（未作成）の場合、フォルダを作成する
        try! fileManager.createDirectory(at: downloadDataURL, withIntermediateDirectories: true, attributes: nil)
        return []
      }
    }
    
    // localFileList のコピー(localFileName)を準備
    var localFileName: [String] = []
    
    // localFileListに収容されたファイルのタイムスタンプをlocalFileDateリストに収容
    var localFileDate: [String] = []
    for idx in 0..<localFileList.count {
      do {
        let attribs: NSDictionary =
          try fileManager.attributesOfItem(atPath: documentPath+"/"+DocumentDir+"/"+localFileList[idx]) as NSDictionary
        let modDate = attribs["NSFileModificationDate"].debugDescription
        let modDateStr = modDate.substring(with: modDate.index(modDate.startIndex, offsetBy: 9)..<modDate.index(modDate.startIndex, offsetBy: 28))
        localFileDate.append(modDateStr)
        
        //　localFileListのitemがファイルの場合、localFileNameリストに収容
        let fileType = attribs["NSFileType"].debugDescription
        let fileTypeStr = fileType.substring(with: fileType.index(fileType.startIndex, offsetBy: 9)..<fileType.index(fileType.startIndex, offsetBy: 26))
        if fileTypeStr == "NSFileTypeRegular" {
          print(localFileList[idx])
          localFileName.append(localFileList[idx])
        }
        
        
      } catch let error {
        print("Error: \(error.localizedDescription)") }
    }
    
    
    SVProgressHUD.show()
    
    // Dropboxにあるファイルのメタデータ取得
    var counter: Int = 0
    var isMoved: Bool = false
    var hasError = false
    
    guard let client = DropboxClientsManager.authorizedClient else {return }
    client.files.listFolder(path: DropboxDir).response { response, error in
      
      if let metadata = response {
        counter = metadata.entries.count
        
        for file in metadata.entries {
          
          // ファイルでないアイテムはskipする
          if !(file is Files.FileMetadata) {
            counter -= 1
            print("Found a non-file item: \(file.name)")
            continue
          }
          //          print(file.name)
          
          // Dropboxの各ファイルと同じファイルがローカルににあるかチェック
          if let idx = localFileList.index(of: file.name) {
            // 同じファイルがローカルにあった場合、localFileNameリストよりremoveする
            let idxName = localFileName.index(of: file.name)
            localFileName.remove(at: idxName!)
            
            // ファイルの更新日付を取得
            let txt = file.description
            let dropboxFileDate = txt.substring(with: txt.index(txt.startIndex, offsetBy: 27)..<txt.index(txt.startIndex, offsetBy: 37)) + " " + txt.substring(with: txt.index(txt.startIndex, offsetBy: 38)..<txt.index(txt.startIndex, offsetBy: 46))
            //            print("dropboxFileDate: \(dropboxFileDate)")
            //            print("localFileDate: \(localFileDate[idx])")
            
            // ローカルファイルの日付がDropboxにあるファイルの日付より新しい場合は、ダウンロードしない
            if localFileDate[idx] > dropboxFileDate {
              counter -= 1
              //              print("Counter \(counter)")
              continue
            }
          }
          
          let downloadFileURL = downloadDataURL.appendingPathComponent(file.name)
          let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return downloadFileURL
          }
          
          // ダウンロード
          client.files.download(path: DropboxDir+file.name, overwrite: true, destination: destination).response { response, error in
            //            print(file.name)
            counter -= 1
            if let response = response {
              //                print("response: \(response)")
            } else if let error = error {
              print("Has Error: \(error)")
              hasError = true
              SVProgressHUD.showError(withStatus: error.description)
            }
            
            print("Downloaded \(file.name) \(Date())")
            
            if counter <= 0 {
              isMoved = true
              print("isMoved 1")
              //              print("Local unmatched files: \(localFileName)")
              SVProgressHUD.dismiss()
            }
            
            }  /* client.files.download ().response */
            
            .progress { progressData in
              // print(progressData)
          }
          
        }  /* for file in metadata.entries */
        
        if counter <= 0 {
          isMoved = true
          print("isMoved 2")
          //          print("Local unmatched files: \(localFileName)")
          SVProgressHUD.dismiss()
        }
        
      } else {  /* if let metadata = response */
        print(error!)
        SVProgressHUD.showError(withStatus: error!.description)
      }
      
    } /* client.files.listFolder() */
    
    
    repeat {
      if isMoved == true {
        
        // Downloadされたファイルに含まれないローカルファイルをremoveする
        for file in localFileName {
          let removeFileURL = downloadDataURL.appendingPathComponent(file)
          try? fileManager.removeItem(at: removeFileURL)
          print("Removed: \(file)")
        }
        
        print("Finished downloading from \(DocumentDir) \(Date())\n")
        return
      } else {
        Thread.sleep(forTimeInterval: 0.1)
      }
    } while true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}



