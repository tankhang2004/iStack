//
//  smashPadWatchApp.swift
//  smashPadWatch Watch App
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import SwiftUI
import HealthKit
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    // Apple native function that is automatically called when iPhone runs healthStore.startWatchApp()
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        print("⌚️ Watch woken up by iPhone with type: \(workoutConfiguration.activityType)")
        
        // Start session when sensor is awake
        HealthKitService.shared.startSession()
    }
}

@main
struct smashPadWatch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
