//
//  DateExtension.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import Foundation

extension Date {
    // MMM dd, yyyy
    func toString() -> String {
        return self.formatted(Date.VerbatimFormatStyle(format: "\(month: .abbreviated) \(day: .twoDigits), \(year: .defaultDigits)", locale: Locale(identifier: "en_US_POSIX"), timeZone: .current, calendar: Calendar(identifier: .gregorian)))
    }

    // hh:mm a, dd MMM yyyy
    func toFullString() -> String {
        return self.formatted(Date.VerbatimFormatStyle(format: "\(hour: .twoDigits(clock: .twelveHour, hourCycle: .oneBased)):\(minute: .twoDigits) \(dayPeriod: .standard(.abbreviated)), \(day: .twoDigits) \(month: .abbreviated) \(year: .defaultDigits)", locale: Locale(identifier: "en_US_POSIX"), timeZone: .current, calendar: Calendar(identifier: .gregorian)))
    }

    // yyyy-MM-dd
    func toMALString() -> String {
        return self.formatted(Date.VerbatimFormatStyle(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", locale: Locale(identifier: "en_US_POSIX"), timeZone: .current, calendar: Calendar(identifier: .gregorian)))
    }
}
