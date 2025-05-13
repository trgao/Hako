//
//  DateExtension.swift
//  MALC
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
}
