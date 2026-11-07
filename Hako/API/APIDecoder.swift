//
//  APIDecoder.swift
//  Hako
//
//  Created by Gao Tianrun on 6/11/26.
//

import Foundation

actor APIDecoder {
    // yyyy
    static let yearOnlyDateStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)", locale: Locale(identifier: "en_US_POSIX"), timeZone: .current, calendar: Calendar(identifier: .gregorian))
    // yyyy-MM
    static let monthOnlyDateStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)", locale: Locale(identifier: "en_US_POSIX"), timeZone: .current, calendar: Calendar(identifier: .gregorian))
    // yyyy-MM-dd
    static let normalDateStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", locale: Locale(identifier: "en_US_POSIX"), timeZone: .current, calendar: Calendar(identifier: .gregorian))
    static let iso8601DateStrategy = Date.ISO8601FormatStyle().timeZoneSeparator(.colon)

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let len = dateStr.count
            var date: Date?

            if len == 4 {
                date = try? Date(dateStr, strategy: yearOnlyDateStrategy)
            } else if len == 7 {
                date = try? Date(dateStr, strategy: monthOnlyDateStrategy)
            } else if len == 10 {
                date = try? Date(dateStr, strategy: normalDateStrategy)
            } else {
                date = try? Date(dateStr, strategy: iso8601DateStrategy)
            }
            guard let date_ = date else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
            }
            return date_
        })
        return d
    }()

    @concurrent
    static func decode<T: Decodable & Sendable>(_ type: T.Type, from data: Data) async throws -> T {
        try decoder.decode(type, from: data)
    }
}
