//
//  ConnectivityButton.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct ConnectivityButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let size: CGFloat
    let iconSize: CGFloat
    let action: () -> Void
    
    init(
            size: CGFloat = 42,
            iconSize: CGFloat = 18,
            action: @escaping () -> Void
        ) {
            self.size = size
            self.iconSize = iconSize
            self.action = action
        }

    var body: some View {
        
        Button(action: action) {
            Image(systemName: "point.3.connected.trianglepath.dotted")
                .font(.system(size: iconSize, weight: .heavy))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .frame(width: size, height: size)
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
