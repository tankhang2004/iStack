//
//  SummaryView.swift
//  smashPad
//

import SwiftUI
import SwiftData

enum SummaryTimeRange: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case allTime = "All Time"

    var id: String { rawValue }
}

struct SummaryView: View {

    @Query(sort: \Session.startTime, order: .reverse)
    private var sessions: [Session]

    @State private var selectedRange: SummaryTimeRange = .day
    @State private var anchorDate: Date = .now
    @State private var showingDatePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

                    Text("Sessions")
                        .font(DesignTokens.Typography.largeTitle)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.top, DesignTokens.Spacing.sm)

                    rangePicker
                        .padding(.horizontal, DesignTokens.Spacing.md)

                    periodButton
                        .padding(.horizontal, DesignTokens.Spacing.md)

                    statsGrid
                        .padding(.horizontal, DesignTokens.Spacing.md)

                    historySection
                        .padding(.horizontal, DesignTokens.Spacing.md)
                }
                .padding(.bottom, DesignTokens.Spacing.xl)
            }
            .background(DesignTokens.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Session.self) { session in
                SessionDetailView(session: session)
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerSheet
            }
        }
    }

    // MARK: - Range picker + period navigator

    private var rangePicker: some View {
        Picker("Time Range", selection: $selectedRange) {
            ForEach(SummaryTimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private var periodButton: some View {
        Button {
            showingDatePicker = true
        } label: {
            HStack(spacing: 4) {
                Text(periodLabel)
                    .font(.subheadline.weight(.semibold))
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(DesignTokens.Colors.textPrimary)
        }
        .buttonStyle(.plain)
        .disabled(selectedRange == .allTime)
        .opacity(selectedRange == .allTime ? 0.4 : 1)
    }

    private var datePickerSheet: some View {
        NavigationStack {
            VStack {
                DatePicker("", selection: $anchorDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(DesignTokens.Colors.accent)
                    .padding()

                Button("Jump to Today") {
                    anchorDate = .now
                }
                .foregroundStyle(DesignTokens.Colors.accent)
                .padding(.bottom)

                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showingDatePicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Stats grid

    private var statsGrid: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                statBlock(title: "Tensest Activity", value: tensestActivityName)
                Spacer()
                statBlock(title: "Total Punches", value: "\(totalPunches) Times")
                Spacer()
            }
            HStack {
                statBlock(title: "Tense Duration", value: totalTenseDuration.formattedMinSecLetters)
                Spacer()
                statBlock(title: "Avg. Recovery Time", value: averageRecoveryTimeAcrossRange.formattedMinSecLetters)
                Spacer()
            }
        }
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(DesignTokens.Colors.accent)
        }
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text("History")
                    .font(.title2.bold())
                    .foregroundStyle(DesignTokens.Colors.textPrimary)
                Text("\(filteredSessions.count) ACTIVITIES")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
            }

            if filteredSessions.isEmpty {
                emptyState
            } else {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(filteredSessions) { session in
                        NavigationLink(value: session) {
                            SessionRowView(session: session)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(DesignTokens.Colors.textSecondary)
            Text("No sessions in this period")
                .font(DesignTokens.Typography.title3)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignTokens.Spacing.lg)
    }

    // MARK: - Period math

    private var periodBounds: (start: Date, end: Date)? {
        let calendar = Calendar.current
        switch selectedRange {
        case .day:
            let start = calendar.startOfDay(for: anchorDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: anchorDate) else { return nil }
            return (interval.start, interval.end)
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: anchorDate) else { return nil }
            return (interval.start, interval.end)
        case .year:
            guard let interval = calendar.dateInterval(of: .year, for: anchorDate) else { return nil }
            return (interval.start, interval.end)
        case .allTime:
            return nil
        }
    }

    private var periodLabel: String {
        let calendar = Calendar.current
        switch selectedRange {
        case .day:
            if calendar.isDateInToday(anchorDate) { return "Today" }
            if calendar.isDateInYesterday(anchorDate) { return "Yesterday" }
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: anchorDate)
        case .week:
            if let thisWeek = calendar.dateInterval(of: .weekOfYear, for: .now), thisWeek.contains(anchorDate) {
                return "This Week"
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            if let interval = calendar.dateInterval(of: .weekOfYear, for: anchorDate) {
                return "Week of \(formatter.string(from: interval.start))"
            }
            return "This Week"
        case .month:
            if calendar.isDate(anchorDate, equalTo: .now, toGranularity: .month) { return "This Month" }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: anchorDate)
        case .year:
            if calendar.isDate(anchorDate, equalTo: .now, toGranularity: .year) { return "This Year" }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter.string(from: anchorDate)
        case .allTime:
            return "All Time"
        }
    }

    // MARK: - Filtering & aggregate stats

    private var filteredSessions: [Session] {
        guard let bounds = periodBounds else { return sessions }
        return sessions.filter { $0.startTime >= bounds.start && $0.startTime < bounds.end }
    }

    private var totalPunches: Int {
        filteredSessions.reduce(0) { $0 + $1.punchCount }
    }

    private var totalTenseDuration: TimeInterval {
        filteredSessions.reduce(0) { $0 + $1.totalTenseDuration }
    }

    private var allTenseEventsInRange: [TenseEvent] {
        filteredSessions.flatMap(\.tenseEvents)
    }

    private var averageRecoveryTimeAcrossRange: TimeInterval {
        let durations = allTenseEventsInRange.compactMap(\.recoveryDuration)
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }

    private var tensestActivityName: String {
        let groups = Dictionary(grouping: filteredSessions, by: { $0.category.id })
        let totals = groups.mapValues { sessionsInGroup in
            sessionsInGroup.reduce(0) { $0 + $1.totalTenseDuration }
        }
        guard let winner = totals.max(by: { $0.value < $1.value }), winner.value > 0 else {
            return "—"
        }
        return filteredSessions.first(where: { $0.category.id == winner.key })?.category.name ?? "—"
    }
}

// MARK: - Session Row

struct SessionRowView: View {
    let session: Session

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(session.category.name)
                    .font(DesignTokens.Typography.title3)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)

                Text("\(session.punchCount) Times")
                    .font(.title2.bold())
                    .foregroundStyle(DesignTokens.Colors.accent)
            }

            Spacer()

            Text(session.startTime.relativeDayLabel)
                .font(.subheadline)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .fill(DesignTokens.Colors.cardFill)
        )
    }
}

#Preview {
    let container = PreviewSupport.makeContainer()
    return SummaryView()
        .preferredColorScheme(.dark)
        .modelContainer(container)
}
