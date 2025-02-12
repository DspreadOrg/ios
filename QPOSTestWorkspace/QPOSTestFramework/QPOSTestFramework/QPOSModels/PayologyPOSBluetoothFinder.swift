
import Foundation

// MARK: - Delegate Protocol
public protocol PayologyPOSBluetoothFinderDelegate: NSObject {
    
    func didStartScanning()
    
    func didStopScanning(hasFoundDevice: Bool)
    
    func didFindPOSDeviceName(deviceName: String)
    
}

// MARK: - Class Implementation
public class PayologyPOSBluetoothFinder: NSObject, BluetoothDelegate2Mode {
    
    public let BTFinder : BTDeviceFinder = BTDeviceFinder()
    public weak var delegate : PayologyPOSBluetoothFinderDelegate?
    public var didFoundDevice: Bool = false
    
    public init(delegate: PayologyPOSBluetoothFinderDelegate? = nil) {
        super.init()
        self.delegate = delegate
    }
}

// MARK: - Own Methods
extension PayologyPOSBluetoothFinder {

    public func startScan(scanningInterval: TimeInterval) {
        BTFinder.setBluetoothDelegate2Mode(self)
        BTFinder.scanQPos2Mode(Int(scanningInterval))
        
        delegate?.didStartScanning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + scanningInterval) { [weak self] in
            guard let self else { return }
            self.stopScan()
            
            if !didFoundDevice { delegate?.didStopScanning(hasFoundDevice: false) }
        }
    }
    
    public func stopScan() {
        BTFinder.stopQPos2Mode()
        BTFinder.setBluetoothDelegate2Mode(nil)
    }
    
    private func isPOSDeviceName(_ bluetoothName: String) -> Bool {
        guard bluetoothName.count >= 4 else { return false }
        let firstFourCharacters = bluetoothName.prefix(8)
        return firstFourCharacters == "MPOS1081"
    }
}

// MARK: - BluetoothDelegate2Mode Methods
extension PayologyPOSBluetoothFinder {
    
    public func onBluetoothName2Mode(_ bluetoothName: String!) {
        guard
            let bluetoothName,
            isPOSDeviceName(bluetoothName)
        else { return }
        
        stopScan()
        self.didFoundDevice = true
        delegate?.didStopScanning(hasFoundDevice: true)
        delegate?.didFindPOSDeviceName(deviceName: bluetoothName)
    }
    
    public func finishScanQPos2Mode() {
        self.stopScan()
    }
}
