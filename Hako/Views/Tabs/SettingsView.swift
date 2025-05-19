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
    @State private var isAuthenticating = false
    @State private var isLoading = false
    @State private var isLoadingError = false
    @State private var isAuthenticatingError = false
    
    private func isCancelledLoginError(_ error: Error) -> Bool {
        (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue
    }
    
    private func signIn() {
        Task {
            do {
                isAuthenticating = true
                try await networker.signIn()
                isAuthenticating = false
            } catch let error {
                isAuthenticatingError = true
                isAuthenticating = false
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !settings.useWithoutAccount {
                    Section {
                        ZStack {
                            if isAuthenticating || isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else if !networker.isSignedIn {
                                VStack {
                                    Text("Sign in to view or edit lists")
                                    Button("Sign In") {
                                        signIn()
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(5)
                            } else if let user = networker.user {
                                NavigationLink {
                                    ProfileView(user: user)
                                } label: {
                                    HStack {
                                        ProfileImage()
                                        VStack {
                                            Text(user.name ?? "")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.system(size: 20))
                                                .bold()
                                            Text("User settings")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(20)
                                    }
                                }
                            } else {
                                VStack {
                                    Text("Something went wrong")
                                    Button {
                                        Task {
                                            isLoading = true
                                            do {
                                                try await networker.getUserProfile()
                                            } catch {
                                                isLoadingError = true
                                            }
                                            isLoading = false
                                        }
                                    } label: {
                                        Text("Try again")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
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
                                .foregroundStyle(.purple)
                        }
                    }
                    NavigationLink {
                        Text("Information")
                    } label: {
                        Label {
                            Text("Information")
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Could not successfully sign in", isPresented: $isAuthenticatingError) {
                Button("Ok") {}
            }
        }
    }
}
