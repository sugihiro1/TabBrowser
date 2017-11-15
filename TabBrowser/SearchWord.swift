//
//  searchWordController.swift
//  Vietnam2
//
//  Created by 杉山尋美 on 2017/10/01.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

  
  

import UIKit
import Kanna
import SwiftyDropbox
import SVProgressHUD
//import UICheckbox

class SearchWord: UIViewController {
  
  @IBOutlet weak var searchWordUnicode: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
    let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
    self.view.addGestureRecognizer(tapGesture)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // 「検索」ボタンが押された
  @IBAction func searchWord(_ sender: Any) {
    
    // 検索語を設定
    var searchWord: String?
    
    if searchWordUnicode != nil {
      searchWord = searchWordUnicode.text
    } else {
      print("検索語が入力されていません")
      return
    }

    SVProgressHUD.show()

    // 検索結果出力ファイルのHTML文のheader部分
    let searchHeader: String? = "<html><meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"><body bgcolor=\"white\" text=\"black\" link=\"blue\" vlink=\"purple\" alink=\"red\"><table style=\"border-color:purple;\" border=\"1\" width=\"900\" cellpadding=\"2\" cellspacing=\"0\">"

    var searchResult: String = ""
    searchResult = searchResult + self.searchWordAction(searchWord!, subDir: "/htm1/", type: "<tr>")
    searchResult = searchResult + self.searchWordAction(searchWord!, subDir: "/htm2/", type: "<tr>")
    searchResult = searchResult + self.searchWordAction(searchWord!, subDir: "/TuVung/", type: "<p>")
    searchResult = searchResult + self.searchWordAction(searchWord!, subDir: "/BaiNghe/", type: "<p>")

    let searchResultHtml = searchHeader! + searchResult + "</table></html>"

    SVProgressHUD.dismiss()

    // 検索結果のhtmlを書き出す
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
      }
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
//      let pathFileName = dirDocument!.appendingPathComponent("/htm1/" + wordFiles[i] )
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
    
    return searchResult
    
  }
  
  
  // Dropboxから単語htmlファイルをダウンロードするプロシージャ
  @IBAction func DownloadFromDropbox(_ sender: Any) {
    
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
  

  
  // Dropboxよりダウンロード　（一旦、DownloadDataフォラダに落とし、全ファイルDL後、所定のフォルダにコピー）
  func downloadAllx(_ DropboxDir: String, DocumentDir: String)  {
    
    // Documentフォルダのパス取得
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // Dropboxよりダウンロードしたデータを収納する仮フォルダを作成
    let downloadDataURL = documentURL.appendingPathComponent("DownloadData")
    try! fileManager.createDirectory(at: downloadDataURL, withIntermediateDirectories: true, attributes: nil)
    
    
    // Dropboxから全ファイル取得
    SVProgressHUD.show()

    var counter: Int = 0
    var isMoved: Bool = false

    guard let client = DropboxClientsManager.authorizedClient else {return }
    
    client.files.listFolder(path: DropboxDir).response { response, error in
      
      if let metadata = response {
        counter = metadata.entries.count
        print("file count: \(counter)")
        var hasError = false
        
        for file in metadata.entries {
          
          let downloadFileURL = downloadDataURL.appendingPathComponent(file.name)
          let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return downloadFileURL
          }
         print(file.name)

          client.files.download(path: DropboxDir+file.name, overwrite: true, destination: destination).response { response, error in

              counter -= 1
              if let response = response {
//                print("response: \(response)")
              } else if let error = error {
                print("Has Error: \(error)")
                hasError = true
                SVProgressHUD.showError(withStatus: error.description)
              }
            
              // 全ファイルダウンロード完了
              print("Counter2: \(counter)")
              if (counter <= 0) {
                print("Will move to local \(DocumentDir) \(Date())\n")
               
                // 全て成功したら、フォルダを入れ替え, 元データ削除
                if hasError == false {
                  let dataURL = documentURL.appendingPathComponent(DocumentDir)
                  try? fileManager.removeItem(at: dataURL)
                  // フォルダ入れ替え
                  try! fileManager.moveItem(at: downloadDataURL, to: dataURL)
                  isMoved = true
                  SVProgressHUD.dismiss()
                  
                }
              }
            }
            .progress { progressData in
//              print(progressData)
          }
        }
      } else {
        print(error!)
        SVProgressHUD.showError(withStatus: error!.description)
      }
    }
    
    repeat {
      if isMoved == true {
        print("Will return from \(DocumentDir) \(Date())\n")
        return
      } else {
        Thread.sleep(forTimeInterval: 0.5)
      }
    } while true

  }


  
  
  // AppディレクトリーよりMenuファイルをDocument ルートデレクトリーに送るプロシージャ
  @IBAction func updateMenuFiles(_ sender: Any) {
  
    let wordFiles: [String] = ["wordsmenu1bodyIphone.htm","wordsmenu2Iphone.htm","wordsmenu2bodyIphone.htm"]
    
    var fileName: String!
    var textData: String!
    var targetFilePath: URL!
    
    // Documentフォルダのパス取得
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    let targetPathURL = documentURL
    try! fileManager.createDirectory(at: targetPathURL, withIntermediateDirectories: true, attributes: nil)
    
    for i in 0 ..< wordFiles.count {
      
      fileName = wordFiles[i]
      var indexDot = fileName.characters.index(of: ".")
      var bodyFileName = fileName.substring(to: indexDot!)
      indexDot = fileName.index(after: indexDot!)
      var extFileName = fileName.substring(from: indexDot!)
      
      let path = Bundle.main.path(forResource: bodyFileName, ofType: extFileName)!
      if let data = NSData(contentsOfFile: path){
        
        textData = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!) as String
        
        // Documentディレクトリのパスにファイル名をつなげて書き込みファイルのフルパスを作る
        let targetDirPath = documentURL
        targetFilePath = targetDirPath.appendingPathComponent(fileName)
        print(targetFilePath)
        
        // 書き込み
        do {
          try textData!.write(to: targetFilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
          print("書き込みエラーが発生しました: \(error)")
        }
      }
    }
  }

  
  // Appディレクトリーより単語htmlファイルをDocument内サブデレクトリーに送るプロシージャ　（Dropboxが使えない場合のテスト用）
  @IBAction func updateWordFiles(_ sender: Any) {
  
    let wordFiles: [String] = ["a.htm","ac.htm","ai.htm","am.htm","an.htm","anh.htm","ao.htm","ap.htm"]
    
    var fileName: String!
    var textData: String!
    var targetFilePath: URL!
    
    // Documentフォルダのパス取得
    let fileManager = FileManager.default
    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // Appディレクトリーより送ったデータを収納するサブフォルダをDocumentフォルダ内に作成
    let targetPathURL = documentURL.appendingPathComponent("htm2")
    try! fileManager.createDirectory(at: targetPathURL, withIntermediateDirectories: true, attributes: nil)
    
    for i in 0 ..< wordFiles.count {
      
      fileName = wordFiles[i]
      var indexDot = fileName.characters.index(of: ".")
      var bodyFileName = fileName.substring(to: indexDot!)
      indexDot = fileName.index(after: indexDot!)
      var extFileName = fileName.substring(from: indexDot!)
      
      let path = Bundle.main.path(forResource: bodyFileName, ofType: extFileName)!
      if let data = NSData(contentsOfFile: path){
        
        textData = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!) as String
        
        // Documentディレクトリのパスにファイル名をつなげて書き込みファイルのフルパスを作る
        let targetDirPath = documentURL.appendingPathComponent("htm2")
        targetFilePath = targetDirPath.appendingPathComponent(fileName)
        print(targetFilePath)
        
        // 書き込み
        do {
          try textData!.write(to: targetFilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
          print("書き込みエラーが発生しました: \(error)")
        }
      }
    }
  }

  
  // Documentデレクトリーにあるファイルをリストに収得     （テスト用）
  @IBAction func FileList(_ sender: Any) {
  
    // Documentディレクトリーのパスを取得
    let currentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    // ディレクトリ内のファイルをリストアップし、wordFiles[]配列に収納
    var wordFiles: [String] {
      do {
         return try FileManager.default.contentsOfDirectory(atPath: currentDir + "/htm1/")
//      return try FileManager.default.contentsOfDirectory(atPath: currentDir)
     } catch {
        return []
      }
    }
    
    print(wordFiles)
  }

  
  // ログインボタン押された （手動でログインする場合）
  @IBAction func loginButtonPushed(_ sender: Any) {
    
    DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                  controller: self,
                                                  openURL: { (url: URL) -> Void in
                                                    UIApplication.shared.openURL(url)
    })
  }
  
  
  @objc func dismissKeyboard(){
    // キーボードを閉じる
    view.endEditing(true)
  }
  

 
  
  

  
  
