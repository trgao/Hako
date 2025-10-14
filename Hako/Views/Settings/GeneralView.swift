//
//  GeneralView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI
import LocalAuthentication

struct GeneralView: View {
    @EnvironmentObject private var settings: SettingsManager
    @State private var isAuthenticationError = false
    @State private var cacheSizeString = ""
    let networker = NetworkManager.shared
    let cacheManager = CacheManager.shared
    
    var body: some View {
        List {
            Section("General") {
                Toggle(isOn: $settings.safariInApp) {
                    Text("Open links in app")
                }
                Toggle(isOn: $settings.useWithoutAccount) {
                    Text("Use app without account")
                    Text("It will hide the login view and my list tab")
                }
                .onChange(of: settings.useWithoutAccount) { _, cur in
                    if cur == true && settings.defaultView == 3 {
                        settings.defaultView = settings.hideTop ? 1 : 0
                    }
                }
                Toggle(isOn: $settings.hideTop) {
                    Text("Hide top tab")
                }
                .onChange(of: settings.hideTop) { _, cur in
                    if cur == true && settings.defaultView == 0 {
                        settings.defaultView = 1
                    }
                }
                PickerRow(title: "Preferred title language", selection: $settings.preferredTitleLanguage, labels: ["Romaji", "English"])
                PickerRow(title: "Default view", selection: $settings.defaultView, labels: [settings.hideTop ? "" : "Top", "Seasons", "Search", settings.useWithoutAccount ? "" : "My List"])
            }
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                Section("Privacy") {
                    Toggle(isOn: Binding(
                        get: { settings.useFaceID },
                        set: { value in
                            let reason = "Face ID is required to change settings"
                            
                            if !value {
                                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                                    if success {
                                        DispatchQueue.main.async {
                                            settings.useFaceID = false
                                        }
                                    } else {
                                        isAuthenticationError = true
                                    }
                                }
                            } else {
                                settings.useFaceID = true
                            }
                        }
                    )) {
                        Text("Use Face ID to lock app")
                    }
                }
            }
            Section("Grid view") {
                Toggle(isOn: $settings.truncate) {
                    Text("Truncate titles or names")
                }
                PickerRow(title: "Line limit", selection: $settings.lineLimit, labels: ["1", "2", "3"])
                    .disabled(!settings.truncate)
            }
            if networker.isSignedIn {
                Section("List view") {
                    Toggle(isOn: $settings.useSwipeActions) {
                        Text("Enable swipe actions")
                        Text("Swipe left or right on items in My List tab to increase or decrease episodes watched and \(settings.mangaReadProgress == 0 ? "chapters" : "volumes") read")
                    }
                    PickerRow(title: "Manga read progress", selection: $settings.mangaReadProgress, labels: ["Chapters", "Volumes"])
                }
                Section("Edit view") {
                    Toggle(isOn: $settings.autofillStartDate) {
                        Text("Autofill start date")
                        Text("Autofill start date when anime is changed to watching or manga is changed to reading")
                    }
                    Toggle(isOn: $settings.autofillEndDate) {
                        Text("Autofill end date")
                        Text("Autofill end date when anime or manga is changed to completed")
                    }
                }
            }
            Section {
                Button("Clear cache", role: .destructive) {
                    Task {
                        await cacheManager.clearCache()
                        cacheSizeString = await cacheManager.calculateCacheSize()
                    }
                }
            } footer: {
                Text("Cache size: \(cacheSizeString)")
                    .padding(.bottom, 10)
            }
        }
        .task {
            cacheSizeString = await cacheManager.calculateCacheSize()
        }
        .alert("Unable to change settings", isPresented: $isAuthenticationError) {
            Button("Ok") {}
        }
    }
}
