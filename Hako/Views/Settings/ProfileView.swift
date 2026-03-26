//
//  ProfileView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = UserProfileViewController()
    @StateObject private var networker = NetworkManager.shared
    @State private var isRefresh = false
    @State private var isSigningOut = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ScrollViewSection {
                        HStack {
                            ProfileImage(imageUrl: networker.user?.picture, username: networker.user?.name, allowExpand: true)
                            VStack {
                                Text("Hello, \(networker.user?.name ?? "")")
                                    .frame(maxWidth: .infinity)
                                    .font(.title3)
                                    .bold()
                                Button("Sign Out") {
                                    isSigningOut = true
                                }
                                .tint(.red)
                                .confirmationDialog("Are you sure?", isPresented: $isSigningOut) {
                                    Button("Confirm", role: .destructive) {
                                        Task {
                                            networker.signOut()
                                            dismiss()
                                        }
                                    }
                                } message: {
                                    Text("This will sign you out of your account")
                                }
                                .prominentButtonStyle()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    UserStatisticsInformation(userStatistics: controller.userStatistics, loadingState: controller.loadingState)
                    UserFavouritesInformation(anime: controller.anime, manga: controller.manga, characters: controller.characters, people: controller.people, loadingState: controller.favouritesLoadingState, load: controller.loadFavourites)
                    ScrollViewSection {
                        ScrollViewLink(text: "Import list", url: "https://myanimelist.net/import.php")
                            .foregroundStyle(settings.getAccentColor())
                        ScrollViewLink(text: "Account settings", url: "https://myanimelist.net/editprofile.php?go=myoptions")
                            .foregroundStyle(settings.getAccentColor())
                        ScrollViewLink(text: "Delete account", url: "https://myanimelist.net/account_deletion")
                            .foregroundStyle(.red)
                    }
                    HStack {
                        Text("This will bring you to the MyAnimeList website")
                            .font(.footnote)
                            .opacity(0.7)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    if let dateString = networker.user?.joinedAt, let date = ISO8601DateFormatter().date(from: dateString) {
                        HStack {
                            Text("Joined MyAnimeList on \(date.toString())")
                                .font(.footnote)
                                .opacity(0.7)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                    }
                }
            }
            .refreshable {
                isRefresh = true
            }
            .task(id: isRefresh) {
                await controller.refresh()
                isRefresh = false
            }
            .scrollContentBackground(.hidden)
            .background {
                ImageFrame(id: "userImage", imageUrl: networker.user?.picture, imageSize: .background)
            }
            .toolbar {
                if controller.loadingState == .error {
                    Button {
                        Task {
                            await controller.refresh()
                        }
                    } label: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
                ShareLink(item: URL(string: "https://myanimelist.net/profile/\(networker.user?.name ?? "")")!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

