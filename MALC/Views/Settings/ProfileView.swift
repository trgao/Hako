//
//  ProfileView.swift
//  MALC
//
//  Created by Gao Tianrun on 20/11/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var controller = ProfileViewController()
    @State private var isRefresh = false
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
                                networker.signOut()
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                }
                Section {
                    if let animeStatistics = controller.userStatistics?.anime {
                        ListRow(title: "Days watched", content: String(animeStatistics.daysWatched), icon: "calendar", color: .blue)
                        ListRow(title: "Mean score", content: String(animeStatistics.meanScore), icon: "star", color: .yellow)
                        ListRow(title: "Total entries", content: String(animeStatistics.totalEntries), icon: "circle.circle", color: .black)
                        ListRow(title: "Watching", content: String(animeStatistics.watching), icon: "play.circle", color: .blue)
                        ListRow(title: "Completed", content: String(animeStatistics.completed), icon: "checkmark.circle", color: .green)
                        ListRow(title: "On hold", content: String(animeStatistics.onHold), icon: "pause.circle", color: .yellow)
                        ListRow(title: "Plan to watch", content: String(animeStatistics.planToWatch), icon: "plus.circle.dashed", color: .cyan)
                        ListRow(title: "Episodes watched", content: String(animeStatistics.episodesWatched), icon: "video", color: .black)
                    }
                } header: {
                    Text("Anime Statistics")
                }
                Section {
                    if let mangaStatistics = controller.userStatistics?.manga {
                        ListRow(title: "Days read", content: String(mangaStatistics.daysRead), icon: "calendar", color: .blue)
                        ListRow(title: "Mean score", content: String(mangaStatistics.meanScore), icon: "star", color: .yellow)
                        ListRow(title: "Total entries", content: String(mangaStatistics.totalEntries), icon: "circle.circle", color: .black)
                        ListRow(title: "Reading", content: String(mangaStatistics.reading), icon: "play.circle", color: .blue)
                        ListRow(title: "Completed", content: String(mangaStatistics.completed), icon: "checkmark.circle", color: .green)
                        ListRow(title: "On hold", content: String(mangaStatistics.onHold), icon: "pause.circle", color: .yellow)
                        ListRow(title: "Plan to read", content: String(mangaStatistics.planToRead), icon: "plus.circle.dashed", color: .cyan)
                        ListRow(title: "Volumes read", content: String(mangaStatistics.volumesRead), icon: "book.closed", color: .black)
                        ListRow(title: "Chapters read", content: String(mangaStatistics.chaptersRead), icon: "book.pages", color: .black)
                    }
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
            if controller.isLoading {
                LoadingView()
            }
        }
    }
}

