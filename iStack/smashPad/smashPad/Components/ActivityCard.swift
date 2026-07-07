//
//  ActivityCard.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import SwiftUI

struct ActivityCard: View {

    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let action: () -> Void

    var body: some View {

        HStack {

            Text(title)
                .font(.title3.bold())
                .foregroundStyle(colorScheme == .dark ? .white : .black)

            Spacer()

            Button(action: action) {
                Image(systemName: "play.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(Color(red: 109/255, green: 124/255, blue: 255/255))
                    .clipShape(Circle())
            }
        }
        .padding()
        .frame(height: 82)
        .background(
            Color(red: 109/255, green: 124/255, blue: 255/255)
                .opacity(0.2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ActivityCard(
        title: "Studying",
        action: {}
    )
    .padding()
    .preferredColorScheme(.dark)
}
