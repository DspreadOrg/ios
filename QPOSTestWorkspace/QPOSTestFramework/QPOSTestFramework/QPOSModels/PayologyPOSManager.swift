//
//  PayologyPOSManager.swift
//  PayologyCreditCard
//
//  Created by Filipe Rogério Canzi da Silva on 04/11/24.
//

import Foundation

public class PayologyPOSManager: NSObject, QPOSServiceListener {
    
    // MARK: - Stored Properties
    public let POSInstance = QPOSService.sharedInstance()
    public let bluetoothFinder = PayologyPOSBluetoothFinder()
    
    public private(set) var hasConnectedDevice: Bool = false {
        didSet {
            bluetoothFinder.didFoundDevice = hasConnectedDevice
        }
    }
    
    // MARK: - Observer Properties
    public var bluetoothStatus: BluetoothStatus = .awaitingConnection
    
    public var tradeStatus: TradeStatus = .awaitingTradeStart
    
    // MARK: - Initializer
    public override init() {
        super.init()
        bluetoothFinder.delegate = self
    }
}

// MARK: - Bluetooth Connection
extension PayologyPOSManager: PayologyPOSBluetoothFinderDelegate {

    public enum BluetoothStatus: Hashable, CaseIterable {
        case awaitingConnection
        
        case didStartScanning
        case scanDidFoundDevice
        case scanDidNotFoundDevice
        
        case connectingDevice
        case connectionDidSuccessfullyEnd
        case unableToConnectDevice
        
        case disconnectingDevice
        case disconnectionDidEnd
    }
    
