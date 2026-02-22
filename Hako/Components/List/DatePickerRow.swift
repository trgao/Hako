//
//  DatePickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 22/2/26.
//

import SwiftUI

struct DatePickerRow: View {
    @EnvironmentObject private var settings: SettingsManager
    @Binding private var date: Date?
    private let title: String
    
    init(title: String, date: Binding<Date?>) {
        self._date = date
        self.title = title
    }
    
    var body: some View {
        if date != nil {
            HStack {
                DatePicker(title, selection: $date ?? Date(), displayedComponents: [.date])
                Button {
                    date = nil
                } label: {
                    Image(systemName: "xmark")
                }
            }
        } else {
            HStack {
                Text(title)
                Spacer()
                Button {
                    date = Date()
                } label: {
                    Text("Add \(title.lowercased())")
                }
            }
        }
    }
}
