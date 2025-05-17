//
//  SettingsManager.swift
//  Hako
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI
import Foundation

@MainActor
class SettingsManager: ObservableObject {
    @AppStorage("safariInApp") var safariInApp = true
    @AppStorage("useAccount") var useAccount = true
    @AppStorage("recommendations") var recommendations = true
    @AppStorage("defaultView") var defaultView = 0
    @AppStorage("truncateTitle") var truncate = false
    @AppStorage("lineLimit") var lineLimit = 1
    @AppStorage("colorScheme") var colorScheme = 0
    @AppStorage("accentColor") var accentColor = 0
    @AppStorage("translucentBackground") var translucentBackground = true
    var colorSchemes: [ColorScheme?] = [nil, .light, .dark]
    var accentColors: [Color] = [.blue, .teal, .orange, .pink, .indigo, .purple, .green, .brown]
    
    func getLineLimit() -> Int? {
        return truncate ? lineLimit + 1 : nil
    }
    
    func getColorScheme() -> ColorScheme? {
        return colorSchemes[colorScheme]
    }
    
    func getAccentColor() -> Color {
        return accentColors[accentColor]
    }
}
