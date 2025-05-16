//
//  AnimeDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct AnimeDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject var controller: AnimeDetailsViewController
    @State private var synopsisLines = 4
    @State private var isShowingMore = false
    @State private var isShowingSafariView = false
    @State private var isEditViewPresented = false
    @State private var isRefresh = false
    private let id: Int
    private let imageUrl: String?
    private let url: URL
    let networker = NetworkManager.shared
    
    init(id: Int, imageUrl: String?) {
        self.id = id
        self.imageUrl = imageUrl
        self.url = URL(string: "https://myanimelist.net/anime/\(id)")!
        self._controller = StateObject(wrappedValue: AnimeDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if (controller.isLoadingError) {
                ErrorView(refresh: controller.refresh)
            } else if let anime = controller.anime {
                PageList {
                    TextBox(title: "Synopsis", text: anime.synopsis)
                    AnimeInformation(anime: anime)
                    AnimeCharacters(controller: controller)
                    Staffs(controller: controller)
                    AnimeRelatedItems(controller: controller)
                    Recommendations(animeRecommendations: anime.recommendations)
                    ThemeSongs(openingThemes: anime.openingThemes, endingThemes: anime.endingThemes)
                    AnimeStatistics(controller: controller)
                } header: {
                    ImageFrame(id: "anime\(anime.id)", imageUrl: imageUrl, imageSize: .large)
                        .padding([.top], 10)
                    Text(anime.title)
                        .bold()
                        .font(.system(size: 25))
                        .padding(.horizontal, 10)
                        .multilineTextAlignment(.center)
                    if let japaneseTitle = anime.alternativeTitles?.ja {
                        Text(japaneseTitle)
                            .padding([.horizontal, .bottom], 10)
                            .font(.system(size: 18))
                            .opacity(0.7)
                            .multilineTextAlignment(.center)
                    }
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
                    .padding(.bottom, 5)
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
                    .font(.system(size: 12))
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
                        ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .background)
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
                    Text("Nothing found. ")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingSafariView) {
            SafariView(url: url)
        }
        .toolbar {
            if networker.isSignedIn {
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
                        AnimeEditView(id: id, listStatus: anime.myListStatus, title: anime.title, numEpisodes: anime.numEpisodes, imageUrl: imageUrl, isPresented: $isEditViewPresented)
                            .presentationBackground {
                                if settings.translucentBackground {
                                    ImageFrame(id: "anime\(id)", imageUrl: imageUrl, imageSize: .background)
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
                NavigationLink {
                    TrailersView(videos: controller.anime?.videos)
                } label: {
                    Label("Trailers", systemImage: "play.rectangle")
                }
                if settings.safariInApp {
                    Button {
                        isShowingSafariView = true
                    } label: {
                        Label("Open in browser", systemImage: "globe")
                    }
                } else {
                    Link(destination: url) {
                        Label("Open in browser", systemImage: "globe")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .disabled(controller.isLoading)
        }
    }
}
