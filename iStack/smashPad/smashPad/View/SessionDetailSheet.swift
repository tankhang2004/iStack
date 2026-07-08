//
//  SessionDetailsSheet.swift
//  smashPad
//
//  Modal presented from SessionDetailView's "Session Details" disclosure.
//  Shows condensed tense/punch/recovery stats plus the full heart rate chart.
//

import SwiftUI
import SwiftData

struct SessionDetailsSheet: View {

    let session: Session

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

                statsSection

                sectionTitle("Heart Rate")
                    .padding(.horizontal, DesignTokens.Spacing.md)

                HeartRateChartView(
                    samples: session.sortedHeartRates,
                    restingHR: session.averageRestingHR,
                    punchTimestamps: session.allPunches.map(\.timestamp),
                    startTime: session.startTime,
                    endTime: session.displayEndTime
                )
                .padding(.horizontal, DesignTokens.Spacing.md)
            }
            .padding(.top, DesignTokens.Spacing.md)
            .padding(.bottom, DesignTokens.Spacing.xl)
        }
        .background(DesignTokens.Colors.background.ignoresSafeArea())
        .safeAreaInset(edge: .top) { header }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(DesignTokens.Colors.chipFill))
            }

            Spacer()

            Text("Session Details")
                .font(.headline)
                .foregroundStyle(DesignTokens.Colors.textPrimary)

            Spacer()

            // Balances the close button so the title stays centered.
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.sm)
        .padding(.bottom, DesignTokens.Spacing.sm)
        .background(DesignTokens.Colors.background)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(DesignTokens.Colors.textPrimary)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                statBlock(
                    title: "Tense Duration",
                    value: session.totalTenseDuration.formattedMinSecLetters,
                    color: DesignTokens.DataViz.tense
                )
                Spacer()
                statBlock(
                    title: "Punch Frequency",
                    value: "\(session.punchCount) Times",
                    color: DesignTokens.DataViz.marker
                )
                Spacer()
            }

            statBlock(
                title: "Avg. Recovery Time",
                value: session.averageRecoveryTime.formattedMinSecLetters,
                color: DesignTokens.DataViz.calm
            )
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    private func statBlock(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
        }
    }
}

#Preview {
    let container = PreviewSupport.makeContainer()
    let session = PreviewSupport.fetchSessions(from: container).first { $0.category.name == "Gaming" }!

    return Color.clear
        .sheet(isPresented: .constant(true)) {
            SessionDetailsSheet(session: session)
        }
        .preferredColorScheme(.dark)
        .modelContainer(container)
}
