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
    private let url: URL
    private let colours: [StatusEnum:Color] = [
        .watching: Color(.systemGreen),
        .completed: Color(.systemBlue),
        .onHold: Color(.systemYellow),
        .dropped: Color(.systemRed),
        .planToWatch: .primary,
        .none: Color(.systemGray)
    ]
    
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
                PageList {
                    TextBox(title: "Synopsis", text: anime.synopsis)
                    if let listStatus = anime.myListStatus, networker.isSignedIn && !settings.hideAnimeProgress {
                        Section {
                            if let numEpisodes = anime.numEpisodes, numEpisodes > 0 {
                                VStack {
                                    ProgressView(value: Float(listStatus.numEpisodesWatched) / Float(numEpisodes))
                                        .tint(colours[listStatus.status ?? .none])
                                    HStack {
                                        Text(listStatus.status?.toString() ?? "")
                                            .bold()
                                        Spacer()
                                        Label("\(String(listStatus.numEpisodesWatched)) / \(String(numEpisodes))", systemImage: "video.fill")
                                            .labelStyle(CustomLabel(spacing: 2))
                                    }
                                }
                                .padding(.vertical, 10)
                            } else {
                                VStack {
                                    ProgressView(value: listStatus.numEpisodesWatched == 0 ? 0 : 0.5)
                                        .tint(colours[anime.myListStatus?.status ?? .none])
                                    HStack {
                                        Text(listStatus.status?.toString() ?? "")
                                            .bold()
                                        Spacer()
                                        Label("\(String(listStatus.numEpisodesWatched)) / ?", systemImage: "video.fill")
                                            .labelStyle(CustomLabel(spacing: 2))
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                        } header: {
                            Text("Your progress")
                                .textCase(nil)
                                .foregroundColor(Color.primary)
                                .font(.system(size: 17))
                                .bold()
                        }
                    }
                    AnimeInformation(anime: anime)
                    AnimeAiringInformation(nextEpisode: controller.nextEpisode)
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
                } photo: {
                    ImageFrame(id: "anime\(anime.id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .large)
                } title: {
                    TitleText(romaji: anime.title, english: anime.alternativeTitles?.en, japanese: anime.alternativeTitles?.ja)
                } subtitle: {
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
                .task(id: isRefresh) {
                    if isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .refreshable {
                    isRefresh = true
                }
                .scrollContentBackground(settings.translucentBackground ? .hidden : .visible)
                .background {
                    if settings.translucentBackground {
                        ImageFrame(id: "anime\(id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .background)
                    }
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
                                if settings.translucentBackground {
                                    ImageFrame(id: "anime\(id)", imageUrl: controller.anime?.mainPicture?.large, imageSize: .background)
                                } else {
                                    Color(.systemGray6)
                                }
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
                if let videos = controller.anime?.videos, !videos.isEmpty, !settings.hideTrailers {
                    NavigationLink {
                        TrailersView(videos: videos)
                    } label: {
                        Label("Trailers", systemImage: "play.rectangle")
                    }
                }
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
