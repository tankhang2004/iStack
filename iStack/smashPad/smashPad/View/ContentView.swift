//
//  ContentView.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectivity = ConnectivityManager.shared
    
    // CRUCIAL CHANGE: Add @StateObject so the UI updates automatically when punch data is received
    @StateObject private var bluetooth = BluetoothService.shared
    
    var body: some View {
        ScrollView { // Using ScrollView to ensure it fits on smaller iPhone screens
            VStack(spacing: 30) {
                Text("Analytical Dashboard")
                    .font(.largeTitle.bold())
                
                // MARK: - 1. STATUS INDICATOR
                ZStack {
                    Circle()
                        .fill(connectivity.currentStatus == "stressed" ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                        .frame(width: 250, height: 250)
                    
                    VStack {
                        Text("Current Status:")
                            .font(.headline)
                        Text(connectivity.currentStatus == "stressed" ? "TENSED UP!" : "RELAXED")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundColor(connectivity.currentStatus == "stressed" ? .red : .green)
                    }
                }
                
                if connectivity.currentStatus == "stressed" {
                    Text("Smart Pad turned on.\nSmash the pad to relieve your tension!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
//                Divider()
//                    .padding(.horizontal)
                
                // MARK: - 2. SMASH METRICS (ESP32 Punch Data)
                VStack(spacing: 15) {
                    Text("Smash Metrics")
                        .font(.title2.bold())
                    
                    HStack(spacing: 40) {
                        // Total Smashes Column
                        VStack {
                            Text("Total Smashes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(bluetooth.punchCount)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                        }
                        
                        // Last Intensity Column
                        VStack {
                            Text("Last Intensity")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f", bluetooth.lastPunchIntensity))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                // Number turns red if the smash is very hard (> 20 m/s^2)
                                .foregroundColor(bluetooth.lastPunchIntensity > 20.0 ? .red : .primary)
                        }
                    }
                }
                
//                Divider()
//                    .padding(.horizontal)
                
                // MARK: - 3. APPLE WATCH REMOTE CONTROL
                VStack(spacing: 10) {
                    
                    
                    Button(action: {
                        if connectivity.isWatchSessionActive {
                            connectivity.sendStopCommandToWatch()
                        } else {
                            connectivity.sendStartCommandToWatch()
                        }
                    }) {
                        HStack {
                            Image(systemName: connectivity.isWatchSessionActive ? "stop.circle.fill" : "play.circle.fill")
                            Text(connectivity.isWatchSessionActive ? "End Focus Session" : "Start Focus Session")
                        }
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(connectivity.isWatchSessionActive ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal, 40)
                }
            }
            .padding(.vertical)
        }
        // Listener to turn the light on/off based on the Apple Watch signal
        .onChange(of: connectivity.currentStatus) { oldStatus, newStatus in
            if newStatus == "stressed" {
                bluetooth.turnOnPillowLED()
            } else {
                bluetooth.turnOffPillowLED()
            }
        }
        .onAppear {
            // Ask permission when first shown
            connectivity.requestHealthKitAuthorizationOnPhone()
        }
    }
}

#Preview {
    ContentView()
}
