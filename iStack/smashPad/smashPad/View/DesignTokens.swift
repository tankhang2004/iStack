//
//  DesignTokens.swift
//  smashPad
//
//  Design tokens derived from the smashPad design spec.
//

import SwiftUI

enum DesignTokens {

    enum Colors {
        /// bg/base — Main screen background (tracking + summary)
        static let background = Color.black
        /// accent/purple — Primary color, play/resume button, active state highlights
        static let accent = Color(red: 125 / 255, green: 122 / 255, blue: 255 / 255) // #7D7AFF
        /// text/primary — Headlines, sub headline, text
        static let textPrimary = Color.white
        /// text/secondary — Inactive state / lower-attention text
        static let textSecondary = Color(red: 154 / 255, green: 154 / 255, blue: 158 / 255) // #9A9A9E

        static let cardFill = Color.white.opacity(0.08)
        static let chipFill = Color.white.opacity(0.12)
    }

    /// Semantic colors used specifically in heart-rate / tense-event data visualization,
    /// kept distinct from the app's purple accent so the chart reads clearly at a glance.
    enum DataViz {
        static let tense = Color(red: 1.0, green: 0.624, blue: 0.039)     // elevated heart rate
        static let calm = Color(red: 0.392, green: 0.824, blue: 1.0)      // heart rate at/below resting
        static let resting = Color(red: 0.188, green: 0.820, blue: 0.345) // resting HR reference line
        static let marker = Color(red: 1.0, green: 0.231, blue: 0.188)    // punch event markers
    }

    enum Spacing {
        static let xs: CGFloat = 4   // Icon-to-label gap
        static let sm: CGFloat = 8   // Inline gaps within a component
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)                 // Page title
        static let title2 = Font.system(size: 22, weight: .regular)                  // Activity name when tracking
        static let title3 = Font.system(size: 20, weight: .regular)                  // Notification / near-counter text
        static let counter = Font.system(size: 60, weight: .medium, design: .rounded) // Big biometric numeral
        static let timer = Font.system(size: 34, weight: .medium, design: .rounded)   // Timer
        static let symbol = Font.system(size: 40, weight: .semibold)                  // Pause/Resume SF Symbol
        static let buttonLabel = Font.system(size: 17, weight: .regular, design: .rounded) // Tracking button label
    }

    enum Radius {
        static let card: CGFloat = 16
        static let chip: CGFloat = 999
    }
}

// MARK: - Formatting helpers

extension TimeInterval {
    /// Formats a duration in seconds as "m:ss", e.g. 62 -> "1:02"
    var formattedDuration: String {
        let totalSeconds = Int(self.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Formats a duration in seconds as "Xm Ys" (or just "Xs" under a minute),
    /// e.g. 1152 -> "19m 12s", 45 -> "45s"
    var formattedMinSecLetters: String {
        let totalSeconds = Int(self.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

extension Date {
    /// "Today", "Yesterday", or "Sun, 5 Jul"
    var relativeDayLabel: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, d MMM"
            return formatter.string(from: self)
        }
    }

    /// "Sun, 5 Jul"
    var shortDayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: self)
    }

    /// "16.20"
    var hourDotMinuteLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter.string(from: self)
    }
}
