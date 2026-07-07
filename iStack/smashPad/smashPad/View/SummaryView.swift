//
//  SummaryView.swift
//  smashPad
//

import SwiftUI
import SwiftData

struct SummaryView: View {

    @Query(sort: \Session.startTime, order: .reverse)
    private var sessions: [Session]

    @Query(sort: \Category.name)
    private var categories: [Category]

    @State private var selectedCategory: Category?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

                    Text("Sessions")
                        .font(DesignTokens.Typography.largeTitle)
                        .foregroundStyle(DesignTokens.Colors.textPrimary)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.top, DesignTokens.Spacing.sm)

                    filterChips
                        .padding(.horizontal, DesignTokens.Spacing.md)

                    if groupedSessions.isEmpty {
                        emptyState
                    } else {
                        ForEach(groupedSessions, id: \.month) { group in
                            monthSection(group)
                        }
                    }
                }
                .padding(.bottom, DesignTokens.Spacing.xl)
            }
            .background(DesignTokens.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Session.self) { session in
                SessionDetailView(session: session)
            }
        }
    }

    // MARK: - Sections

    private func monthSection(_ group: MonthGroup) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(group.month)
                .font(.title2.bold())
                .foregroundStyle(DesignTokens.Colors.textPrimary)
                .padding(.horizontal, DesignTokens.Spacing.md)

            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(group.sessions) { session in
                    NavigationLink(value: session) {
                        SessionRowView(session: session)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                FilterChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(categories) { category in
                    FilterChip(
                        title: category.name,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        selectedCategory = category
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
            Text("No sessions yet")
                .font(DesignTokens.Typography.title3)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignTokens.Spacing.xl)
    }

    // MARK: - Grouping

    private struct MonthGroup {
        let month: String
        let sortDate: Date
        let sessions: [Session]
    }

    private var filteredSessions: [Session] {
        guard let selectedCategory else { return sessions }
        return sessions.filter { $0.category.id == selectedCategory.id }
    }

    private var groupedSessions: [MonthGroup] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: filteredSessions) { session in
            formatter.string(from: session.startTime)
        }

        return grouped
            .map { key, value -> MonthGroup in
                let sorted = value.sorted { $0.startTime > $1.startTime }
                return MonthGroup(month: key, sortDate: sorted.first?.startTime ?? .distantPast, sessions: sorted)
            }
            .sorted { $0.sortDate > $1.sortDate }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.black : DesignTokens.Colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? DesignTokens.Colors.accent : DesignTokens.Colors.chipFill)
                )
        }
        .buttonStyle(.plain)
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

                Text(session.activityTime.formattedDuration)
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
    SummaryView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [
            Category.self,
            Session.self,
            HeartRate.self,
            TenseEvent.self,
            Punch.self
        ], inMemory: true)
}
