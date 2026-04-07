//
//  PickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 16/5/25.
//

import SwiftUI

struct PickerRow: View {
    @EnvironmentObject private var settings: SettingsManager
    @Binding private var selection: Int
    private let title: String
    private let labels: [String]
    private let description: String?
    
    init(title: String, selection: Binding<Int>, labels: [String], description: String? = nil) {
        self._selection = selection
        self.title = title
        self.labels = labels
        self.description = description
    }
    
    var body: some View {
        Picker(selection: $selection) {
            ForEach(labels.indices, id: \.self) { index in
                if !labels[index].isEmpty {
                    Text(labels[index]).tag(index)
                }
            }
        } label: {
            Text(title)
            if let description = description {
                Text(description)
            }
        }
        .id(settings.getAccentColor()) // to change tint when settings change
        .tint(settings.getAccentColor())
    }
}
