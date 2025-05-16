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
            Picker("App theme", selection: $settings.colorScheme) {
                Text("System").tag(0)
                Text("Light").tag(1)
                Text("Dark").tag(2)
            }
            .pickerStyle(.menu)
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
        }
    }
}
