//
//  SessionDetailView.swift
//  smashPad
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {

    let session: Session

    @Environment(\.dismiss) private var dismiss
    @State private var showDetailSheet = false

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

                sessionDetailsDisclosure
                detailsCard
                    .padding(.horizontal, DesignTokens.Spacing.md)
            }
            .padding(.top, DesignTokens.Spacing.sm)
            .padding(.bottom, DesignTokens.Spacing.xl)
        }
        .background(DesignTokens.Colors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showDetailSheet) {
            SessionDetailsSheet(session: session)
        }
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

    private var sessionDetailsDisclosure: some View {
        Button {
            showDetailSheet = true
        } label: {
            HStack(spacing: 6) {
                Text("Session Details")
                    .font(.title3.bold())
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    // MARK: - Session details card

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Elapsed Time")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                Text(session.elapsedTime.formattedDuration)
                    .font(.title2.bold())
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
            .padding(DesignTokens.Spacing.md)

            Divider().overlay(Color.white.opacity(0.1))

            detailRow(
                left: ("Punch Frequency", "\(session.punchCount) Times"),
                right: ("Tense Duration", session.totalTenseDuration.formattedMinSecLetters)
            )

            Divider().overlay(Color.white.opacity(0.1))

            detailRow(
                left: ("Resting Heart Rate", "\(session.averageRestingHR)BPM"),
                right: ("Max Heart Rate", "\(session.maxHeartRate)BPM")
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
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                Text(left.1)
                    .font(.title3.bold())
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
            Spacer()
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(right.0)
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                Text(right.1)
                    .font(.title3.bold())
                    .foregroundStyle(DesignTokens.Colors.accent)
            }
            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
    }
}

#Preview {
    let container = PreviewSupport.makeContainer()
    let session = PreviewSupport.fetchSessions(from: container).first { $0.category.name == "Gaming" }!

    return NavigationStack {
        SessionDetailView(session: session)
    }
    .preferredColorScheme(.dark)
    .modelContainer(container)
}
