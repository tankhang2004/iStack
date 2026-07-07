//
//  RecoveryIllustration.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct RecoveryIllustration: View {

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {

            Circle()
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.18 : 0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 50)

            Circle()
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.08 : 0.05))
                .frame(width: 220, height: 220)

            RoundedRectangle(cornerRadius: 30)
                .fill(
                    colorScheme == .dark
                    ? Color(red: 38/255, green: 38/255, blue: 38/255)
                    : Color(.systemBackground)
                )
                .frame(width: 180, height: 340)
                .overlay {

                    VStack(spacing: 18) {

                        Capsule()
                            .fill(.blue)
                            .frame(width: 70, height: 6)
                            .padding(.top, 18)

                        Image(systemName: "heart.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(.red)

                        VStack(alignment: .leading, spacing: 12) {

                            RoundedRectangle(cornerRadius: 6)
                                .fill(.red.opacity(0.85))
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(.orange.opacity(0.85))
                                .frame(width: 110, height: 10)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(.green.opacity(0.85))
                                .frame(height: 10)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(.blue.opacity(0.85))
                                .frame(width: 90, height: 10)
                        }
                        .padding(.horizontal)

                        Spacer()

                        HStack(spacing: 22) {

                            Image(systemName: "waveform.path.ecg")
                                .font(.title2)
                                .foregroundStyle(.green)

                            Image(systemName: "bolt.heart.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)

                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        .padding(.bottom, 22)
                    }
                }
                .shadow(
                    color: .blue.opacity(colorScheme == .dark ? 0.35 : 0.2),
                    radius: 20
                )

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 34))
                .foregroundStyle(.red)
                .offset(x: -130, y: -90)

            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 34))
                .foregroundStyle(.green)
                .offset(x: 130, y: -20)

            Image(systemName: "bolt.heart.fill")
                .font(.system(size: 34))
                .foregroundStyle(.orange)
                .offset(x: -120, y: 110)

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 34))
                .foregroundStyle(.cyan)
                .offset(x: 120, y: 110)
        }
        .frame(height: 360)
    }
}

#Preview {
    RecoveryIllustration()
        .preferredColorScheme(.dark)
}
