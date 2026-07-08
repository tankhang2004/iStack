//
//  ContentView.swift
//  smashPadWatch Watch App
//
//  Created by Ahmad Taufiq Hidayat on 01/07/26.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @ObservedObject private var hkService = HealthKitService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 1. Condition with no authorization
                if !hkService.isAuthorized {
                    VStack(spacing: 14) {

                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.red)

                        Text("Allow Heart Rate Access")
                            .font(.headline)
                            .multilineTextAlignment(.center)

                        Text("Your heart rate is used to detect potential tension and start recovery sessions.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            hkService.requestAuthorization()
                        } label: {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 109/255, green: 124/255, blue: 255/255))
                        .frame(width: 110)
                    }
                    .padding(.horizontal)
                    .padding(.top, -14)
                }
                // 2. Condition with authorization
                else {
                    // Calculate stress threshold
                    let stressThreshold = hkService.restingHeartRate * 1.30
                    let isStressed = hkService.currentHeartRate >= stressThreshold && hkService.currentHeartRate > 0
                    
                    VStack(spacing: 2) {
                        Text("Current BPM")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        // Display current heart rate
                        Text("\(hkService.currentHeartRate, specifier: "%.0f") ❤️")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            // red if stressed, green if safe
                            .foregroundColor(isStressed ? .red : .green)
                    }
                    .padding(.top, 8)
                    
                    // RHR baseline info (for demo)
                    VStack(spacing: 2) {
                        Text("Baseline RHR: \(hkService.restingHeartRate, specifier: "%.0f") BPM")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text("Heart Rate Limit: > \(stressThreshold, specifier: "%.0f") BPM")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    .padding(.bottom, 8)
                    
                    // --- FAKE SIMULATION BUTTON ---
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("Test/Simulation Mode")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        // Button to force stressed condition (set BPM +10 from threshold)
                        Button("🔥 Stress") {
                            hkService.currentHeartRate = stressThreshold + 10
                            ConnectivityManager.shared.sendStressAlert()
                        }
                        .tint(.red)
                        .buttonStyle(.borderedProminent)
                        
                        // Button to force relaxed condition (BPM back to average resting heart rate)
                        Button("🍏 Relax") {
                            hkService.currentHeartRate = hkService.restingHeartRate
                            ConnectivityManager.shared.sendRelaxedAlert()
                        }
                        .tint(.green)
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, -14)
        }
    }
}

#Preview {
    ContentView()
}
