//
//  OnboardPage.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct OnboardPage: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 35) {

                Spacer()

                RecoveryIllustration()

                VStack(spacing: 16) {
                    Text("Track Your Recovery")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)

                    Text("View your heart rate trends, recovery progress, and punching history to better understand your tension patterns.")
                        .font(.system(size: 17))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                Button {
                    hasSeenOnboarding = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: 180)
                        .frame(height: 56)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()
                    .frame(height: 20)
            }
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    OnboardPage()
}
