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


