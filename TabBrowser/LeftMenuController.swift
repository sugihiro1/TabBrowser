//
//  LeftMenuController.swift
//  TabBrowser
//
//  Created by 杉山尋美 on 2017/12/21.
//  Copyright © 2017年 hiromi.sugiyama. All rights reserved.
//

import UIKit


class LeftMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet var table:UITableView!
  
  let userDefaults0 = UserDefaults.standard
  let userDefaults1 = UserDefaults.standard

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // table.delegate = self
    // table.dataSource = self
    
    if let aaa = userDefaults0.object(forKey: "sw0") {
      swIsOnArray0 = aaa as! Array<Bool>
    }
    
    if let aaa = userDefaults0.object(forKey: "sw1") {
      swIsOnArray1 = aaa as! Array<Bool>
    }

  }

/*
  //Table Viewのセルの数を指定
  func tableView(_ table: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return commandArray.count
  }
*/
  
  // Cell の高さを設定
  func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40.0
  }

  // セクションの数を返す.
  func numberOfSections(in table: UITableView) -> Int {
    return sections.count
  }
  
  // セクションのタイトルを返す.
  func tableView(_ table: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section] as? String
  }
  
  // テーブルに表示する配列の総数を返す.
  func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return commandArray0.count
    } else if section == 1 {
      return commandArray1.count
    } else {
      return 0
    }
  }
  

  //各セルの要素を設定する
  func tableView(_ table: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
    
    if indexPath.section == 0 {
      cell.textLabel?.text = String(describing: commandArray0[indexPath.row])
      let sw = switchArray0[indexPath.row] as! UISwitch
      sw.isOn = swIsOnArray0[indexPath.row]
      sw.tag = indexPath.row
      sw.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
      cell.accessoryView = sw
    } else if indexPath.section == 1 {
      cell.textLabel?.text = String(describing: commandArray1[indexPath.row])
      let sw = switchArray1[indexPath.row] as! UISwitch
      sw.isOn = swIsOnArray1[indexPath.row]
      sw.tag = indexPath.row + 100
      sw.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
      cell.accessoryView = sw
    }
        
    return cell
  }
  
  // Switchが変更された時に呼び出される.
  @objc func switchTriggered(sender: UISwitch){
    if sender.tag < 100 {
      swIsOnArray0[sender.tag] = sender.isOn
      userDefaults0.set(swIsOnArray0, forKey:"sw0")
    } else if sender.tag >= 100 {
      swIsOnArray1[sender.tag - 100] = sender.isOn
      userDefaults1.set(swIsOnArray1, forKey:"sw1")
    }
  }
  // Cellが選択された際に呼び出される.
  func tableView(_ table: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      print("Value: \(commandArray0[indexPath.row])")
    } else if indexPath.section == 1 {
      print("Value: \(commandArray1[indexPath.row])")
    }    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  
}
