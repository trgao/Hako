//
//  StringExtension.swift
//  Code taken from https://stackoverflow.com/questions/41292671/separating-camelcase-string-into-space-separated-words
//

import Foundation

extension String {
    func camelCaseToWords() -> String {
        return unicodeScalars.dropFirst().reduce(String(prefix(1))) {
            return (CharacterSet.uppercaseLetters.contains($1)
                ? $0 + " " + String($1)
                    : $0 + String($1)).capitalized
        }
    }
    
    func index(of string: String) -> Index? {
        return range(of: string, options: .literal)?.lowerBound
    }
    
    func formatStatus() -> String {
        let text = self.replacingOccurrences(of: "_", with: " ")
        let first = text.prefix(1).capitalized
        return first + text.dropFirst()
    }
    
    func formatThemeSong() -> String {
        var cur = self
        if let number = cur.firstIndex(of: ":"), cur.distance(from: cur.startIndex, to: number) < 4 {
            cur = String(cur[cur.index(number, offsetBy: 2)...])
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
