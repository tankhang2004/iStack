//
//  RootView.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI
import SwiftData

struct RootView: View {

    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardPage()
            } else {
                TabView {
                    ActivityView()
                        .tabItem {
                            Label("Activity", systemImage: "heart.fill")
                        }

                    SummaryView()
                        .tabItem {
                            Label("Summary", systemImage: "chart.line.text.clipboard")
                        }
                }
                .tint(Color(red: 109/255, green: 124/255, blue: 255/255))
            }
        }
    }
}

#Preview {

    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")

    return RootView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [
            Category.self,
            Session.self,
            HeartRate.self,
            TenseEvent.self,
            Punch.self
        ], inMemory: true)
}
