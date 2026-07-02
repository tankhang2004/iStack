//
//  ContentView.swift
//  smashPad
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectivity = ConnectivityManager.shared
    
    private var bluetooth = BluetoothService.shared
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Analytical Dashboard")
                .font(.largeTitle.bold())
            
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
        }
        .onChange(of: connectivity.currentStatus) { oldStatus, newStatus in
            if newStatus == "stressed" {
                bluetooth.turnOnPillowLED()
            } else {
                bluetooth.turnOffPillowLED()
            }
        }
    }
}

#Preview {
    ContentView()
}
