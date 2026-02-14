//
//  StringExtension.swift
//  Code taken from https://stackoverflow.com/questions/41292671/separating-camelcase-string-into-space-separated-words
//

import Foundation

extension String {
    func index(of string: String) -> Index? {
        return range(of: string, options: .literal)?.lowerBound
    }
    
    func formatMediaType() -> String {
        let cur = self.lowercased()
        if cur == "tv" || cur == "ova" || cur == "ona" || cur == "pv" {
            return cur.uppercased()
        } else if cur == "tv_special" || cur == "tv special" {
            return "Special"
        } else if cur == "one-shot" || cur == "one_shot" {
            return "Oneshot"
        } else {
            return cur.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
    
    func formatStatus() -> String {
        let text = self.replacingOccurrences(of: "_", with: " ").lowercased()
        let first = text.prefix(1).capitalized
        return first + text.dropFirst()
    }
    
    func formatThemeSong() -> String {
        var cur = self
        if let number = cur.firstIndex(of: "\""), cur.distance(from: cur.startIndex, to: number) < 6 {
            cur = String(cur[number...])
        }
        if let eps = cur.index(of: " (ep") {
            cur = String(cur[...eps])
        }
        if let eps = cur.index(of: " (TV") {
            cur = String(cur[...eps])
        }
        if let eps = cur.index(of: " (Single episodes version") {
            cur = String(cur[...eps])
        }
        return cur
    }
}
