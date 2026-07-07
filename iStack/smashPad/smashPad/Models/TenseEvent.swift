//
//  TenseEvent.swift
//  smashPad
//
//  Created by Stevanus Felixiano on 06/07/26.
//

import Foundation
import SwiftData

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
}
