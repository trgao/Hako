//
//  AppearanceView.swift
//  MALC
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct AppearanceView: View {
    @EnvironmentObject private var settings: SettingsManager
    
    var body: some View {
        List {
            Section("Grid view") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                }
                PickerRow(title: "Line limit", selected: $settings.lineLimit, array: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
            PickerRow(title: "App theme", selected: $settings.colorScheme, array: ["System", "Light", "Dark"])
            Section {
                HStack {
                    ForEach(Array(settings.accentColors.enumerated()), id: \.offset) { index, color in
                        Button {
                            settings.accentColor = index
                        } label: {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(color)
                                .tag(index)
                        }
                        .buttonStyle(.plain)
                        .padding(2)
                        .overlay {
                            if settings.accentColor == index {
                                Circle()
                                    .stroke(color, lineWidth: 2)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } header: {
                Text("Accent color")
            }
            Section("Accessibility") {
                Toggle(isOn: $settings.translucentBackground) {
                    Text("Allow translucent backgrounds")
                }
            }
        }
    }
}
