//
//  SetUpController.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2018/02/03.
//  Copyright © 2018年 hiromi.sugiyama. All rights reserved.
//

import UIKit

var segment1index: Int = 0
var segment1value: Array = ["1.0","1.25", "1.5"]

// userDefaultsインスタンス生成 (segment1index)
let userDefaults2 = UserDefaults.standard

// デリゲートメソッド定義
protocol FontResizeDelegate {
  func fontResize()
}


class SetUpController: UIViewController {
  
  var delegate: FontResizeDelegate? = nil
  
  @IBOutlet weak var SegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    SegmentedControl.selectedSegmentIndex = segment1index
  }
  
  // 「単語検索」ボタンが押された
  @IBAction func WordSearchButtonPushed(_ sender: Any) {
    // 検索(searchViewController)画面へ遷移
    let storyboard = UIStoryboard(name: "Search", bundle: nil)
    let searchViewController = storyboard.instantiateViewController(withIdentifier: "Search")
    self.present(searchViewController,animated: false, completion: nil)
  }
  
  // 「書体サイズ」SegmentedControlが選択された
  @IBAction func SegmentedControlPushed(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      segment1index = 0
    case 1:
      segment1index = 1
    case 2:
      segment1index = 2
    default:
      print("該当無し")
    }
    
    // fontResize 実行
    self.delegate = browserVC as? FontResizeDelegate
    if let dg = self.delegate {
      // browserVCクラスのfontResizeプロシージャをデリゲート経由実行
      dg.fontResize()
    } else {
      print("何もしません")
    }
    
    // userDefaults保存
    userDefaults2.set(segment1index, forKey:"sw2")
  }
  
  // 「Close」ボタンが押された
  @IBAction func CloseButtonPushed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}



