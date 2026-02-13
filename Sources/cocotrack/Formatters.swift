import Foundation

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

extension JSONEncoder {
    static var clockifyEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        return encoder
    }
}
