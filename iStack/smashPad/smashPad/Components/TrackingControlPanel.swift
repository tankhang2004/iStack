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
    @Binding var elapsedTime: TimeInterval
    @GestureState private var dragOffset: CGFloat = 0
    
    let onPauseResume: () -> Void
    let onEndSession: () -> Void
    
    private var formattedTime: String {
        
        let total = Int(elapsedTime)
        let minutes = total / 60
        let seconds = total % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(.ultraThinMaterial)
            .frame(maxWidth: .infinity)
            .frame(height: isExpanded ? 310 : 230)
            .overlay {
                
                VStack(spacing: 24) {
                    
                    Capsule()
                        .fill(.secondary.opacity(0.5))
                        .frame(width: 42, height: 5)
                        .padding(.top, -8)
                        .padding(.bottom, -8)
                    
                    Text(formattedTime)
                        .font(
                            .system(
                                size: 34,
                                weight: .medium,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.indigo)
                    
                    Button {
                        
                        onPauseResume()
                        
                    } label: {
                        
                        Image(systemName: isPaused ? "play.fill" : "pause")
                            .font(.system(size: 36))
                            .frame(width: 110, height: 110)
                            .foregroundColor(
                                isPaused
                                ? Color.indigo.opacity(0.8)
                                : .primary
                            )
                            .background(
                                isPaused
                                ? Color.indigo.opacity(0.2)
                                : Color.primary.opacity(0.15)
                            )
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
                                    .font(
                                        .system(
                                            size: 18,
                                            weight: .regular
                                        )
                                    )
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
                        .transition(
                            .move(edge: .bottom)
                            .combined(with: .opacity)
                        )
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 15)
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            
                            if value.translation.height < -40 {
                                isExpanded = true
                            } else if value.translation.height > 40 {
                                isExpanded = false
                            }
                            
                        }
                    }
            )
            .padding(.horizontal, 2)
            .animation(.spring(), value: isExpanded)
    }
}

#Preview {
    
    TrackingControlPanel(
        isPaused: .constant(false),
        isExpanded: .constant(false),
        elapsedTime: .constant(75),
        onPauseResume: {},
        onEndSession: {}
    )
    .preferredColorScheme(.dark)
}
