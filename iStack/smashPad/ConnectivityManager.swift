//
//  ConnectivityManager.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import Foundation
import WatchConnectivity
import Combine
import HealthKit

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    @Published var currentStatus: String = "relaxed"
    // Property to track watch session state on the iPhone UI
    @Published var isWatchSessionActive: Bool = false
#if os(iOS)
    
    @Published var isWatchConnected = false
    private let healthStore = HKHealthStore()
    
#endif
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Methods called by Apple Watch (Sending data to iPhone)
    func sendStressAlert() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["status": "stressed"], replyHandler: nil)
        }
    }
    
    func sendRelaxedAlert() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["status": "relaxed"], replyHandler: nil)
        }
    }
    
    // 🌟 THE MISSING FUNCTION: For Watch to sync its session state back to iPhone
    func sendSessionSync(isActive: Bool) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["sessionStatus": isActive], replyHandler: nil)
        }
    }
    
    // MARK: - Methods called by iPhone (Sending command to Apple Watch)
    func sendStartCommandToWatch() {
    #if os(iOS)
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .mindAndBody // Cocok untuk deteksi stres
            configuration.locationType = .unknown
            
            // Membangunkan Apple Watch secara paksa via HealthKit
            healthStore.startWatchApp(with: configuration) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.isWatchSessionActive = true
                        print("📱 iPhone sent START command via HealthKit (Watch Woken Up!)")
                    } else {
                        print("❌ Failed to wake watch: \(error?.localizedDescription ?? "Error unknown")")
                        
                        // Fallback: Jika gagal (misal belum ada izin), coba pakai WCSession biasa
                        if WCSession.default.isReachable {
                            WCSession.default.sendMessage(["command": "start"], replyHandler: nil)
                            self.isWatchSessionActive = true
                            print("📱 Fallback: iPhone sent START command via WCSession")
                        }
                    }
                }
            }
    #endif
        }
    
    func sendStopCommandToWatch() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["command": "stop"], replyHandler: nil)
            isWatchSessionActive = false // Update UI state immediately
            print("📱 iPhone sent STOP command to Watch via WCSession")
        }
    }
    
    // MARK: - Message Receiver (Handles incoming messages for BOTH devices)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            
            // 1. iPhone receiving data from Apple Watch
            if let status = message["status"] as? String {
                self.currentStatus = status
                print("📱 iPhone received new status: \(status)")
            }
            if let sessionStatus = message["sessionStatus"] as? Bool {
                self.isWatchSessionActive = sessionStatus
            }
            
            // 🌟 2. Apple Watch receiving commands from iPhone
#if os(watchOS)
            if let command = message["command"] as? String {
                print("⌚️ Watch received command: \(command)")
                if command == "start" {
                    HealthKitService.shared.startSession()
                } else if command == "stop" {
                    HealthKitService.shared.stopSession()
                }
            }
#endif
        }
    }
    
    // MARK: - WCSession Delegate Boilerplate
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {

        #if os(iOS)
        DispatchQueue.main.async {
            self.isWatchConnected =
                session.isPaired &&
                session.isWatchAppInstalled
        }
        #endif
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {

        #if os(iOS)
        DispatchQueue.main.async {
            self.isWatchConnected =
                session.isReachable ||
                (session.isPaired && session.isWatchAppInstalled)
        }
        #endif
    }
    
    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {}
        func sessionDidDeactivate(_ session: WCSession) {
            WCSession.default.activate()
        }
    #endif
    
    #if os(iOS)
    func requestHealthKitAuthorizationOnPhone() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToShare: Set = [HKQuantityType.workoutType()]
        
        let typesToRead = Set<HKObjectType>()
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ iOS HealthKit Authorization Granted")
                } else {
                    print("❌ iOS HealthKit Authorization Failed: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    #endif
}
