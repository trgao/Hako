//
//  UserProfileView.swift
//  Hako
//
//  Created by Gao Tianrun on 17/1/26.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: UserProfileViewController
    @StateObject private var networker = NetworkManager.shared
    @State private var isRefresh = false
    private let user: String
    
    init(user: String) {
        self.user = user
        self._controller = StateObject(wrappedValue: UserProfileViewController(user: user))
    }
    
    var body: some View {
        ZStack {
            if controller.isUserNotFound {
                VStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 10)
                    Text("User not found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack {
                        ScrollViewSection {
                            VStack {
                                Text(user)
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 20))
                                    .bold()
                                NavigationLink("Go to user lists") {
                                    UserListView(user: user)
                                }
                                .buttonStyle(.borderedProminent)
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
                    }
                    .padding(.bottom, 20)
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
                    ImageFrame(id: "", imageUrl: nil, imageSize: .background)
                }
            }
        }
        .toolbar {
            if controller.isLoading {
                ProgressView()
            }
            ShareLink(item: URL(string: "https://myanimelist.net/profile/\(user)")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}

