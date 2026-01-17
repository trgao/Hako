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
                                    .font(.system(size: 20))
                                    .bold()
                                Button("Sign Out") {
                                    isSigningOut = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    if !settings.hideUserAnimeStatistics {
                        ScrollViewSection(title: "Anime statistics") {
                            StatisticsRow(title: "Days watched", content: controller.userStatistics?.anime.daysWatched, icon: "calendar", color: .blue)
                            StatisticsRow(title: "Mean score", content: controller.userStatistics?.anime.meanScore, icon: "star.fill", color: .yellow)
                            StatisticsRow(title: "Total entries", content: controller.userStatistics?.anime.totalEntries, icon: "circle.circle", color: .primary)
                            StatisticsRow(title: "Watching", content: controller.userStatistics?.anime.watching, icon: "play.circle", color: .blue)
                            StatisticsRow(title: "Completed", content: controller.userStatistics?.anime.completed, icon: "checkmark.circle", color: .green)
                            StatisticsRow(title: "On hold", content: controller.userStatistics?.anime.onHold, icon: "pause.circle", color: .yellow)
                            StatisticsRow(title: "Plan to watch", content: controller.userStatistics?.anime.planToWatch, icon: "plus.circle.dashed", color: .purple)
                            StatisticsRow(title: "Episodes watched", content: controller.userStatistics?.anime.episodesWatched, icon: "video", color: .primary)
                        }
                    }
                    if !settings.hideUserMangaStatistics {
                        ScrollViewSection(title: "Manga statistics") {
                            StatisticsRow(title: "Days read", content: controller.userStatistics?.manga.daysRead, icon: "calendar", color: .blue)
                            StatisticsRow(title: "Mean score", content: controller.userStatistics?.manga.meanScore, icon: "star.fill", color: .yellow)
                            StatisticsRow(title: "Total entries", content: controller.userStatistics?.manga.totalEntries, icon: "circle.circle", color: .primary)
                            StatisticsRow(title: "Reading", content: controller.userStatistics?.manga.reading, icon: "book.circle", color: .blue)
                            StatisticsRow(title: "Completed", content: controller.userStatistics?.manga.completed, icon: "checkmark.circle", color: .green)
                            StatisticsRow(title: "On hold", content: controller.userStatistics?.manga.onHold, icon: "pause.circle", color: .yellow)
                            StatisticsRow(title: "Plan to read", content: controller.userStatistics?.manga.planToRead, icon: "plus.circle.dashed", color: .purple)
                            StatisticsRow(title: "Volumes read", content: controller.userStatistics?.manga.volumesRead, icon: "book.closed", color: .primary)
                            StatisticsRow(title: "Chapters read", content: controller.userStatistics?.manga.chaptersRead, icon: "book.pages", color: .primary)
                        }
                    }
                    if let userFavourites = controller.userFavourites {
                        if !controller.anime.isEmpty && !settings.hideUserFavouriteAnime {
                            ScrollViewCarousel(title: "Favourite anime", items: controller.anime) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 15) {
                                        ForEach(controller.anime) { anime in
                                            AnimeGridItem(id: anime.id, title: anime.node.title, enTitle: anime.node.alternativeTitles?.en, imageUrl: anime.node.mainPicture?.large, anime: anime.node)
                                        }
                                    }
                                    .padding(.horizontal, 17)
                                    .padding(.top, 50)
                                }
                                .padding(.top, -50)
                            }
                        }
                        if !controller.manga.isEmpty && !settings.hideUserFavouriteManga {
                            ScrollViewCarousel(title: "Favourite manga", items: controller.manga) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 15) {
                                        ForEach(controller.manga) { manga in
                                            MangaGridItem(id: manga.id, title: manga.node.title, enTitle: manga.node.alternativeTitles?.en, imageUrl: manga.node.mainPicture?.large, manga: manga.node)
                                        }
                                    }
                                    .padding(.horizontal, 17)
                                    .padding(.top, 50)
                                }
                                .padding(.top, -50)
                            }
                        }
                        if !userFavourites.characters.isEmpty && !settings.hideUserFavouriteCharacters {
                            ScrollViewCarousel(title: "Favourite characters", items: userFavourites.characters) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 15) {
                                        ForEach(userFavourites.characters) { character in
                                            CharacterGridItem(id: character.id, name: character.name, imageUrl: character.images?.jpg?.imageUrl)
                                        }
                                    }
                                    .padding(.horizontal, 17)
                                    .padding(.top, 50)
                                }
                                .padding(.top, -50)
                            }
                        }
                        if !userFavourites.people.isEmpty && !settings.hideUserFavouritePeople {
                            ScrollViewCarousel(title: "Favourite people", items: userFavourites.people) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: 15) {
                                        ForEach(userFavourites.people) { person in
                                            PersonGridItem(id: person.id, name: person.name, imageUrl: person.images?.jpg?.imageUrl)
                                        }
                                    }
                                    .padding(.horizontal, 17)
                                    .padding(.top, 50)
                                }
                                .padding(.top, -50)
                            }
                        }
                    }
                    ScrollViewSection {
                        ScrollViewLink(text: "Edit account", url: "https://myanimelist.net/editprofile.php?go=myoptions")
                            .foregroundStyle(settings.getAccentColor())
                        ScrollViewLink(text: "Delete account", url: "https://myanimelist.net/account_deletion")
                            .foregroundStyle(.red)
                    }
                    HStack {
                        Text("This will bring you to the MyAnimeList website")
                            .font(.system(size: 13))
                            .opacity(0.7)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                    if let dateString = networker.user?.joinedAt, let date = ISO8601DateFormatter().date(from: dateString) {
                        HStack {
                            Text("Joined MyAnimeList on \(date.toString())")
                                .font(.system(size: 13))
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
            .scrollContentBackground(.hidden)
            .background {
                ImageFrame(id: "userImage", imageUrl: networker.user?.picture, imageSize: .background)
            }
            .toolbar {
                ShareLink(item: URL(string: "https://myanimelist.net/profile/\(networker.user?.name ?? "")")!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