/**
 以下は、Dropboxとアクセスするための各プロシージャ
*/
  

  @IBAction func Login(_ sender: Any) {
  
   DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                  controller: self,
                                                  openURL: { (url: URL) -> Void in
                                                    UIApplication.shared.openURL(url)
    })
  }
  

  @IBAction func CreateFolder(_ sender: Any) {
    
    let client = DropboxClientsManager.authorizedClient
    
     client!.files.createFolder(path: "/test").response { response, error in
     if let response = response {
     print(response)
     } else if let error = error {
     print(error)
     }
     }
    
  }
  
  
  @IBAction func ListFolder(_ sender: Any) {
   
    let client = DropboxClientsManager.authorizedClient

//      client!.files.listFolder(path: "/Vietnam/Words1/htm1/").response { response, error in
      client!.files.listFolder(path: "").response { response, error in
        print()
        print("*** List folder ***")
        if let result = response {
          for entry in result.entries {
            if entry is Files.FileMetadata {
              let file = entry as! Files.FileMetadata
              print("\(file.name) \(file.size)")
              
            } else {
              print("\(entry.name)")
            }
          }
        } else {
          print("Error \(error!)")
        }
    }
    
  }
  
  @IBAction func Upload(_ sender: Any) {
    
    let client = DropboxClientsManager.authorizedClient
    
    let fileData = "testing data example".data(using: String.Encoding.utf8, allowLossyConversion: false)!
    print(type(of: fileData))
    
    client!.files.upload(path: "/test/uploadSample.txt", input: fileData)
      .response { response, error in
        if let response = response {
          print(response)
        } else if let error = error {
          print(error)
        }
      }
      .progress { progressData in
        print(progressData)
    }
    
  }
  
  @IBAction func Download(_ sender: Any) {
    
    let client = DropboxClientsManager.authorizedClient
    
    // Download to URL
    let fileManager = FileManager.default
    let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let destURL = directoryURL.appendingPathComponent("uploadSample.txt")
    let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
      return destURL
    }
    
    client!.files.download(path: "/test", overwrite: true, destination: destination)
      
      .response { response, error in
        if let response = response {
          print(response)
        } else if let error = error {
          print(error)
        }
      }
      .progress { progressData in
        print(progressData)
    }
  }
  
}
