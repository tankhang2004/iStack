//
//  HeartRateChartView.swift
//  smashPad
//
//  Two-tone heart rate chart: segments above the resting HR are drawn in
//  DataViz.tense (orange), segments at/below are DataViz.calm (teal). A solid
//  reference line marks the resting HR, and small ring markers show punch
//  timestamps mapped onto the nearest heart rate sample.
//

import SwiftUI

struct HeartRateChartView: View {

    let samples: [HeartRate]        // pre-sorted ascending by timestamp
    let restingHR: Int
    let punchTimestamps: [Date]
    let startTime: Date
    let endTime: Date

    private var dataMin: Double { Double(samples.map(\.heartRateBPM).min() ?? restingHR) }
    private var dataMax: Double { Double(samples.map(\.heartRateBPM).max() ?? restingHR) }
    private var chartMin: Double { min(dataMin, Double(restingHR)) - 15 }
    private var chartMax: Double { max(dataMax, Double(restingHR)) + 25 }
    private var midValue: Double { (chartMin + chartMax) / 2 }

    private var midTime: Date {
        startTime.addingTimeInterval(endTime.timeIntervalSince(startTime) / 2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            ZStack(alignment: .topTrailing) {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height

                    ZStack {
                        bands(height: height)
                        gridLines(width: width, height: height)
                        restingLine(width: width, height: height)
                        lineSegments(width: width, height: height)
                        markerDots(width: width, height: height)
                        restingValueLabel(width: width, height: height)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .frame(height: 220)

                yAxisLabels
                    .padding(.trailing, 6)
                    .padding(.top, 4)
                    .allowsHitTesting(false)
            }

            HStack {
                Text(startTime.hourDotMinuteLabel)
                Spacer()
                Text(midTime.hourDotMinuteLabel)
                Spacer()
                Text(endTime.hourDotMinuteLabel)
            }
            .font(.caption2)
            .foregroundStyle(DesignTokens.Colors.textSecondary)

            Text("\(restingHR)BPM RESTING HEART RATE")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(DesignTokens.DataViz.resting)
        }
    }

    private var yAxisLabels: some View {
        VStack {
            Text("\(Int(chartMax))")
            Spacer()
            Text("\(Int(midValue))")
            Spacer()
            Text("\(Int(chartMin))")
        }
        .font(.caption2)
        .foregroundStyle(DesignTokens.Colors.textSecondary)
    }

    // MARK: - Geometry helpers

    private func yPosition(for value: Double, height: CGFloat) -> CGFloat {
        let range = chartMax - chartMin
        guard range > 0 else { return height / 2 }
        let normalized = (value - chartMin) / range
        return height - CGFloat(normalized) * height
    }

    private func xPosition(for index: Int, width: CGFloat) -> CGFloat {
        guard samples.count > 1 else { return 0 }
        return width * CGFloat(index) / CGFloat(samples.count - 1)
    }

    private func nearestSampleIndex(to date: Date) -> Int? {
        guard !samples.isEmpty else { return nil }
        return samples.indices.min { lhs, rhs in
            abs(samples[lhs].timestamp.timeIntervalSince(date)) < abs(samples[rhs].timestamp.timeIntervalSince(date))
        }
    }

    // MARK: - Drawing

    private func bands(height: CGFloat) -> some View {
        let restingY = yPosition(for: Double(restingHR), height: height)
        return VStack(spacing: 0) {
            DesignTokens.DataViz.tense.opacity(0.18)
                .frame(height: restingY)
            DesignTokens.DataViz.calm.opacity(0.18)
                .frame(height: max(height - restingY, 0))
        }
    }

    private func gridLines(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            let columns = 4
            for i in 0...columns {
                let x = width * CGFloat(i) / CGFloat(columns)
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: height))
            }
        }
        .stroke(Color.white.opacity(0.08), style: StrokeStyle(lineWidth: 1, dash: [2, 4]))
    }

    private func restingLine(width: CGFloat, height: CGFloat) -> some View {
        let y = yPosition(for: Double(restingHR), height: height)
        return Path { path in
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
        }
        .stroke(DesignTokens.DataViz.resting, lineWidth: 1.5)
    }

    private func restingValueLabel(width: CGFloat, height: CGFloat) -> some View {
        let y = yPosition(for: Double(restingHR), height: height)
        return Text("\(restingHR)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(DesignTokens.DataViz.resting)
            .position(x: width - 14, y: max(y - 10, 10))
    }

    private func lineSegments(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            ForEach(0..<max(samples.count - 1, 0), id: \.self) { index in
                let startSample = samples[index]
                let endSample = samples[index + 1]
                let startPoint = CGPoint(
                    x: xPosition(for: index, width: width),
                    y: yPosition(for: Double(startSample.heartRateBPM), height: height)
                )
                let endPoint = CGPoint(
                    x: xPosition(for: index + 1, width: width),
                    y: yPosition(for: Double(endSample.heartRateBPM), height: height)
                )
                let average = Double(startSample.heartRateBPM + endSample.heartRateBPM) / 2
                let color = average >= Double(restingHR) ? DesignTokens.DataViz.tense : DesignTokens.DataViz.calm

                Path { path in
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
                .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
    }

    private func markerDots(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            ForEach(Array(punchTimestamps.enumerated()), id: \.offset) { _, timestamp in
                if let index = nearestSampleIndex(to: timestamp) {
                    let point = CGPoint(
                        x: xPosition(for: index, width: width),
                        y: yPosition(for: Double(samples[index].heartRateBPM), height: height)
                    )
                    Circle()
                        .fill(DesignTokens.Colors.background)
                        .overlay(Circle().stroke(DesignTokens.DataViz.marker, lineWidth: 1.5))
                        .frame(width: 8, height: 8)
                        .position(point)
                }
            }
        }
    }
}

#Preview {
    let container = PreviewSupport.makeContainer()
    let session = PreviewSupport.fetchSessions(from: container).first!

    return HeartRateChartView(
        samples: session.sortedHeartRates,
        restingHR: session.averageRestingHR,
        punchTimestamps: session.allPunches.map(\.timestamp),
        startTime: session.startTime,
        endTime: session.displayEndTime
    )
    .padding()
    .background(DesignTokens.Colors.background)
    .preferredColorScheme(.dark)
}
