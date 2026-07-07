//
//  TrackingTopBar.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI

struct TrackingTopBar: View {

    @Binding var showConnectivity: Bool
    let onBack: () -> Void

    var body: some View {

        HStack {

            Button(action: onBack) {

                Image(systemName: "chevron.backward")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            Spacer()

            ConnectivityButton {

                withAnimation(.spring(response: 0.35)) {
                    showConnectivity.toggle()
                }
            }
        }
    }
}

#Preview {

    TrackingTopBar(
        showConnectivity: .constant(true),
        onBack: {}
    )
    .padding()
    .preferredColorScheme(.dark)
}
