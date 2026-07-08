//
//  smashPadApp.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import SwiftUI
import SwiftData

@main
struct smashPadApp: App {

    var body: some Scene {
        WindowGroup {
//            AppThemeManager {
//                RootView()
//            }
            
            ContentView()
        }
        .modelContainer(for: [
            Category.self,
            Session.self,
            HeartRate.self,
            TenseEvent.self,
            Punch.self
        ])
    }
}
