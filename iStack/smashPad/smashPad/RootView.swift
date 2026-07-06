//
//  RootView.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                ContentView()
            } else {
                OnboardPage()
            }
        }
    }
}

#Preview {
    UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    return RootView()
}
