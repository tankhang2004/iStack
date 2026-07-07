//
//  ConnectivityButton.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct ConnectivityButton: View {
    @Environment(\.colorScheme) private var colorScheme

    let action: () -> Void

    var body: some View {
        
        Button(action: action) {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .frame(width: 48, height: 48)
                .glassEffect(in: Circle())
                .overlay {
                    Circle()
                        .stroke(
                            colorScheme == .dark
                            ? .white.opacity(0.25)
                            : .black.opacity(0.15),
                            lineWidth: 1.5
                        )
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ConnectivityButton { }
        .preferredColorScheme(.dark)
}
