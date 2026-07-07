//
//  TrackingInfo.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI
import SwiftData

struct TrackingInfo: View {

    let session: Session

    var status: TrackingStatus = .monitoring

    var body: some View {

        VStack(alignment: .leading, spacing: 26) {

            Text(session.category.name)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.primary)

            HStack(spacing: 8) {

                Image(systemName: status.icon)
                    .foregroundStyle(status.color)

                Text(status.message)
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 24))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {

    do {

        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(
            for: Category.self,
            Session.self,
            HeartRate.self,
            TenseEvent.self,
            Punch.self,
            configurations: config
        )

        let category = Category(name: "Studying")

        container.mainContext.insert(category)

        let session = Session(
            category: category,
            startTime: .now,
            averageRestingHR: 75
        )

        container.mainContext.insert(session)

        return TrackingInfo(session: session)
            .padding()
            .preferredColorScheme(.dark)
            .modelContainer(container)

    } catch {

        return Text("Preview Error")

    }
}
