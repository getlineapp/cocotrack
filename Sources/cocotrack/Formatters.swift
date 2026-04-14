import Foundation
import SwiftUI

extension Date {
    var clockifyISO8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }

    var shortDateTime: String {
        formatted(date: .numeric, time: .shortened)
    }
}

extension JSONDecoder {
    static var clockifyDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let formatterWithFractional = ISO8601DateFormatter()
            formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            formatterWithFractional.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = formatterWithFractional.date(from: value) {
                return date
            }

            let formatterWithoutFractional = ISO8601DateFormatter()
            formatterWithoutFractional.formatOptions = [.withInternetDateTime]
            formatterWithoutFractional.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = formatterWithoutFractional.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(value)")
        }
        return decoder
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard hex.count == 6 else { return nil }
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension JSONEncoder {
    static var clockifyEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        return encoder
    }
}

// MARK: - Duration formatting

extension Int {
    var formattedDuration: String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = self % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

// MARK: - Time entry helpers

extension ClockifyTimeEntry {
    var durationSeconds: Int? {
        guard let end = timeInterval.end else { return nil }
        return max(0, Int(end.timeIntervalSince(timeInterval.start)))
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var timeRangeText: String {
        let start = Self.timeFormatter.string(from: timeInterval.start)
        if let end = timeInterval.end {
            return "\(start) – \(Self.timeFormatter.string(from: end))"
        }
        return "\(start) – ..."
    }
}
