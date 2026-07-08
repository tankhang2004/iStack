//  AllModelsForCopy.swift

import Foundation
import SwiftData


@Model
final class Category {

    @Attribute(.unique)
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade)
    var sessions: [Session] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

@Model
final class HeartRate {

    @Attribute(.unique)
    var id: UUID

    var heartRateBPM: Int
    var timestamp: Date

    var session: Session?

    init(
        heartRateBPM: Int,
        timestamp: Date = .now,
        session: Session? = nil
    ) {
        self.id = UUID()
        self.heartRateBPM = heartRateBPM
        self.timestamp = timestamp
        self.session = session
    }
}


@Model
final class Session {

    @Attribute(.unique)
    var id: UUID

    var startTime: Date
    var endTime: Date?

    // NEW
    var pausedAt: Date?
    var totalPausedDuration: TimeInterval

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
        pausedAt: Date? = nil,
        totalPausedDuration: TimeInterval = 0,
        averageRestingHR: Int
    ) {
        self.id = UUID()

        self.category = category

        self.startTime = startTime
        self.endTime = endTime

        self.pausedAt = pausedAt
        self.totalPausedDuration = totalPausedDuration

        self.averageRestingHR = averageRestingHR
    }
}

extension Session {

    /// Falls back to "now" for a session that hasn't ended yet.
    var displayEndTime: Date {
        endTime ?? .now
    }

    /// Total duration including pause time.
    var elapsedTime: TimeInterval {
        displayEndTime.timeIntervalSince(startTime)
    }

    /// Total recovery duration.
    var totalRecoveryDuration: TimeInterval {

        tenseEvents.reduce(0) { partial, event in

            guard
                let start = event.recoveryStartedAt,
                let end = event.recoveryEndedAt
            else {
                return partial
            }

            return partial + end.timeIntervalSince(start)
        }
    }

    /// Duration excluding pause.
    var activeDuration: TimeInterval {

        max(
            elapsedTime - totalPausedDuration,
            0
        )
    }

    /// Active duration excluding recovery.
    var activityTime: TimeInterval {

        max(
            activeDuration - totalRecoveryDuration,
            0
        )
    }

    var allPunches: [Punch] {

        tenseEvents.flatMap(\.punchData)
    }

    var punchCount: Int {

        allPunches.count
    }

    var sortedHeartRates: [HeartRate] {

        heartRates.sorted {
            $0.timestamp < $1.timestamp
        }
    }
}


@Model
final class Punch{

    @Attribute(.unique)
    var id: UUID

    var punchIntensity: Float?
    var timestamp: Date

    var tenseEvent: TenseEvent?

    init(
        punchIntensity: Float? = nil,
        timestamp: Date = .now,
        tenseEvent: TenseEvent? = nil
    ) {
        self.id = UUID()
        self.punchIntensity = punchIntensity
        self.timestamp = timestamp
        self.tenseEvent = tenseEvent
    }
}

@Model
final class TenseEvent {

    @Attribute(.unique)
    var id: UUID

    var startingHeartRate: Int
    var detectedAt: Date
    var recoveryStartedAt: Date?
    var recoveryEndedAt: Date?

    var session: Session?

    @Relationship(deleteRule: .cascade)
    var punchData: [Punch] = []

    init(
        startingHeartRate: Int,
        detectedAt: Date = .now,
        recoveryStartedAt: Date? = nil,
        recoveryEndedAt: Date? = nil,
        session: Session? = nil
    ) {
        self.id = UUID()
        self.startingHeartRate = startingHeartRate
        self.detectedAt = detectedAt
        self.recoveryStartedAt = recoveryStartedAt
        self.recoveryEndedAt = recoveryEndedAt
        self.session = session
    }
}

extension TenseEvent {
    /// The window to shade on the heart rate chart: from detection through the end of recovery.
    /// Falls back to recoveryStartedAt if recovery hasn't ended yet, or nil if not yet started.
    var shadedRange: (start: Date, end: Date)? {
        guard let end = recoveryEndedAt ?? recoveryStartedAt else { return nil }
        return (detectedAt, end)
    }
    var recoveryDuration: TimeInterval? {

        guard let start = recoveryStartedAt,
              let end = recoveryEndedAt
        else { return nil }

        return end.timeIntervalSince(start)
    }
}


