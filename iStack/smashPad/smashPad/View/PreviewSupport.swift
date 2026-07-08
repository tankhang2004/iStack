//
//  PreviewSupport.swift
//  smashPad
//
//  Synthetic data generator used ONLY by #Preview blocks across the summary
//  screens, so canvases render realistic charts/stats without touching real
//  user data. Not compiled into release builds' behavior in any functional way.
//

import Foundation
import SwiftData

@MainActor
enum PreviewSupport {

    /// Builds an in-memory container pre-populated with a couple of categories,
    /// each with a session that has heart rate samples, tense events, and punches.
    static func makeContainer() -> ModelContainer {
        let container = try! ModelContainer(
            for: Category.self, Session.self, HeartRate.self, TenseEvent.self, Punch.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let gaming = Category(name: "Gaming")
        let coding = Category(name: "Coding")
        context.insert(gaming)
        context.insert(coding)

        let today = Calendar.current.startOfDay(for: .now)

        makeSession(
            category: gaming,
            day: today,
            startHour: 16, startMinute: 20,
            endHour: 17, endMinute: 22,
            restingHR: 62,
            tenseWindows: [(0.33, 0.40), (0.68, 0.75)],
            context: context
        )

        makeSession(
            category: coding,
            day: today,
            startHour: 13, startMinute: 5,
            endHour: 14, endMinute: 0,
            restingHR: 68,
            tenseWindows: [(0.15, 0.22), (0.45, 0.52), (0.78, 0.85)],
            context: context
        )

        // A session from a few days ago, so Week/Month/Year/All Time filters have something to show.
        if let lastWeekDay = Calendar.current.date(byAdding: .day, value: -4, to: today) {
            makeSession(
                category: gaming,
                day: lastWeekDay,
                startHour: 20, startMinute: 0,
                endHour: 21, endMinute: 10,
                restingHR: 64,
                tenseWindows: [(0.5, 0.6)],
                context: context
            )
        }

        return container
    }

    /// Fetches all sessions from a preview container, most recent first.
    static func fetchSessions(from container: ModelContainer) -> [Session] {
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }

    @discardableResult
    private static func makeSession(
        category: Category,
        day: Date,
        startHour: Int, startMinute: Int,
        endHour: Int, endMinute: Int,
        restingHR: Int,
        tenseWindows: [(Double, Double)],
        context: ModelContext
    ) -> Session {
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: day)!
        let endTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: day)!

        let session = Session(
            category: category,
            startTime: startTime,
            endTime: endTime,
            averageRestingHR: restingHR
        )
        context.insert(session)

        let totalDuration = endTime.timeIntervalSince(startTime)
        let interval: TimeInterval = 20
        let sampleCount = max(Int(totalDuration / interval), 2)

        var heartRates: [HeartRate] = []
        for i in 0..<sampleCount {
            let timestamp = startTime.addingTimeInterval(Double(i) * interval)
            let progress = Double(i) / Double(sampleCount)
            let wobble = sin(progress * .pi * 10) * 4

            var spikeContribution = 0.0
            for window in tenseWindows {
                let center = (window.0 + window.1) / 2
                let width = max(window.1 - window.0, 0.02)
                spikeContribution += exp(-pow((progress - center) / width, 2)) * 32
            }

            let bpm = Double(restingHR) + wobble + spikeContribution
            let heartRate = HeartRate(heartRateBPM: Int(bpm.rounded()), timestamp: timestamp, session: session)
            context.insert(heartRate)
            heartRates.append(heartRate)
        }
        session.heartRates = heartRates

        var tenseEvents: [TenseEvent] = []
        for window in tenseWindows {
            let detectedAt = startTime.addingTimeInterval(totalDuration * window.0)
            let recoveryStart = startTime.addingTimeInterval(totalDuration * ((window.0 + window.1) / 2))
            let recoveryEnd = startTime.addingTimeInterval(totalDuration * window.1)

            let tenseEvent = TenseEvent(
                startingHeartRate: restingHR + 25,
                detectedAt: detectedAt,
                recoveryStartedAt: recoveryStart,
                recoveryEndedAt: recoveryEnd,
                session: session
            )
            context.insert(tenseEvent)

            let punches = [
                Punch(punchIntensity: Float.random(in: 0.4...1.0), timestamp: recoveryStart.addingTimeInterval(5), tenseEvent: tenseEvent),
                Punch(punchIntensity: Float.random(in: 0.4...1.0), timestamp: recoveryStart.addingTimeInterval(20), tenseEvent: tenseEvent)
            ]
            punches.forEach { context.insert($0) }
            tenseEvent.punchData = punches

            tenseEvents.append(tenseEvent)
        }
        session.tenseEvents = tenseEvents

        return session
    }
}
