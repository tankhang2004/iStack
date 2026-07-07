import Foundation
import CoreBluetooth
import Combine

class BluetoothService: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BluetoothService()
    
    // Variables to be monitored by SwiftUI views
    @Published var isConnected = false
    @Published var lastPunchIntensity: Double = 0.0
    @Published var punchCount: Int = 0
    @Published var isBluetoothPoweredOn = false
    
    private var centralManager: CBCentralManager!
    private var pillowPeripheral: CBPeripheral?
    private var txCharacteristic: CBCharacteristic? // ESP32 -> iOS
    private var rxCharacteristic: CBCharacteristic? // iOS -> ESP32
    
    // UUIDs must match exactly with the ESP32 (main.cpp)
    private let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789012")
    private let rxUUID = CBUUID(string: "87654321-4321-4321-4321-210987654321")
    private let txUUID = CBUUID(string: "abcdef01-abcd-abcd-abcd-abcdef012345")
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothPoweredOn = (central.state == .poweredOn)
        }

        if central.state == .poweredOn {
            print("🔵 Bluetooth is Active! Scanning for SmashPad_Bantal...")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            print("🔴 Bluetooth is off or unavailable.")

            DispatchQueue.main.async {
                self.isConnected = false
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("🔵 Pillow Found! Connecting...")
        pillowPeripheral = peripheral
        pillowPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(pillowPeripheral!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🟢 Successfully Connected to Pillow!")
        DispatchQueue.main.async {
            self.isConnected = true
        }
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("🔴 Pillow Disconnected! Rescanning...")
        DispatchQueue.main.async {
            self.isConnected = false
        }
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    // MARK: - CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([rxUUID, txUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == rxUUID {
                rxCharacteristic = characteristic
            } else if characteristic.uuid == txUUID {
                txCharacteristic = characteristic
                // Subscribe to notifications so iOS automatically receives data from ESP32
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    // MARK: - RECEIVE DATA FROM ESP32 (Parsing Intensity)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == txUUID, let data = characteristic.value else { return }
        
        // Convert byte data to String ("PUNCH:32.45")
        if let message = String(data: data, encoding: .utf8) {
            
            // Verify format
            if message.hasPrefix("PUNCH:") {
                let components = message.split(separator: ":")
                
                if components.count == 2 {
                    let intensityString = String(components[1])
                    
                    // Convert numeric string to Double
                    if let intensity = Double(intensityString) {
                        DispatchQueue.main.async {
                            print("💥 PUNCH RECEIVED ON iOS! Intensity: \(intensity)")
                            
                            // Update variables to trigger UI changes
                            self.lastPunchIntensity = intensity
                            self.punchCount += 1
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - SEND COMMAND TO ESP32
    func turnOnPillowLED() {
        guard let peripheral = pillowPeripheral, let rxChar = rxCharacteristic else { return }
        
        // Send 0x01 (TENSED)
        let command: [UInt8] = [0x01]
        let data = Data(command)
        peripheral.writeValue(data, for: rxChar, type: .withResponse)
        print("📱 iOS Sending: TURN ON LIGHT (0x01)")
    }
    
    func turnOffPillowLED() {
        guard let peripheral = pillowPeripheral, let rxChar = rxCharacteristic else { return }
        
        // Send 0x00 (RELAXED)
        let command: [UInt8] = [0x00]
        let data = Data(command)
        peripheral.writeValue(data, for: rxChar, type: .withResponse)
        print("📱 iOS Sending: TURN OFF LIGHT (0x00)")
    }
    
    func scanAgain() {

        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on.")
            return
        }

        centralManager.stopScan()

        centralManager.scanForPeripherals(
            withServices: [serviceUUID],
            options: nil
        )

        print("🔄 Scanning again...")
    }
}
