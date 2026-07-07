//
//  Session.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import Foundation
import SwiftData

@Model
final class Session {

    @Attribute(.unique)
    var id: UUID

    var startTime: Date
    var endTime: Date?
    var averageRestingHR: Int
    var category: Category

    @Relationship(deleteRule: .cascade)
    var heartRates: [HeartRate] = []

    @Relationship(deleteRule: .cascade)
    var tenseEvents: [TenseEvent] = []

    init(
        category: Category,
        startTime: Date,
        endTime: Date? = nil,
        averageRestingHR: Int
    ) {
        self.id = UUID()
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.averageRestingHR = averageRestingHR
    }
}

extension Session {

    /// Falls back to "now" for a session that hasn't ended yet.
    var displayEndTime: Date {
        endTime ?? .now
    }

    /// Full wall-clock duration of the session.
    var elapsedTime: TimeInterval {
        displayEndTime.timeIntervalSince(startTime)
    }

    /// Total time spent in a "recovery" (pillow-punch calming) window across all tense events.
    var totalRecoveryDuration: TimeInterval {
        tenseEvents.reduce(0) { partial, event in
            guard let start = event.recoveryStartedAt, let end = event.recoveryEndedAt else {
                return partial
            }
            return partial + end.timeIntervalSince(start)
        }
    }

    /// "Active" time — elapsed time minus time spent recovering.
    var activityTime: TimeInterval {
        max(elapsedTime - totalRecoveryDuration, 0)
    }

    /// All pillow punches logged across every tense event in this session.
    var allPunches: [Punch] {
        tenseEvents.flatMap(\.punchData)
    }

    var punchCount: Int {
        allPunches.count
    }

    /// Heart rate samples sorted chronologically, ready for the chart.
    var sortedHeartRates: [HeartRate] {
        heartRates.sorted { $0.timestamp < $1.timestamp }
    }
}