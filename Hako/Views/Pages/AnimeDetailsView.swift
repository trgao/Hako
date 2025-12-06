//
//  AnimeDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct AnimeDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: AnimeDetailsViewController
    @StateObject private var networker = NetworkManager.shared
    @State private var isEditViewPresented = false
    @State private var isRefresh = false
    private let id: Int
    
    init(id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: AnimeDetailsViewController(id: id))
    }
    
    init(anime: Anime) {
        self.id = anime.id
        self._controller = StateObject(wrappedValue: AnimeDetailsViewController(anime: anime))
    }
    
    private func addToRecentlyViewed() {
        guard let anime = controller.anime else {
            return
        }
        var itemList = settings.recentlyViewedItems
        itemList.removeAll(where: { $0.id == anime.id && $0.type == .anime })
        if itemList.count == 10 {
            itemList.removeFirst()
        }
        itemList.append(ListItem(id: anime.id, title: anime.title, enTitle: anime.alternativeTitles?.en, imageUrl: anime.mainPicture?.medium, type: .anime))
        settings.recentlyViewedItems = itemList
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.anime == nil {
                ErrorView(refresh: controller.refresh)
            } else if let anime = controller.anime {
                ScrollView {
                    VStack {
                        VStack {
                            ImageCarousel(id: "anime\(anime.id)", imageUrl: anime.mainPicture?.large, pictures: anime.pictures?.reversed())
                            TitleText(romaji: anime.title, english: anime.alternativeTitles?.en, japanese: anime.alternativeTitles?.ja)
                            HStack {
                                VStack {
                                    if let myScore = controller.anime?.myListStatus?.score, myScore > 0 {
                                        Text("MAL score:")
                                            .font(.system(size: 13))
                                    }
                                    Text("\(anime.mean == nil ? "N/A" : String(anime.mean!)) ⭐")
                                }
                                if let myScore = controller.anime?.myListStatus?.score, myScore > 0 {
                                    VStack {
                                        Text("Your score:")
                                            .font(.system(size: 13))
                                        Text("\(myScore) ⭐")
                                    }
                                    .padding(.leading, 20)
                                }
                            }
                            .bold()
                            .font(.system(size: 25))
                            VStack {
                                if let startSeason = anime.startSeason, let season = startSeason.season, let year = startSeason.year {
                                    Text("\(season.capitalized), \(String(year))")
                                }
                                if let mediaType = anime.mediaType, let status = anime.status {
                                    Text("\(mediaType.formatMediaType()) ・ \(status.formatStatus())")
                                }
                                Text("\(anime.numEpisodes == 0 || anime.numEpisodes == nil ? "?" : String(anime.numEpisodes!)) episode\(anime.numEpisodes == 1 ? "" : "s"), \((anime.averageEpisodeDuration == 0 || anime.averageEpisodeDuration == nil) ? "?" : String(anime.averageEpisodeDuration! / 60)) minutes")
                            }
                            .opacity(0.7)
                            .font(.system(size: 13))
                        }
                        .padding(.horizontal, 20)
                        TextBox(title: "Synopsis", text: anime.synopsis)
                        if networker.isSignedIn && !settings.hideAnimeProgress && !anime.isEmpty() {
                            if let listStatus = anime.myListStatus, !controller.isLoading {
                                AnimeProgress(numEpisodes: anime.numEpisodes, numEpisodesWatched: listStatus.numEpisodesWatched, status: listStatus.status)
                            } else {
                                AnimeProgressNotAdded(numEpisodes: anime.numEpisodes, isLoading: controller.isLoading)
                            }
                        }
                        if !settings.hideAnimeInformation {
                            AnimeInformation(anime: anime)
                        }
                        if !settings.hideAiringSchedule {
                            AnimeAiringSchedule(controller: controller)
                        }
                        if !settings.hideTrailers {
                            Trailers(videos: anime.videos)
                        }
                        if !settings.hideAnimeCharacters {
                            AnimeCharacters(controller: controller)
                        }
                        if !settings.hideStaffs {
                            Staffs(controller: controller)
                        }
                        if !settings.hideAnimeRelated {
                            AnimeRelatedItems(controller: controller)
                        }
                        if !settings.hideAnimeRecommendations {
                            Recommendations(animeRecommendations: anime.recommendations)
                        }
                        if !settings.hideThemeSongs {
                            ThemeSongs(openingThemes: anime.openingThemes, endingThemes: anime.endingThemes)
                        }
                        if !settings.hideAnimeReviews {
                            AnimeReviews(id: id, controller: controller)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onChange(of: networker.isSignedIn) {
                    Task {
                        await controller.refresh()
                    }
                }
                .onChange(of: controller.isLoading) { prev, cur in
                    if prev && !cur {
                        addToRecentlyViewed()
                    }
                }
                .task(id: isRefresh) {
                    if isRefresh || controller.isLoadingError {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .refreshable {
                    isRefresh = true
                }
                .background {
                    ImageFrame(id: "anime\(id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .background)
                }
            }
            if controller.isLoading && (controller.anime == nil || controller.anime!.isEmpty()) {
                LoadingView()
            }
            if controller.anime == nil && !controller.isLoading && !controller.isLoadingError {
                VStack {
                    Image(systemName: "tv.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("Nothing found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let anime = controller.anime {
                if controller.isLoading && !anime.isEmpty() {
                    ProgressView()
                } else if networker.isSignedIn && !settings.useWithoutAccount {
                    Button {
                        isEditViewPresented = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .sheet(isPresented: $isEditViewPresented) {
                        Task {
                            await controller.loadDetails()
                        }
                    } content: {
                        AnimeEditView(id: id, listStatus: anime.myListStatus, title: anime.title, enTitle: anime.alternativeTitles?.en, numEpisodes: anime.numEpisodes, imageUrl: controller.anime?.mainPicture?.large)
                            .presentationBackground {
                                ImageFrame(id: "anime\(id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .background)
                            }
                    }
                    .disabled(controller.isLoading)
                }
            } else if controller.isLoadingError {
                Button {
                    Task {
                        await controller.refresh()
                    }
                } label: {
                    Image(systemName: "exclamationmark.triangle")
                }
            }
            ShareLink(item: URL(string: "https://myanimelist.net/anime/\(id)")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}
