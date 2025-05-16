//
//  MALCApp.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

@main
struct MALCApp: App {
    @StateObject private var settings = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .textSelection(.enabled)
                .environmentObject(settings)
                .preferredColorScheme(settings.getColorScheme())
                .tint(settings.getAccentColor())
        }
    }
}
