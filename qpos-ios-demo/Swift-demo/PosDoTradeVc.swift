
//
//  PosDoTradeVc.swift
//  Swift-demo
//
//  Created by 方正伟 on 2018/8/20.
//  Copyright © 2018年 方正伟. All rights reserved.
//

import UIKit
enum OperationAction {
    case InsertAction
    case SwipeAction
    case NFCAction
}

class PosDoTradeVc: UIViewController,QPOSServiceListener{
    lazy var pos : QPOSService? = {
       let pos = QPOSService.sharedInstance()
       return pos
    }()
    
    lazy var dotradeBtn : UIButton? = {
        let dotradeBt = UIButton()
        dotradeBt.setTitle("dotrade", for: .normal)
        dotradeBt.backgroundColor = UIColor.orange;
        dotradeBt.frame = CGRect(x: 30, y: 100, width: 90, height:40)
        dotradeBt.setTitleColor(UIColor.white, for: .normal);
        dotradeBt.setTitleColor(UIColor.black, for: .highlighted);
        dotradeBt.layer.cornerRadius = 10;
        dotradeBt.addTarget(self, action:#selector(doTradeAction), for: .touchUpInside);
        return dotradeBt
    }()
    
    lazy var getPosId : UIButton? = {
        let getPosIdBtn = UIButton()
        getPosIdBtn.setTitle("getPosId", for: .normal)
        getPosIdBtn.backgroundColor = UIColor.orange;
        getPosIdBtn.frame = CGRect(x: 30, y: 150, width: 90, height:40)
        getPosIdBtn.setTitleColor(UIColor.white, for: .normal);
        getPosIdBtn.setTitleColor(UIColor.black, for: .highlighted);
        getPosIdBtn.layer.cornerRadius = 10;
        getPosIdBtn.addTarget(self, action:#selector(getPosIdAction), for: .touchUpInside);
        return getPosIdBtn
    }()
    
    lazy var getPosInfo : UIButton? = {
        let getPosInfoBtn = UIButton()
        getPosInfoBtn.setTitle("getPosInfo", for: .normal)
        getPosInfoBtn.backgroundColor = UIColor.orange;
        getPosInfoBtn.frame = CGRect(x: 30, y: 200, width: 90, height:40)
        getPosInfoBtn.setTitleColor(UIColor.white, for: .normal);
        getPosInfoBtn.setTitleColor(UIColor.black, for: .highlighted);
        getPosInfoBtn.layer.cornerRadius = 10;
        getPosInfoBtn.addTarget(self, action:#selector(getPosInfoAction), for: .touchUpInside);
        return getPosInfoBtn
    }()
    
    lazy var resetPosBtn : UIButton? = {
        let resetPosBtn = UIButton()
        resetPosBtn.setTitle("resetPOS", for: .normal)
        resetPosBtn.backgroundColor = UIColor.orange;
        resetPosBtn.frame = CGRect(x: 30, y: 250, width: 90, height:40)
        resetPosBtn.setTitleColor(UIColor.white, for: .normal);
        resetPosBtn.setTitleColor(UIColor.black, for: .highlighted);
        resetPosBtn.layer.cornerRadius = 10;
        resetPosBtn.addTarget(self, action:#selector(resetPOSAction), for: .touchUpInside);
        return resetPosBtn
    }()
    
    lazy var disconnectBlu : UIButton? = {
        let disconnectBlu = UIButton()
        disconnectBlu.setTitle("disconnect", for: .normal)
        disconnectBlu.backgroundColor = UIColor.orange;
        disconnectBlu.frame = CGRect(x: 30, y: 300, width: 90, height:40)
        disconnectBlu.setTitleColor(UIColor.white, for: .normal);
        disconnectBlu.setTitleColor(UIColor.black, for: .highlighted);
        disconnectBlu.layer.cornerRadius = 10;
        disconnectBlu.addTarget(self, action:#selector(disconnectBluAction), for: .touchUpInside);
        return disconnectBlu
    }()
    
    lazy var textViewLog : UITextView? = {
       let textViewLo = UITextView()
        textViewLo.frame = CGRect(x: 130, y: 100, width: (view.bounds.width-140), height: (view.bounds.height-100))
        textViewLo.textColor = UIColor.black
        textViewLo.font = UIFont.boldSystemFont(ofSize: 16)
        return textViewLo
    }()
    
    var btName : String?
    var terminalTime : String!
    var currencyCode : String!
    var mTransType : TransactionType!
    var batchData : String = ""
    var cardNumStr : String = ""
    var pinblockStr : String = ""
    let BDK : String = "0123456789ABCDEFFEDCBA9876543210"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        view.addSubview(textViewLog!)
        view.addSubview(dotradeBtn!)
        view.addSubview(resetPosBtn!)
        view.addSubview(getPosId!)
        view.addSubview(getPosInfo!)
        view.addSubview(disconnectBlu!)
        pos?.setDelegate(self)
        pos?.setPosType(PosType.bluetooth_2mode)
        pos?.setQueue(nil)
        pos?.connectBT(self.btName);
        currencyCode="0156";
        self.textViewLog?.text = "connecting bluetooth...";
        pos?.setBTAutoDetecting(true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.pos?.disconnectBT()
        super.viewWillDisappear(true)
    }
    
    func onRequestQposConnected() {
        self.textViewLog?.text = "pos Connected"
    }
    
    func onRequestQposDisconnected() {
        print("111----onRequestQposDisconnected");
        self.textViewLog?.text = "pos Disconnected"
    }
    
    func onRequestNoQposDetected() {
        self.textViewLog?.text = "No pos Detected"
    }
    
    func onRequestSetAmount() {
        
        let alertVc = UIAlertController(title: "please set amount", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "confirm", style: .default) { (_) in
            for text in alertVc.textFields! {
                self.pos?.setAmount(text.text, aAmountDescribe: "123", currency: "0156", transactionType:.GOODS)
            }
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (_) in
            self.pos?.cancelSetAmount()
        }
        alertVc.addTextField { (textfield : UITextField) in
            textfield.placeholder = ""
        }
        alertVc.addAction(okAction)
        alertVc.addAction(cancelAction)
        present(alertVc, animated: true, completion:nil)
    }
    
    // Fires after amount is set for a charge, waits on swipe
    func onRequestWaitingUser() {
        self.textViewLog?.text = "Please insert/swipe/tap card now."
    }
    
    func onDHError(_ errorState: DHError) {
        var stateStr : String = "";
        if errorState == DHError.TIMEOUT {
            stateStr = "TIMEOUT";
        }else if errorState == DHError.APDU_ERROR{
            stateStr = "APDU_ERROR";
        }else if (errorState == DHError.UNKNOWN){
            stateStr = "UNKNOWN";
        }else if (errorState == DHError.DEVICE_BUSY){
            stateStr = "DEVICE_BUSY";
        }else if (errorState == DHError.DEVICE_RESET){
            stateStr = "DEVICE_RESET";
        }else if (errorState == DHError.INPUT_INVALID){
            stateStr = "INPUT_INVALID";
        }else if (errorState == DHError.WR_DATA_ERROR){
            stateStr = "WR_DATA_ERROR";
        }else if errorState == DHError.EMV_APP_CFG_ERROR{
            stateStr = "EMV_APP_CFG_ERROR";
        }else if errorState == DHError.INPUT_ZERO_VALUES{
            stateStr = "INPUT_ZERO_VALUES";
        }else if errorState == DHError.DIGITS_UNAVAILABLE{
            stateStr = "DIGITS_UNAVAILABLE";
        }else if errorState == DHError.EMV_CAPK_CFG_ERROR{
            stateStr = "EMV_CAPK_CFG_ERROR";
        }else if errorState == DHError.ICC_ONLINE_TIMEOUT{
            stateStr = "ICC_ONLINE_TIMEOUT";
        }else if errorState == DHError.INPUT_OUT_OF_RANGE{
            stateStr = "INPUT_OUT_OF_RANGE";
        }else if errorState == DHError.AMOUNT_OUT_OF_LIMIT{
            stateStr = "AMOUNT_OUT_OF_LIMIT";
        }else if errorState == DHError.QPOS_MEMORY_OVERFLOW{
            stateStr = "QPOS_MEMORY_OVERFLOW";
        }else if errorState == DHError.CMD_TIMEOUT{
            stateStr = "CMD_TIMEOUT"
        }else if errorState == DHError.CASHBACK_NOT_SUPPORTED{
            stateStr = "CASHBACK_NOT_SUPPORTED"
        }else if errorState == DHError.COMM_ERROR{
            stateStr = "COMM_ERROR"
        }else if errorState == DHError.DIGITS_UNAVAILABLE{
            stateStr = "DIGITS_UNAVAILABLE"
        }
        self.textViewLog?.text = stateStr;
    }
    
    func onRequest(_ displayMsg: Display) {
        var msg : String = ""
        if displayMsg == Display.PLEASE_WAIT{
            msg = "Please wait...";
        }else if displayMsg == Display.REMOVE_CARD{
            msg = "Please remove card";
        }else if displayMsg == Display.TRY_ANOTHER_INTERFACE{
            msg = "Please try another interface";
        }else if displayMsg == Display.TRANSACTION_TERMINATED{
            msg = "Terminated";
        }else if displayMsg == Display.PIN_OK{
            msg = "Pin ok";
        }else if displayMsg == Display.INPUT_PIN_ING{
            msg = "please input pin on pos";
        }else if displayMsg == Display.MAG_TO_ICC_TRADE{
            msg = "please insert chip card on pos";
        }else if displayMsg == Display.INPUT_OFFLINE_PIN_ONLY{
            msg = "input offline pin only";
        }else if displayMsg == Display.CARD_REMOVED{
            msg = "Card Removed";
        }else if displayMsg == Display.INPUT_LAST_OFFLINE_PIN{
            msg = "input last offline pin";
        }
        self.textViewLog?.text = msg;
    }

    @objc func doTradeAction() {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        self.terminalTime = dateFormatter.string(from: Date())
        self.mTransType = TransactionType.GOODS
        self.batchData = ""
        self.textViewLog?.text = ""
        self.currencyCode = "0156";
        pos?.setCardTradeMode(CardTradeMode.SWIPE_TAP_INSERT_CARD);
        pos?.doTrade();
    }
    
    @objc func resetPOSAction() {
        if pos?.resetPosStatus() ?? false {
            self.textViewLog?.text="reset pos success";
        }else{
            self.textViewLog?.text="reset pos fail";
        }
    }
    
    func onRequestPinEntry() {
        let alertVc = UIAlertController(title: "please input pin", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "confirm", style: .default) { (_) in
            for text in alertVc.textFields! {
                print("PIN: \(text.text ?? "")")
                self.pos?.sendPinEntryResult(text.text);
            }
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (_) in
            self.pos?.cancelPinEntry();
        }
        alertVc.addTextField { (textfield : UITextField) in
            textfield.placeholder = ""
        }
        alertVc.addAction(okAction)
        alertVc.addAction(cancelAction)
        present(alertVc, animated: true, completion:nil)
    }
    
    @objc func disconnectBluAction() {
        pos?.disconnectBT();
    }
    
    @objc func getPosIdAction() {
        pos?.getQPosId();
    }
    
    @objc func getPosInfoAction() {
       pos?.getQPosInfo();
    }

    func onQposIdResult(_ posId: [AnyHashable : Any]!) {
        self.textViewLog?.text="posid:\(posId["posId"] as! String)\npsamId:\(posId["psamId"] as! String)\ntmk0Status:\(posId["tmk0Status"] as! String)\ntmk1Status:\(posId["tmk1Status"] as! String)\ntmk2Status:\(posId["tmk2Status"] as! String)\ntmk3Status:\(posId["tmk3Status"]as! String)\ntmk4Status:\(posId["tmk4Status"]as! String)\nisKeyboard:\(posId["isKeyboard"]as! String)\nisSupportNFC:\(posId["isSupportNFC"]as! String)";
    }
    
    func onQposInfoResult(_ posInfoData: [AnyHashable : Any]!) {
        print(posInfoData);
        self.textViewLog?.text = "Bootloader Version:\(posInfoData["bootloaderVersion"]as! String)\nFirmware Version: \(posInfoData["firmwareVersion"]as! String)\nHardware Version:\(posInfoData["hardwareVersion"] as! String)\nbatteryLevel:\(posInfoData["batteryLevel"]as! String)\nbatteryPercentage:\(posInfoData["batteryPercentage"]as! String)\nSUB:\(posInfoData["SUB"]as! String)\nPCIHardwareVersion:\(posInfoData["PCIHardwareVersion"]as! String)\nisCharging:\(posInfoData["isCharging"]as! String)\nisSupportedTrack1:\(posInfoData["isSupportedTrack1"]as! String)\nisUsbConnected:\(posInfoData["isUsbConnected"]as! String)\nupdateWorkKeyFlag:\(posInfoData["updateWorkKeyFlag"]as! String)";
    }
    
    func onDoTradeResult(_ result: DoTradeResult, decodeData: [AnyHashable : Any]!) {
        print(("onDoTradeResult?>> result \(result)"))
        print(decodeData);
        if result == DoTradeResult.ICC {
            //insert card
            self.pos?.doEmvApp(EmvOption.START)
        }else if result == DoTradeResult.MCR{
            //swipe card
            self.printTransactionData(dict: decodeData! as NSDictionary,operationAction: .SwipeAction)
        }else if result == DoTradeResult.NFC_ONLINE{
            //NFC card
            self.printTransactionData(dict: decodeData! as NSDictionary,operationAction: .NFCAction)
        }else if result == DoTradeResult.NONE{
            self.textViewLog?.text = "No card detected. Please insert or swipe card again and press check card"
        }else if result == DoTradeResult.NFC_OFFLINE{
            self.textViewLog?.text = "NFC_OFFLINE"
        }else if result == DoTradeResult.NO_RESPONSE{
            self.textViewLog?.text = "NO_RESPONSE"
        }else if result == DoTradeResult.NFC_DECLINED{
            self.textViewLog?.text = "NFC_DECLINED"
        }
    }
    
    func printTransactionData(dict : NSDictionary,operationAction:OperationAction) {
        
        if dict.count <= 1 {
            return
        }
        let formatID = dict.object(forKey:"formatID");
        let maskedPAN = dict.object(forKey:"maskedPAN");
        let expiryDate = dict.object(forKey:"expiryDate");
        let cardHoldName = dict.object(forKey:"cardholderName");
        let pinksn = dict.object(forKey:"pinKsn") as! String
        let trackksn = dict.object(forKey:"trackksn");
        let servicecode = dict.object(forKey:"serviceCode");
        cardNumStr = dict.object(forKey:"encTrack2") as! String
        pinblockStr = dict.object(forKey:"pinBlock") as! String
        if operationAction == .SwipeAction {
            self.textViewLog?.text = "Swipe Card:\nformatID:\(formatID ?? "")\nmaskedPAN:\(maskedPAN ?? "")\nexpiryDate:\(expiryDate ?? "")\ncardHoldName:\(cardHoldName ?? "")\npinksn:\(pinksn)\ntrackksn:\(trackksn ?? "")\nservicecode:\(servicecode ?? "")\ncardNum:\(cardNumStr)\npinblock:\(pinblockStr)";
        }else{
            self.textViewLog?.text = "NFC Card:\nformatID:\(formatID ?? "")\nmaskedPAN:\(maskedPAN ?? "")\nexpiryDate:\(expiryDate ?? "")\ncardHoldName:\(cardHoldName ?? "")\npinksn:\(pinksn)\ntrackksn:\(trackksn ?? "")\nservicecode:\(servicecode ?? "")\ncardNum:\(cardNumStr)\npinblock:\(pinblockStr)";
        }
    }
    
    func onRequestTime() {
        self.pos?.sendTime(self.terminalTime)
    }
    
    //pls select AID in this callback function
    func onRequestSelectEmvApp(_ appList: [Any]!) {
         print(appList);
         pos?.selectEmvApp(0);
    }
    
    func onRequestOnlineProcess(_ tlv: String!) {
        self.textViewLog?.text = "Online process requested."
        print("onRequestOnlineProcess: " + tlv)
        let hashtable:String = pos?.getICCTag(0, tagCount: 1, tagArrStr: "5F20")["tlv"] as! String;
        print("hashtable: " + hashtable);
        self.pos?.sendOnlineProcessResult("8A023030")
    }
    
    func onRequestBatchData(_ tlv: String!) {
        self.batchData = tlv
        print("onRequestBatchData: "+tlv)
    }
    
    func onRequest(_ transactionResult: TransactionResult) {
        var message3 = "";
        if transactionResult == TransactionResult.APPROVED {
            message3 = "approve";
        }else if transactionResult == TransactionResult.TERMINATED{
            
            message3 = "terminated";
            
        }else if transactionResult == TransactionResult.DECLINED{
    
            message3 = "decline";
        }else if transactionResult == TransactionResult.CANCEL{
        
            message3 = "cancel";
        }else if transactionResult == TransactionResult.CAPK_FAIL{
            
            message3 = "capk fail";
            
        }else if transactionResult == TransactionResult.NOT_ICC{
            
            message3 = "not icc";
            
        }else if transactionResult == TransactionResult.SELECT_APP_FAIL{
            
            message3 = "app fail";
            
        }else if transactionResult == TransactionResult.DEVICE_ERROR{
        
            message3 = "device error";
            
        }else if transactionResult == TransactionResult.CARD_NOT_SUPPORTED{
            
            message3 = "card not supported";
            
        }else if transactionResult == TransactionResult.MISSING_MANDATORY_DATA{
            
            message3 = "missing mandatory data";
            
        }else if transactionResult == TransactionResult.CARD_BLOCKED_OR_NO_EMV_APPS{
        
            message3 = "card blocked or no emv apps";
            
        }else if transactionResult == TransactionResult.INVALID_ICC_DATA{
            
            message3 = "invalid icc data";
            
        }else if transactionResult == TransactionResult.FALLBACK{
            
            message3 = "fallback";
            
        }else if transactionResult == TransactionResult.NFC_TERMINATED{
            
            message3 = "NFC terminated";
            
        }else if transactionResult == TransactionResult.TRADE_LOG_FULL{
            
            message3 = "trade log full";
        }
        print("transactionResult: "+message3);
        self.textViewLog?.text = "TransactionResult:\(message3)\ncardNumber:\(cardNumStr)\npin:\(pinblockStr)\nBatch Data:\(self.batchData)"
    }
    
    func onEmvICCExceptionData(_ tlv: String!) {
         print("onEmvICCExceptionData: "+tlv);
    }
    
    func onReturnReversalData(_ tlv: String!) {
         print("Reversal Data: "+tlv);
    }
    
    //inject TMK into pos
    func updateMasterKeyAction(){
        let newEnMaterKey = "89EEF94D28AA2DC189EEF94D28AA2DC1";
        let newEnMaterKeyKCV = "82E13665B4624DF5";
        pos?.setMasterKey(newEnMaterKey, checkValue: newEnMaterKeyKCV);
    }
    
    // callback of setMasterKey
    func onReturnSetMasterKeyResult(_ isSuccess: Bool) {
        if isSuccess {
            self.textViewLog?.text = "set masterkey success";
        }else{
            self.textViewLog?.text = "set masterkey fail";
        }
    }
    
    func updateIPEKKeyAction(){
        let groupKey = "00";
        let tracksn = "00000510F462F8400004";
        let trackipek = "293C2D8B1D7ABCF83E665A7C5C6532C9";
        let trackipekCheckValue = "93906AA157EE2604";
        
        let emvksn = "00000510F462F8400004";
        let emvipek = "293C2D8B1D7ABCF83E665A7C5C6532C9";
        let emvipekcheckvalue = "93906AA157EE2604";
        
        let pinksn = "00000510F462F8400004";
        let pinipek = "293C2D8B1D7ABCF83E665A7C5C6532C9";
        let pinipekcheckValue = "93906AA157EE2604";
        
        pos?.doUpdateIPEKOperation(groupKey, tracksn: tracksn, trackipek: trackipek, trackipekCheckValue: trackipekCheckValue, emvksn: emvksn, emvipek: emvipek, emvipekcheckvalue: emvipekcheckvalue, pinksn: pinksn, pinipek: pinipek, pinipekcheckValue: pinipekcheckValue, block: { (isSuccess, stateStr) in
            if (isSuccess) {
                self.textViewLog?.text = stateStr;
            }
        })
    }
    
    //update work key into pos
    func updateWorkKeyAction(){
        let pik = "89EEF94D28AA2DC189EEF94D28AA2DC1";
        let pinKeyCheck = "82E13665B4624DF5";
        
        let trackKey = "89EEF94D28AA2DC189EEF94D28AA2DC1";
        let trackKeyCheck = "82E13665B4624DF5";
        
        let macKey = "89EEF94D28AA2DC189EEF94D28AA2DC1";
        let macKeyCheck = "82E13665B4624DF5";
        
        pos?.udpateWorkKey(pik, pinKeyCheck: pinKeyCheck, trackKey: trackKey, trackKeyCheck: trackKeyCheck, macKey: macKey, macKeyCheck: macKeyCheck);
    }
    
    //callback of update work key
    func onRequestUpdateWorkKeyResult(_ updateInformationResult: UpdateInformationResult) {
        print("onRequestUpdateWorkKeyResult %ld",updateInformationResult);
        if (updateInformationResult==UpdateInformationResult.UPDATE_SUCCESS) {
           self.textViewLog?.text = "update workkey Success";
        }else if(updateInformationResult==UpdateInformationResult.UPDATE_FAIL){
           self.textViewLog?.text =  "Failed";
        }else if(updateInformationResult==UpdateInformationResult.UPDATE_PACKET_LEN_ERROR){
           self.textViewLog?.text =  "Packet len error";
        }else if(updateInformationResult==UpdateInformationResult.UPDATE_PACKET_VEFIRY_ERROR){
           self.textViewLog?.text =  "Packet vefiry error";
        }
    }
    
    //use xml file to update emv config
    func updateEmvConfigByXMLFile() {
        let data = self.readLine(name: "emv_profile_tlv")
        print("updateEmvConfigAction: %@",data);
        pos?.updateEMVConfig(byXml: QPOSUtil.asciiFormatString(data));
    }
    
    func onReturnCustomConfigResult(_ isSuccess: Bool, config resutl: String!) {
        if isSuccess {
            self.textViewLog?.text = "Success";
        }else{
            self.textViewLog?.text = "fail" + resutl;
        }
    }
  
    //use tlv data to update emv config
    func updateEMVAIDConfigByTlv(){
        let tlvData = "9F0607A00000000310109F3303E0F8C8";
        pos?.updateEmvAPP(byTlv: EMVOperation.update, appTlv: tlvData);
    }
    //use tlv data to update emv config
    func updateCAPKConfigByTlv(){
        let tlvData = "9F0605A0000000039F220107";
        pos?.updateEmvCAPK(byTlv: EMVOperation.update, capkTlv: tlvData);
    }
    
    //use bin file to update emv config
//    func updateEMVConfigByBinFile(){
//        let emvAppCfg = QPOSUtil.byteArray2Hex(readLine(name: "emv_app"));
//        let emvCapkCfg = QPOSUtil.byteArray2Hex(readLine(name: "emv_capk"));
//        pos?.updateEmvConfig(emvAppCfg, emvCapk: emvCapkCfg);
//    }
    
    func onReturnUpdateEMVResult(_ isSuccess: Bool) {
        if isSuccess {
            self.textViewLog?.text="UpdateEMVResult:SUCCESS";
        }else{
            self.textViewLog?.text="UpdateEMVResult:FAIL";
        }
    }
    
    func onReturnGetEMVListResult(_ result: String!) {
        self.textViewLog?.text="EMVListResult:"+result;
    }
    
    func onReturnUpdateEMVRIDResult(_ isSuccess: Bool) {
        if isSuccess {
            self.textViewLog?.text="UpdateEMVRIDResult:SUCCESS";
        }else{
            self.textViewLog?.text="UpdateEMVRIDResult:FAIL";
        }
    }
    
    func readLine(name : String) -> Data{
      let xmlFile = Bundle.main.path(forResource: name, ofType: ".xml") ?? "";
      let ascFile = Bundle.main.path(forResource: name, ofType: ".asc") ?? "";
      let binFile = Bundle.main.path(forResource: name, ofType: ".bin") ?? "";
      print("xmlFile:"+xmlFile+"  "+"ascFile:"+ascFile+"  "+"binFile:" + binFile);
      var data2 = Data.init();
      let manager = FileManager.default;
      if (!xmlFile.isEmpty){
          data2 = manager.contents(atPath: xmlFile)!;
      }else if(!ascFile.isEmpty){
          data2 = manager.contents(atPath: ascFile)!;
      }else if(!binFile.isEmpty){
          data2 = manager.contents(atPath: binFile)!;
      }
         return data2;
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}




















