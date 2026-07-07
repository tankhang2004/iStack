//
//  PunchCount.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI

struct PunchCounter: View {

    let punchCount: Int

    @State private var scale: CGFloat = 1

    var body: some View {

        VStack(spacing: 10) {

            Text("\(punchCount)")
                .font(.system(size: 88,
                              weight: .medium,
                              design: .rounded))
                .contentTransition(.numericText())
                .scaleEffect(scale)
                .animation(.spring(response: 0.35), value: scale)

            Text("TIMES PILLOW PUNCHED")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(2)
        }
        .onChange(of: punchCount) { _, _ in

            scale = 1.15

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                scale = 1
            }
        }
    }
}

#Preview {

    VStack {

        Spacer()

        PunchCounter(punchCount: 7)

        Spacer()

    }
    .preferredColorScheme(.dark)
}
