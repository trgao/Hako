//
//  StringExtension.swift
//  Code taken from https://stackoverflow.com/questions/41292671/separating-camelcase-string-into-space-separated-words
//

import Foundation

extension String {
    func index(of string: String) -> Index? {
        return range(of: string, options: .literal)?.lowerBound
    }
    
    func formatRankingType() -> String {
        if self == "bypopularity" {
            return "Popularity"
        } else if self == "favorite" {
            return "Favourites"
        } else {
            return self.formatMediaType()
        }
    }
    
    func formatMediaType() -> String {
        let cur = self.lowercased()
        if cur == "tv" || cur == "ova" || cur == "ona" || cur == "pv" {
            return cur.uppercased()
        } else if cur == "tv_special" {
            return "Special"
        } else {
            return cur.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
    
    func formatStatus() -> String {
        let text = self.replacingOccurrences(of: "_", with: " ")
        let first = text.prefix(1).capitalized
        return first + text.dropFirst()
    }
    
    func formatSort() -> String {
        if self == "list_score" {
            return "By score"
        } else if self == "list_updated_at" {
            return "By last update"
        } else if self == "anime_title" || self == "manga_title" {
            return "By title"
        } else if self == "anime_start_date" || self == "manga_start_date" {
            return "By start date"
        } else {
            return ""
        }
    }
    
    func formatThemeSong() -> String {
        var cur = self
        if let number = cur.firstIndex(of: "\""), cur.distance(from: cur.startIndex, to: number) < 6 {
            cur = String(cur[number...])
        }
        if let eps = cur.index(of: " (ep") {
            cur = String(cur[...eps])
        }
        if let eps = cur.index(of: " (Single episodes version") {
            cur = String(cur[...eps])
        }
        return cur
    }
}
