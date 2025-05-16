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
    
    func formatStatus() -> String {
        let text = self.replacingOccurrences(of: "_", with: " ")
        let first = text.prefix(1).capitalized
        return first + text.dropFirst()
    }
}
