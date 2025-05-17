//
//  GeneralView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct GeneralView: View {
    @EnvironmentObject private var settings: SettingsManager
    
    var body: some View {
        List {
            Section("General") {
                Toggle(isOn: $settings.safariInApp) {
                    Text("Open links in app")
                }
                Toggle(isOn: $settings.useAccount) {
                    Text("Use app without account")
                    Text("It will hide login view and my list tab")
                }
                .onChange(of: settings.useAccount) { _, cur in
                    if cur == false && settings.defaultView == 3 {
                        settings.defaultView = 0
                    }
                }
                Toggle(isOn: $settings.recommendations) {
                    Text("Remove recommendations")
                }
            }
            Section("Launch view") {
                PickerRow(title: "Default view", selected: $settings.defaultView, array: settings.useAccount ? ["Top", "Seasons", "Search", "My List"] : ["Top", "Seasons", "Search", ""])
            }
            Section("Grid view") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                }
                PickerRow(title: "Line limit", selected: $settings.lineLimit, array: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
        }
    }
}
