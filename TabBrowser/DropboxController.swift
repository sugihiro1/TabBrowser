//
//  DropboxController.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2018/02/04.
//  Copyright © 2018年 hiromi.sugiyama. All rights reserved.
//

import UIKit
import SwiftyDropbox
import SVProgressHUD

class DropboxController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
  // Dropboxから単語htmlファイルをダウンロードするプロシージャ
  func dropboxDownload() {
    
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
          //          print(localFileList[idx])
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
