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
    @StateObject var networker = NetworkManager.shared
    
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
                        Label {
                            Text("General")
                        } icon: {
                            Image(systemName: "gear")
                                .foregroundStyle(.primary)
                        }
                    }
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        Label {
                            Text("Appearance")
                        } icon: {
                            Image(systemName: "paintpalette.fill")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label {
                            Text("About")
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
