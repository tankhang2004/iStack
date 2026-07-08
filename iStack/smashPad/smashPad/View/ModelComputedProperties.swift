//
//  ModelComputedProperties.swift
//  smashPad
//
//  IMPORTANT: elapsedTime, totalRecoveryDuration, activeDuration, activityTime,
//  allPunches, punchCount, sortedHeartRates (on Session) and shadedRange,
//  recoveryDuration (on TenseEvent) already live directly inside
//  AllModelsForCopy.swift — do NOT redeclare them here, it'll cause
//  "invalid redeclaration" build errors.
//
//  This file only adds the NEW values the redesigned summary screens need.
//

import Foundation

extension Session {

    /// Highest heart rate reading recorded during this session.
    var maxHeartRate: Int {
        heartRates.map(\.heartRateBPM).max() ?? averageRestingHR
    }

    /// Total time spent with an elevated heart rate across all tense events in this session.
    var totalTenseDuration: TimeInterval {
        tenseEvents.reduce(0) { $0 + $1.tenseDuration }
    }

    /// Average recovery time across this session's tense events (0 if none have recovered yet).
    var averageRecoveryTime: TimeInterval {
        let durations = tenseEvents.compactMap(\.recoveryDuration)
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }
}

extension TenseEvent {
    /// Duration from detection through the end of recovery (0 if not yet recovered).
    var tenseDuration: TimeInterval {
        guard let range = shadedRange else { return 0 }
        return range.end.timeIntervalSince(range.start)
    }
}
