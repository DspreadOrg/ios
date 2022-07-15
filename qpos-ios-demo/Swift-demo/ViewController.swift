//
//  ViewController.swift
//  Swift-demo
//
//  Created by 方正伟 on 2018/8/20.
//  Copyright © 2018年 方正伟. All rights reserved.
//

import UIKit
//var 是定义变量，let 定义常亮不能修改
class ViewController: UIViewController {

    lazy var blueToothBtn : UIButton? = {
       
        let blueToothBt = UIButton();
        blueToothBt.setTitle("BlueTooth", for: .normal)
        blueToothBt.backgroundColor = UIColor.orange;
        blueToothBt.frame = CGRect(x: (view.bounds.width * 0.5-50), y: (view.bounds.height * 0.5), width: 100, height:50)
        blueToothBt.setTitleColor(UIColor.white, for: .normal);
        blueToothBt.setTitleColor(UIColor.black, for: .highlighted);
        blueToothBt.layer.cornerRadius = 10;
        blueToothBt.addTarget(self, action:#selector(btnClick(button:)), for: .touchUpInside);
        
        return blueToothBt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white;
        
        view.addSubview(blueToothBtn!);
    }
    
    @objc func btnClick(button:UIButton) {
        
        let searchPage = BTSearchPage();
        
        self.navigationController?.pushViewController(searchPage, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

