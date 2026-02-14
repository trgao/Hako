//
//  PickerRow.swift
//  Hako
//
//  Created by Gao Tianrun on 16/5/25.
//

import SwiftUI

struct PickerRow: View {
    @EnvironmentObject private var settings: SettingsManager
    @Binding var selection: Int
    var title: String
    var labels: [String]
    
    init(title: String, selection: Binding<Int>, labels: [String]) {
        self._selection = selection
        self.title = title
        self.labels = labels
    }
    
    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(labels.indices, id: \.self) { index in
                if !labels[index].isEmpty {
                    Text(labels[index]).tag(index)
                }
            }
        }
        .id(settings.getAccentColor()) // to change tint when settings change
        .tint(settings.getAccentColor())
    }
}
