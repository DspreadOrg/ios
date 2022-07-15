//
//  BTSearchPage.swift
//  Swift-demo
//
//  Created by 方正伟 on 2018/8/20.
//  Copyright © 2018年 方正伟. All rights reserved.
//

import UIKit

class BTSearchPage: UIViewController,BluetoothDelegate2Mode,UITableViewDelegate,UITableViewDataSource{

    var BTTableView : UITableView?
    var btFinder : BTDeviceFinder?
    var BTDeviceArray : NSMutableArray?
    let cellId = "cellid"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    self.view.backgroundColor = UIColor.white;
        
      if btFinder == nil {

        btFinder = BTDeviceFinder();
      }
        
       self.BTDeviceArray = NSMutableArray();
       
       btFinder?.setBluetoothDelegate2Mode(self);
       btFinder?.scanQPos2Mode(10)
        
        BTTableView = UITableView(frame: view.bounds, style: .plain);
        BTTableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellId);
        view.addSubview(BTTableView!);
        
        BTTableView?.delegate = self;
        BTTableView?.dataSource = self;
    }
    
    
    
    func onBluetoothName2Mode(_ bluetoothName: String!) {
        
        if bluetoothName != nil{
            
            self.BTDeviceArray?.add(bluetoothName);
            
            DispatchQueue.main.async {
                self.BTTableView?.reloadData();
            }
        }
    }
    
    func stopScan(){
        
        if (btFinder != nil) {
            
            btFinder?.stopQPos2Mode();
            btFinder?.setBluetoothDelegate2Mode(nil);
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
        self.stopScan()
        super.viewWillDisappear(true)
    }
    
    func finishScanQPos2Mode() {
        
        self.stopScan();
    }
    
//    func bluetoothIsPowerOff2Mode() {
//        
//        self.stopScan();
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return (self.BTDeviceArray?.count)!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId);
        cell?.textLabel?.text = (self.BTDeviceArray?[indexPath.row] as! String);
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let btName = self.BTDeviceArray![indexPath.row];
        
        let postradevc = PosDoTradeVc();
        
        postradevc.btName = btName as? String
        
        self.navigationController?.pushViewController(postradevc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
