//
//  SessionDetailView.swift
//  smashPad
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {

    let session: Session

    @Environment(\.dismiss) private var dismiss

    private var timeRangeLabel: String {
        "\(session.startTime.hourDotMinuteLabel)-\(session.displayEndTime.hourDotMinuteLabel)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

                header

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(session.category.name)
                        .font(DesignTokens.Typography.title2)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)

                    Text(timeRangeLabel)
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }
                .padding(.horizontal, DesignTokens.Spacing.md)

                sectionTitle("Session Details")
                detailsCard
                    .padding(.horizontal, DesignTokens.Spacing.md)

                sectionTitle("Heart Rate")
                heartRateCard
                    .padding(.horizontal, DesignTokens.Spacing.md)
            }
            .padding(.top, DesignTokens.Spacing.sm)
            .padding(.bottom, DesignTokens.Spacing.xl)
        }
        .background(DesignTokens.Colors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text(session.startTime.shortDayLabel)
                .font(.headline)
                .foregroundStyle(DesignTokens.Colors.textPrimary)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(DesignTokens.Colors.chipFill))
                }
                Spacer()
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(DesignTokens.Colors.textPrimary)
            .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Session details card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(
                left: ("Activity Time", session.activityTime.formattedDuration),
                right: ("Elapsed Time", session.elapsedTime.formattedDuration)
            )

            Divider().overlay(Color.white.opacity(0.1))

            detailRow(
                left: ("Resting Heart Rate", "\(session.averageRestingHR)bpm"),
                right: ("Pillow Punch Frequency", "\(session.punchCount) times")
            )
        }
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .fill(DesignTokens.Colors.cardFill)
        )
    }

    private func detailRow(left: (String, String), right: (String, String)) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(left.0)
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                Text(left.1)
                    .font(.title3.bold())
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
            Spacer()
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(right.0)
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                Text(right.1)
                    .font(.title3.bold())
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
    }

    // MARK: - Heart rate card

    private var heartRateCard: some View {
        HeartRateChartView(
            samples: session.sortedHeartRates,
            tenseEvents: session.tenseEvents
        )
        .frame(height: 180)
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .fill(DesignTokens.Colors.cardFill)
        )
    }
}

//#Preview {
//    let container = try! ModelContainer(
//        for: Category.self, Session.self, HeartRate.self, TenseEvent.self, Punch.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    let context = container.mainContext
//
//    let category = Category(name: "Gaming")
//    let session = Session(
//        category: category,
//        startTime: Calendar.current.date(bySettingHour: 16, minute: 20, second: 0, of: .now)!,
//        endTime: Calendar.current.date(bySettingHour: 17, minute: 22, second: 0, of: .now)!,
//        averageRestingHR: 62
//    )
//    context.insert(category)
//    context.insert(session)
//
//    return NavigationStack {
//        SessionDetailView(session: session)
//    }
//    .preferredColorScheme(.dark)
//    .modelContainer(container)
//}


#Preview {
    let container = try! ModelContainer(
        for: Category.self, Session.self, HeartRate.self, TenseEvent.self, Punch.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext

    let category = Category(name: "Gaming")
    let startTime = Calendar.current.date(bySettingHour: 16, minute: 20, second: 0, of: .now)!
    let endTime = Calendar.current.date(bySettingHour: 17, minute: 22, second: 0, of: .now)!

    let session = Session(
        category: category,
        startTime: startTime,
        endTime: endTime,
        averageRestingHR: 62
    )

    context.insert(category)
    context.insert(session)

    // MARK: Placeholder heart rate samples
    // Walks the resting baseline up in a couple of "spikes" so the chart
    // actually has visible shape, rather than a flat line.
    let totalDuration = endTime.timeIntervalSince(startTime)
    let sampleInterval: TimeInterval = 30 // one reading every 30s
    let sampleCount = Int(totalDuration / sampleInterval)

    var heartRates: [HeartRate] = []
    for i in 0..<sampleCount {
        let timestamp = startTime.addingTimeInterval(Double(i) * sampleInterval)
        let progress = Double(i) / Double(sampleCount)

        // Gentle wobble around resting HR
        let wobble = sin(progress * .pi * 8) * 4

        // Two deliberate spikes to simulate tense moments
        let spike1 = exp(-pow((progress - 0.35) * 12, 2)) * 22
        let spike2 = exp(-pow((progress - 0.7) * 12, 2)) * 16

        let bpm = 62 + wobble + spike1 + spike2
        let heartRate = HeartRate(heartRateBPM: Int(bpm.rounded()), timestamp: timestamp, session: session)
        context.insert(heartRate)
        heartRates.append(heartRate)
    }
    session.heartRates = heartRates

    // MARK: Placeholder tense event + punches
    // Lines up with the first spike above (~35% through the session).
    let tenseStart = startTime.addingTimeInterval(totalDuration * 0.33)
    let recoveryStart = startTime.addingTimeInterval(totalDuration * 0.36)
    let recoveryEnd = startTime.addingTimeInterval(totalDuration * 0.40)

    let tenseEvent = TenseEvent(
        startingHeartRate: 84,
        detectedAt: tenseStart,
        recoveryStartedAt: recoveryStart,
        recoveryEndedAt: recoveryEnd,
        session: session
    )
    context.insert(tenseEvent)

    let punches = [
        Punch(punchIntensity: 0.8, timestamp: recoveryStart.addingTimeInterval(10), tenseEvent: tenseEvent),
        Punch(punchIntensity: 0.6, timestamp: recoveryStart.addingTimeInterval(45), tenseEvent: tenseEvent)
    ]
    punches.forEach { context.insert($0) }
    tenseEvent.punchData = punches

    session.tenseEvents = [tenseEvent]

    return NavigationStack {
        SessionDetailView(session: session)
    }
    .preferredColorScheme(.dark)
    .modelContainer(container)
}
