//
//  AnimeDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct AnimeDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @Namespace private var transitionNamespace
    @StateObject private var controller: AnimeDetailsViewController
    @StateObject private var networker = NetworkManager.shared
    @State private var isEditViewPresented = false
    @State private var isPicturesPresented = false
    @State private var isRefresh = false
    private let id: Int
    private let url: URL
    
    init(id: Int) {
        self.id = id
        self.url = URL(string: "https://myanimelist.net/anime/\(id)")!
        self._controller = StateObject(wrappedValue: AnimeDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.anime == nil {
                ErrorView(refresh: controller.refresh)
            } else if let anime = controller.anime {
                ScrollView {
                    VStack {
                        VStack {
                            if #available(iOS 18.0, *) {
                                Button {
                                    isPicturesPresented = true
                                } label: {
                                    ImageFrame(id: "anime\(anime.id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .large)
                                }
                                .matchedTransitionSource(id: "pictures", in: transitionNamespace)
                            } else {
                                Button {
                                    isPicturesPresented = true
                                } label: {
                                    ImageFrame(id: "anime\(anime.id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .large)
                                }
                            }
                            TitleText(romaji: anime.title, english: anime.alternativeTitles?.en, japanese: anime.alternativeTitles?.ja)
                            HStack {
                                VStack {
                                    if (controller.anime?.myListStatus?.score ?? 0) > 0 {
                                        Text("MAL score:")
                                            .font(.system(size: 13))
                                    }
                                    Text("\(anime.mean == nil ? "N/A" : String(anime.mean!)) ⭐")
                                }
                                if (controller.anime?.myListStatus?.score ?? 0) > 0 {
                                    VStack {
                                        Text("Your score:")
                                            .font(.system(size: 13))
                                        Text("\(controller.anime!.myListStatus!.score) ⭐")
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
                                    Text("\(mediaType == "tv" || mediaType == "ova" || mediaType == "ona" ? mediaType.uppercased() : mediaType.replacingOccurrences(of: "_", with: " ").capitalized) ・ \(status.formatStatus())")
                                }
                                Text("\(anime.numEpisodes == 0 || anime.numEpisodes == nil ? "?" : String(anime.numEpisodes!)) episodes, \((anime.averageEpisodeDuration == 0 || anime.averageEpisodeDuration == nil) ? "?" : String(anime.averageEpisodeDuration! / 60)) minutes")
                            }
                            .opacity(0.7)
                            .font(.system(size: 13))
                        }
                        .padding(.horizontal, 20)
                        Synopsis(text: anime.synopsis)
                        if let listStatus = anime.myListStatus, networker.isSignedIn && !settings.hideAnimeProgress {
                            AnimeProgress(numEpisodes: anime.numEpisodes, numEpisodesWatched: listStatus.numEpisodesWatched, status: listStatus.status)
                        }
                        if !settings.hideAnimeInformation {
                            AnimeInformation(anime: anime)
                        }
                        if !settings.hideAiringSchedule {
                            AnimeAiringSchedule(nextEpisode: controller.nextEpisode)
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
                        if !settings.hideAnimeStatistics {
                            AnimeStatistics(controller: controller)
                        }
                    }
                    .padding(.vertical, 20)
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
                .background {
                    ImageFrame(id: "anime\(id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .background)
                }
            }
            if controller.isLoading {
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
        .fullScreenCover(isPresented: $isPicturesPresented) {
            if #available(iOS 18.0, *) {
                ImageCarousel(pictures: controller.anime?.pictures)
                    .navigationTransition(.zoom(sourceID: "pictures", in: transitionNamespace))
            } else {
                ImageCarousel(pictures: controller.anime?.pictures)
            }
        }
        .toolbar {
            if networker.isSignedIn && !settings.useWithoutAccount {
                if let anime = controller.anime {
                    Button {
                        isEditViewPresented = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .sheet(isPresented: $isEditViewPresented) {
                        Task {
                            await controller.refresh()
                        }
                    } content: {
                        AnimeEditView(id: id, listStatus: anime.myListStatus, title: anime.title, numEpisodes: anime.numEpisodes, imageUrl: controller.anime?.mainPicture?.large)
                            .presentationBackground {
                                ImageFrame(id: "anime\(id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .background)
                            }
                    }
                    .disabled(controller.isLoading)
                } else {
                    Button {} label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .disabled(true)
                }
            }
            Menu {
                ShareLink("Share", item: url)
                Link(destination: url) {
                    Label("Open in browser", systemImage: "globe")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .handleOpenURLInApp()
            .disabled(controller.isLoading)
        }
    }
}
