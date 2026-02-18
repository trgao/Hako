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
        let id = "anime\(anime.id)"
        var itemList = settings.recentlyViewedItems
        itemList.removeAll(where: { $0.id == id })
        if itemList.count == 10 {
            itemList.removeFirst()
        }
        itemList.append(ListItem(id: id, anime: anime, manga: nil))
        settings.recentlyViewedItems = itemList
    }
    
    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.anime == nil {
                ErrorView(refresh: controller.refresh)
            } else if let anime = controller.anime {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            VStack {
                                ImageCarousel(id: "anime\(anime.id)", imageUrl: anime.mainPicture?.large, pictures: anime.pictures?.reversed())
                                TitleText(romaji: anime.title, english: anime.alternativeTitles?.en, japanese: anime.alternativeTitles?.ja)
                                HStack {
                                    VStack {
                                        if let myScore = controller.anime?.myListStatus?.score, myScore > 0 {
                                            Text("MAL score:")
                                                .font(.footnote)
                                        }
                                        Text("\(anime.mean == nil ? "N/A" : String(anime.mean!)) ⭐")
                                    }
                                    if let myScore = controller.anime?.myListStatus?.score, myScore > 0 {
                                        VStack {
                                            Text("Your score:")
                                                .font(.footnote)
                                            Text("\(myScore) ⭐")
                                        }
                                        .padding(.leading, 20)
                                    }
                                }
                                .bold()
                                .font(.title2)
                                .padding(.bottom, 5)
                                VStack {
                                    if let startSeason = anime.startSeason, let season = startSeason.season, let year = startSeason.year {
                                        Text("\(season.rawValue.capitalized), \(String(year))")
                                    }
                                    if let mediaType = anime.mediaType, let status = anime.status {
                                        Text("\(mediaType.formatMediaType()) ・ \(status.formatStatus())")
                                    }
                                    Text("\(anime.numEpisodes == 0 || anime.numEpisodes == nil ? "?" : String(anime.numEpisodes!)) episode\(anime.numEpisodes == 1 ? "" : "s"), \((anime.averageEpisodeDuration == 0 || anime.averageEpisodeDuration == nil) ? "?" : String(anime.averageEpisodeDuration! / 60)) minutes")
                                }
                                .opacity(0.7)
                                .font(.footnote)
                            }
                            .padding(.horizontal, 20)
                            if controller.loadingState == .loading && anime.isEmpty() {
                                ProgressView()
                            }
                            TextBox(title: "Synopsis", text: anime.synopsis)
                            if networker.isSignedIn && !settings.hideAnimeProgress && !anime.isEmpty() {
                                AnimeProgress(anime: anime, isLoading: controller.loadingState == .loading)
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
                                AnimeReviews(id: id, controller: controller, width: geometry.size.width - 34)
                            }
                        }
                        .frame(width: geometry.size.width)
                        .padding(.vertical, 20)
                    }
                    .onChange(of: networker.isSignedIn) {
                        Task {
                            await controller.refresh()
                        }
                    }
                    .refreshable {
                        isRefresh = true
                    }
                    .task(id: isRefresh) {
                        if controller.loadingState == .error || isRefresh {
                            await controller.refresh()
                            isRefresh = false
                        }
                    }
                    .background {
                        ImageFrame(id: "anime\(id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .background)
                    }
                }
            } else if controller.loadingState == .idle {
                VStack {
                    Image(systemName: "tv.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 10)
                    Text("Anime not found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if controller.loadingState == .loading && controller.anime == nil {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let anime = controller.anime, !anime.isEmpty() {
                if controller.loadingState == .loading {
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
                    .disabled(controller.loadingState == .loading)
                }
            } else if controller.loadingState == .error {
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
        .onChange(of: controller.loadingState) { prev, cur in
            if prev == .loading && cur == .idle {
                addToRecentlyViewed()
            }
        }
    }
}
