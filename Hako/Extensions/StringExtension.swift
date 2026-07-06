//
//  StringExtension.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import Foundation

extension String {
    var decoded: String {
        let attr = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil)

        return attr?.string ?? self
    }
    
    func index(of string: String) -> Index? {
        return range(of: string, options: .literal)?.lowerBound
    }
    
    func initialCapitalise() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
    
    func formatMediaType() -> String {
        let cur = self.lowercased()
        if cur.count <= 3 {
            return cur.uppercased()
        } else if cur == "tv_special" || cur == "tv special" {
            return "Special"
        } else if cur == "one-shot" || cur == "one_shot" {
            return "Oneshot"
        } else {
            let text = cur.replacingOccurrences(of: "_", with: " ")
            return text.initialCapitalise()
        }
    }
    
    func formatStatus() -> String {
        let text = self.replacingOccurrences(of: "_", with: " ").lowercased()
        return text.initialCapitalise()
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
    
    func toSnakeCase() -> String {
        return self.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}
