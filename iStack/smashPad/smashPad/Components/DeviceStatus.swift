//
//  DeviceStatus.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI

struct DeviceStatusRow: View {

    let icon: String
    let title: String
    let connected: Bool

    var body: some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.title3)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 3) {

                Text(title)
                    .font(.headline)

                Text(connected ? "Connected" : "Not Connected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(connected ? .green : .red)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 2)
    }
}

#Preview("Connected") {
        VStack {
            DeviceStatusRow(
                icon: "applewatch",
                title: "Apple Watch",
                connected: true
            )

            DeviceStatusRow(
                icon: "pill",
                title: "Smart Pillow",
                connected: false
            )
        }
        .padding()
        .preferredColorScheme(.dark)
}
