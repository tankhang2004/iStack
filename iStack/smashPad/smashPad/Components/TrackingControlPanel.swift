//
//  TrackingControlPanel.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI

struct TrackingControlPanel: View {

    @Binding var isPaused: Bool
    @Binding var isExpanded: Bool

    let onEndSession: () -> Void

    var body: some View {

        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(.ultraThinMaterial)
            .frame(maxWidth: .infinity)
            .frame(height: isExpanded ? 290 : 230)
            .overlay {

                VStack(spacing: 24) {
                    Capsule()
                        .fill(.secondary.opacity(0.5))
                        .frame(width: 42, height: 5)
                        .padding(.top, -8)
                        .padding(.bottom, -8)
                    
                    Text("00:00")
                        .font(.system(size: 34,
                                      weight: .medium,
                                      design: .rounded))
                        .foregroundColor(Color.indigo)

                    Button {
                        withAnimation(.spring()) {
                            isPaused.toggle()
                            isExpanded.toggle()
                        }

                    } label: {

                        Image(systemName: isPaused ? "play.fill" : "pause")
                            .font(.system(size: 36))
                            .frame(width: 110, height: 110)
                            .foregroundColor(isPaused ? Color.indigo.opacity(0.8) : .primary)
                            .background(isPaused ? .indigo.opacity(0.2) : Color.primary.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 16)
                    .padding(.top, -10)

                    if isExpanded {
                        Button(action: onEndSession) {

                            HStack(spacing: 8) {

                                Image(systemName: "xmark")
                                    .fontWeight(.medium)

                                Text("End Session")
                                    .font(.system(size: 18, weight: .regular))
                            }
                            .foregroundStyle(.red)
                            .padding(.vertical, 14)
                            .frame(width: 330)
                            .background(Color.red.opacity(0.14))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .padding(.top, -10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal)
            .animation(.spring(), value: isExpanded)
    }
}

#Preview {

    TrackingControlPanel(
        isPaused: .constant(false),
        isExpanded: .constant(false),
        onEndSession: {}
    )
    .preferredColorScheme(.dark)
}
