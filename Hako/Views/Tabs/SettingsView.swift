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
    @State private var isJikanDown = false
    @State private var isLoadingStatus = false
    @Binding private var id: UUID
    @Binding private var isProfileActive: Bool
    
    init(id: Binding<UUID>, isProfileActive: Binding<Bool>) {
        self._id = id
        self._isProfileActive = isProfileActive
    }
    
    // Checking health of Jikan API
    private func loadJikanStatus() async {
        isLoadingStatus = true
        do {
            let status = try await networker.getJikanAPIStatus()
            isJikanDown = status.status != nil || status.myanimelistHeartbeat?.status != "HEALTHY" || status.myanimelistHeartbeat?.down == true
        } catch {
            isJikanDown = true
        }
        isLoadingStatus = false
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
                }
                if !ProcessInfo.processInfo.isMacCatalystApp {
                    Section {
                        NavigationLink {
                            SafariExtensionView()
                        } label: {
                            Label("Safari extension", systemImage: "puzzlepiece.extension.fill")
                        }
                    }
                }
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                    Link(destination: URL(string: "https://forms.gle/v2ewpgxHLDL16kK8A")!) {
                        Label("Feedback", systemImage: "exclamationmark.bubble.fill")
                    }
                }
                Section {
                    HStack {
                        Label("Jikan API status", systemImage: "cloud.fill")
                        Spacer()
                        if isLoadingStatus {
                            Text("Placeholder")
                                .skeleton()
                        } else if isJikanDown {
                            Text("Degraded")
                                .foregroundStyle(.orange)
                                .bold()
                        } else {
                            Text("Healthy")
                                .foregroundStyle(.green)
                                .bold()
                        }
                    }
                } footer: {
                    if isJikanDown {
                        Text("Some parts of the app may not load properly because parts of Jikan API might be down. ")
                    }
                }
            }
            .padding(.bottom, 10)
            .navigationTitle("Settings")
            .navigationDestination(isPresented: $isProfileActive) {
                ProfileView()
            }
            .task {
                await loadJikanStatus()
            }
        }
        .id(id)
    }
}
