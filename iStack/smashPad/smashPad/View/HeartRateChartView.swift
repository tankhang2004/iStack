//
//  HeartRateChartView.swift
//  smashPad
//
//  Custom line chart (no Charts framework dependency) so the shaded
//  "tense" regions under peaks can be drawn exactly as in the design.
//

import SwiftUI

struct HeartRateChartView: View {

    let samples: [HeartRate]      // must be pre-sorted by timestamp ascending
    let tenseEvents: [TenseEvent]

    private var minValue: Double {
        Double((samples.map(\.heartRateBPM).min() ?? 60) - 5)
    }

    private var maxValue: Double {
        max(Double((samples.map(\.heartRateBPM).max() ?? 80) + 5), minValue + 20)
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("\(Int(maxValue))")
                .font(.caption)
                .foregroundStyle(DesignTokens.Colors.textSecondary)

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    baselineDashedLine(width: width, height: height)
                    tenseShading(width: width, height: height)
                    heartRateLine(width: width, height: height)
                }
            }

            Text("\(Int(minValue))")
                .font(.caption)
                .foregroundStyle(DesignTokens.Colors.textSecondary)
        }
    }

    // MARK: - Geometry helpers

    private func yPosition(for value: Double, height: CGFloat) -> CGFloat {
        let range = maxValue - minValue
        guard range > 0 else { return height / 2 }
        let normalized = (value - minValue) / range
        return height - (CGFloat(normalized) * height)
    }

    private func xPosition(for index: Int, width: CGFloat) -> CGFloat {
        guard samples.count > 1 else { return 0 }
        return width * CGFloat(index) / CGFloat(samples.count - 1)
    }

    // MARK: - Drawing

    private func heartRateLine(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            guard !samples.isEmpty else { return }
            for (index, sample) in samples.enumerated() {
                let point = CGPoint(
                    x: xPosition(for: index, width: width),
                    y: yPosition(for: Double(sample.heartRateBPM), height: height)
                )
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
        }
        .stroke(DesignTokens.Colors.textPrimary.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
    }

    private func baselineDashedLine(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            let y = yPosition(for: minValue + 5, height: height)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
        }
        .stroke(DesignTokens.Colors.textSecondary, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
    }

    private func tenseShading(width: CGFloat, height: CGFloat) -> some View {
        ForEach(tenseEvents) { event in
            tenseShape(for: event, width: width, height: height)
                .fill(DesignTokens.Colors.textPrimary.opacity(0.15))
        }
    }

    private func tenseShape(for event: TenseEvent, width: CGFloat, height: CGFloat) -> Path {
        Path { path in
            guard
                let range = event.shadedRange,
                let startIndex = samples.firstIndex(where: { $0.timestamp >= range.start }),
                let endIndex = samples.lastIndex(where: { $0.timestamp <= range.end }),
                startIndex < endIndex
            else { return }

            path.move(to: CGPoint(x: xPosition(for: startIndex, width: width), y: height))
            for index in startIndex...endIndex {
                path.addLine(to: CGPoint(
                    x: xPosition(for: index, width: width),
                    y: yPosition(for: Double(samples[index].heartRateBPM), height: height)
                ))
            }
            path.addLine(to: CGPoint(x: xPosition(for: endIndex, width: width), y: height))
            path.closeSubpath()
        }
    }
}
