//
//  ProfileView.swift
//  Hako
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = ProfileViewController()
    @State private var isRefresh = false
    @State private var isSigningOut = false
    private var user: User
    let networker = NetworkManager.shared
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        ZStack {
            List {
                Section {
                    HStack {
                        ProfileImage()
                        VStack {
                            Text("Hello, \(user.name ?? "")")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 20))
                                .bold()
                            Button("Sign Out") {
                                isSigningOut = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                }
                Section {
                    ListRow(title: "Days watched", content: controller.userStatistics?.anime.daysWatched, icon: "calendar", color: .blue)
                    ListRow(title: "Mean score", content: controller.userStatistics?.anime.meanScore, icon: "star", color: .yellow)
                    ListRow(title: "Total entries", content: controller.userStatistics?.anime.totalEntries, icon: "circle.circle", color: .primary)
                    ListRow(title: "Watching", content: controller.userStatistics?.anime.watching, icon: "play.circle", color: .blue)
                    ListRow(title: "Completed", content: controller.userStatistics?.anime.completed, icon: "checkmark.circle", color: .green)
                    ListRow(title: "On hold", content: controller.userStatistics?.anime.onHold, icon: "pause.circle", color: .yellow)
                    ListRow(title: "Plan to watch", content: controller.userStatistics?.anime.planToWatch, icon: "plus.circle.dashed", color: .purple)
                    ListRow(title: "Episodes watched", content: controller.userStatistics?.anime.episodesWatched, icon: "video", color: .primary)
                } header: {
                    Text("Anime Statistics")
                }
                Section {
                    ListRow(title: "Days read", content: controller.userStatistics?.manga.daysRead, icon: "calendar", color: .blue)
                    ListRow(title: "Mean score", content: controller.userStatistics?.manga.meanScore, icon: "star", color: .yellow)
                    ListRow(title: "Total entries", content: controller.userStatistics?.manga.totalEntries, icon: "circle.circle", color: .primary)
                    ListRow(title: "Reading", content: controller.userStatistics?.manga.reading, icon: "play.circle", color: .blue)
                    ListRow(title: "Completed", content: controller.userStatistics?.manga.completed, icon: "checkmark.circle", color: .green)
                    ListRow(title: "On hold", content: controller.userStatistics?.manga.onHold, icon: "pause.circle", color: .yellow)
                    ListRow(title: "Plan to read", content: controller.userStatistics?.manga.planToRead, icon: "plus.circle.dashed", color: .purple)
                    ListRow(title: "Volumes read", content: controller.userStatistics?.manga.volumesRead, icon: "book.closed", color: .primary)
                    ListRow(title: "Chapters read", content: controller.userStatistics?.manga.chaptersRead, icon: "book.pages", color: .primary)
                } header: {
                    Text("Manga Statistics")
                }
                Section {
                    Link("Delete Account", destination: URL(string: "https://myanimelist.net/account_deletion")!)
                        .foregroundStyle(.red)
                } footer: {
                    Text("This will bring you to the MyAnimeList website")
                }
                Section {} footer: {
                    if let dateString = user.joinedAt, let date = ISO8601DateFormatter().date(from: dateString) {
                        Text("Joined MyAnimeList on \(date.toString())")
                    }
                }
            }
            .task {
                await controller.refresh()
            }
            .task(id: isRefresh) {
                if isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .refreshable {
                isRefresh = true
            }
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
        }
    }
}

