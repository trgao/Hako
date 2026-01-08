//
//  SignInSections.swift
//  Hako
//
//  Created by Gao Tianrun on 19/5/25.
//

import SwiftUI
import AuthenticationServices

struct SignInSections: View {
    @StateObject var networker = NetworkManager.shared
    @State private var isAuthenticating = false
    @State private var isAuthenticatingError = false
    @State private var isLoading = false
    @State private var isLoadingError = false
    private let isSettings: Bool
    
    init(isSettings: Bool = false) {
        self.isSettings = isSettings
    }
    
    private func signIn() {
        Task {
            do {
                isAuthenticating = true
                try await networker.signIn()
                isAuthenticating = false
            } catch {
                isAuthenticatingError = true
                isAuthenticating = false
            }
        }
    }
    
    var body: some View {
        Section {
            ZStack {
                if isAuthenticating || isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if !networker.isSignedIn {
                    VStack {
                        Text("You need to sign in to your MyAnimeList account in order to view and edit your anime or manga lists")
                            .multilineTextAlignment(.center)
                        Button("Sign In") {
                            signIn()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(5)
                } else if isSettings {
                    if let user = networker.user {
                        NavigationLink {
                            ProfileView(user: user)
                        } label: {
                            HStack {
                                ProfileImage(imageUrl: user.picture)
                                VStack {
                                    Text(user.name ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(size: 20))
                                        .bold()
                                    Text("User profile")
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
        .alert("Could not successfully sign in", isPresented: $isAuthenticatingError) {
            Button("Ok") {}
        }
        if !networker.isSignedIn {
            Section {
                Text("You can create a MyAnimeList account by signing up at **[MyAnimeList](https://myanimelist.net/register.php)**")
                    .multilineTextAlignment(.center)
            }
        }
    }
}
