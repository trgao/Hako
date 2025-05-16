//
//  SettingsManager.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI
import Foundation

@MainActor
class SettingsManager: ObservableObject {
    @AppStorage("colorScheme") var colorScheme = 0
    @AppStorage("accentColor") var accentColor = 0
    @AppStorage("defaultView") var defaultView = 0
    var colorSchemes: [ColorScheme?] = [nil, .light, .dark]
    var accentColors: [Color] = [.blue, .teal, .orange, .pink, .purple, .green, .brown, .primary]
    
    func getColorScheme() -> ColorScheme? {
        return colorSchemes[colorScheme]
    }
    
    func getAccentColor() -> Color {
        return accentColors[accentColor]
    }
}
