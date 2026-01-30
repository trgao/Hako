//
//  SettingsView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var networker = NetworkManager.shared
    @Binding private var id: UUID
    @Binding private var isProfileActive: Bool
    
    init(id: Binding<UUID>, isProfileActive: Binding<Bool>) {
        self._id = id
        self._isProfileActive = isProfileActive
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !settings.useWithoutAccount {
                    SignInSections(isSettings: true)
                }
                Section {
                    NavigationLink {
                        GeneralView()
                    } label: {
                        Label("General", systemImage: "gear")
                    }
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        Label("Appearance", systemImage: "paintpalette.fill")
                    }
                    NavigationLink {
                        HideItemsView()
                    } label: {
                        Label("Hide items", systemImage: "eye.slash.fill")
                    }
                    NavigationLink {
                        SafariExtensionView()
                    } label: {
                        Label("Safari extension", systemImage: "puzzlepiece.extension.fill")
                    }
                }
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle.fill")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(isPresented: $isProfileActive) {
                ProfileView()
            }
        }
        .id(id)
    }
}
