//
//  TrackingStatus.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 07/07/26.
//

import SwiftUI

enum TrackingStatus {

    case monitoring
    case tenseDetected
    case recovering
    case paused

    var icon: String {

        switch self {

        case .monitoring:
            return "heart"

        case .tenseDetected:
            return "exclamationmark.triangle.fill"

        case .recovering:
            return "heart.fill"

        case .paused:
            return "pause.fill"
        }
    }

    var color: Color {

        switch self {

        case .monitoring:
            return .indigo

        case .tenseDetected:
            return .orange

        case .recovering:
            return .green

        case .paused:
            return .gray
        }
    }

    var message: String {

        switch self {

        case .monitoring:
            return "We're quietly paying attention..."

        case .tenseDetected:
            return "Possible tension detected."

        case .recovering:
            return "Recovery in progress."

        case .paused:
            return "Monitoring paused."
        }
    }
}