    public func startScanning(scanningInterval: TimeInterval) {
        print(#line, #function)
        guard !hasConnectedDevice else { return }
        bluetoothFinder.startScan(scanningInterval: scanningInterval)
    }
    
    public func connectBluetoothDevice(deviceName: String) {
        print(#line, #function)
        POSInstance?.setDelegate(self)
        POSInstance?.setPosType(PosType.bluetooth_2mode)
        POSInstance?.setQueue(nil)
        
        POSInstance?.connectBT(deviceName)
        POSInstance?.setBTAutoDetecting(true)
        bluetoothStatus = .connectingDevice
    }
    
    public func disconnectBluetoothDevice() {
        print(#line, #function)
        POSInstance?.disconnectBT()
        bluetoothStatus = .disconnectingDevice
    }
    
    public func onRequestQposConnected() {
        print(#line, #function)
        hasConnectedDevice = true
        bluetoothStatus = .connectionDidSuccessfullyEnd
    }
    
    public func onRequestNoQposDetected() {
        print(#line, #function)
        bluetoothStatus = .unableToConnectDevice
    }
    
    public func onRequestQposDisconnected() {
        print(#line, #function)
        hasConnectedDevice = false
        bluetoothStatus = .disconnectionDidEnd
    }

    public func didStartScanning() {
        print(#line, #function)
        bluetoothStatus = .didStartScanning
    }
    
    public func didStopScanning(hasFoundDevice: Bool) {
        print(#line, #function)
        guard !hasConnectedDevice else { return }
        bluetoothStatus = hasFoundDevice ? .scanDidFoundDevice : .scanDidNotFoundDevice
    }
    
    public func didFindPOSDeviceName(deviceName: String) {
        print(#line, #function)
        connectBluetoothDevice(deviceName: deviceName)
    }
}

extension PayologyPOSManager {
    
    public enum TradeStatus: Hashable, CaseIterable {

        case awaitingTradeStart
        case awaitingUserCardAction
        
        case awaitingUserPIN
        case userDidEnterPIN
        case didCancelPINEntry
        case didBypassPINEntry
        
        case tradeDidTimeout
        case tradeDidFail
        case didCompleteTapTrade
        case didCompleteInsertTrade
    }
        
    public func startTrade(tradeData: POSTradeData) {
        print(#line, #function)
        let amountString = getAmountString(decimalValue: tradeData.paymentAmount)
                    
        POSInstance?.setAmount(
            amountString,
            aAmountDescribe: "",
            currency: tradeData.currencyCode,
            transactionType: tradeData.transactionType)
                
        POSInstance?.setCardTradeMode(tradeData.tradeMode)
        POSInstance?.doTrade()
    }
    
    public func stopTrade() {
        print(#line, #function)
        POSInstance?.cancelTrade(true)
    }
    
    private func getAmountString(decimalValue: Decimal) -> String {
        print(#line, #function)
        let doubleValue = NSDecimalNumber(decimal: decimalValue).doubleValue
        let amountString = String(format: "%.2f", doubleValue)
        
        /// This line takes out the decimal separator `.`.
        return amountString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    private func getTerminalTimeString() -> String {
        print(#line, #function)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: Date())
    }
    
    public func onRequestTime() {
        print(#line, #function)
        let terminalTimeString = getTerminalTimeString()
        POSInstance?.sendTime(terminalTimeString)
    }
    
    public func onRequestWaitingUser() {
        print(#line, #function)
        tradeStatus = .awaitingUserCardAction
    }
    
    public func onDHError(_ errorState: DHError) {
        print(#line, #function)
        if errorState == .TIMEOUT || errorState == .CMD_TIMEOUT {
            tradeStatus = .tradeDidTimeout
        } else {
            tradeStatus = .tradeDidFail
        }
    }
    
    public func onRequestPinEntry() {
        print(#line, #function)
        tradeStatus = .awaitingUserPIN
        POSInstance?.bypassPinEntry()
        tradeStatus = .didBypassPINEntry
    }
    

    public func onDoTradeResult(_ result: DoTradeResult, decodeData: [AnyHashable : Any]!) {
        print(#line, #function)
        guard true else { fatalError() }
        print("ON DO TRADE RESULT")
        print("DECODED DATA")
        if let decodeData {
            print("[")
            for (key, value) in decodeData {
                print("KEY: \(key), VALUE: \(value)")
            }
            print("]")
        }
        print()

        if result == .ICC {
            tradeStatus = .didCompleteInsertTrade
            POSInstance?.doEmvApp(EmvOption.START)
            return
            
        } else if result == .NFC_ONLINE, let dictionary = decodeData as? [String : String] {
            tradeStatus = .didCompleteTapTrade
            return
        } else {
            tradeStatus = .tradeDidFail
            return
        }
    }
    
    public func onRequestOnlineProcess(_ tlv: String!) {
        
        /// THIS FUNCTION IS NOT GETTING THE TLV
        print(#line, #function)
        print("TLV", tlv)
        
        guard let tlv else {
            tradeStatus = .tradeDidFail
            return
        }
        POSInstance?.sendOnlineProcessResult("8A023030")
        tradeStatus = .didCompleteInsertTrade
    }
    
    public func onRequestBatchData(_ tlv: String!) {
        print(#line, #function)
        print("TLV", tlv)
    }
    
    public func onRequest(_ transactionResult: TransactionResult) {
        print(#line, #function)
        var tranResult="";
        if transactionResult == TransactionResult.APPROVED {
            tranResult = "TransactionResult.APPROVED";
        }else if transactionResult == TransactionResult.TERMINATED{
            tranResult = "TransactionResult.TERMINATED";
        }else if transactionResult == TransactionResult.DECLINED{
            tranResult = "TransactionResult.DECLINED";
        }else if transactionResult == TransactionResult.CANCEL{
            tranResult = "TransactionResult.CANCEL";
        }else if transactionResult == TransactionResult.CAPK_FAIL{
            tranResult = "TransactionResult.CAPK_FAIL";
        }else if transactionResult == TransactionResult.NOT_ICC{
            tranResult = "TransactionResult.NOT_ICC";
        }else if transactionResult == TransactionResult.SELECT_APP_FAIL{
            tranResult = "TransactionResult.SELECT_APP_FAIL";
        }else if transactionResult == TransactionResult.DEVICE_ERROR{
            tranResult = "TransactionResult.DEVICE_ERROR";
        }else if transactionResult == TransactionResult.CARD_NOT_SUPPORTED{
            tranResult = "TransactionResult.CARD_NOT_SUPPORTED";
        }else if transactionResult == TransactionResult.MISSING_MANDATORY_DATA{
            tranResult = "TransactionResult.MISSING_MANDATORY_DATA";
        }else if transactionResult == TransactionResult.CARD_BLOCKED_OR_NO_EMV_APPS{
            tranResult = "TransactionResult.CARD_BLOCKED_OR_NO_EMV_APPS";
        }else if transactionResult == TransactionResult.INVALID_ICC_DATA{
            tranResult = "TransactionResult.INVALID_ICC_DATA";
        }else if transactionResult == TransactionResult.FALLBACK{
            tranResult = "TransactionResult.FALLBACK";
        }else if transactionResult == TransactionResult.NFC_TERMINATED{
            tranResult = "TransactionResult.NFC_TERMINATED";
        }else if transactionResult == TransactionResult.TRADE_LOG_FULL{
            tranResult = "TransactionResult.TRADE_LOG_FULL";
        }
        print(tranResult);
    }
}



extension PayologyPOSManager {
    
    public enum ConfigurationStatus: Hashable, CaseIterable {
        case isUpdatingConfiguration
        case didUpdateConfiguration
    }
}

