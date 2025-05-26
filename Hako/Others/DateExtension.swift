//
//  DateExtension.swift
//  Hako
//
//  Created by Gao Tianrun on 13/5/25.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        return dateFormatterPrint.string(from: self)
    }
    
    func toFullString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "HH:mm, dd MMM yyyy"
        return dateFormatterPrint.string(from: self)
    }
    
    func toMALString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        return dateFormatterPrint.string(from: self)
    }
}
