//
//  MangaDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: MangaDetailsViewController
    @StateObject private var networker = NetworkManager.shared
    @State private var isEditViewPresented = false
    @State private var isRefresh = false
    private let id: Int
    
    init(id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: MangaDetailsViewController(id: id))
    }
    
    init(manga: Manga) {
        self.id = manga.id
        self._controller = StateObject(wrappedValue: MangaDetailsViewController(manga: manga))
    }
    
    private func addToRecentlyViewed() {
        guard let manga = controller.manga else {
            return
        }
        let id = "manga\(manga.id)"
        var itemList = settings.recentlyViewedItems
        itemList.removeAll(where: { $0.id == id })
        if itemList.count == 10 {
            itemList.removeFirst()
        }
        itemList.append(ListItem(id: id, anime: nil, manga: manga))
        settings.recentlyViewedItems = itemList
    }
    
    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.manga == nil {
                ErrorView(refresh: controller.refresh)
            } else if let manga = controller.manga {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            VStack {
                                ImageCarousel(id: "manga\(manga.id)", imageUrl: manga.mainPicture?.large, pictures: manga.pictures?.reversed())
                                TitleText(romaji: manga.title, english: manga.alternativeTitles?.en, japanese: manga.alternativeTitles?.ja)
                                HStack {
                                    VStack {
                                        if let myScore = manga.myListStatus?.score, myScore > 0 {
                                            Text("MAL score:")
                                                .font(.footnote)
                                        }
                                        Text("\(manga.mean == nil ? "N/A" : String(manga.mean!)) ⭐")
                                    }
                                    if let myScore = manga.myListStatus?.score, myScore > 0 {
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
                                    if let mediaType = manga.mediaType, let status = manga.status {
                                        Text("\(mediaType.formatMediaType()) ・ \(status.formatStatus())")
                                    }
                                    Text("\(manga.numVolumes == 0 || manga.numVolumes == nil ? "?" : String(manga.numVolumes!)) volume\(manga.numVolumes == 1 ? "" : "s"), \(manga.numChapters == 0 || manga.numChapters == nil ? "?" : String(manga.numChapters!)) chapter\(manga.numChapters == 1 ? "" : "s")")
                                }
                                .opacity(0.7)
                                .font(.footnote)
                            }
                            .padding(.horizontal, 20)
                            if controller.loadingState == .loading && manga.isEmpty() {
                                ProgressView()
                            }
                            TextBox(title: "Synopsis", text: manga.synopsis)
                            if networker.isSignedIn && !settings.hideMangaProgress && !manga.isEmpty() {
                                MangaProgress(manga: manga, isLoading: controller.loadingState == .loading)
                            }
                            if !settings.hideMangaInformation {
                                MangaInformation(manga: manga)
                            }
                            if !settings.hideMangaCharacters {
                                Characters(characters: controller.characters, load: controller.loadCharacters)
                            }
                            if !settings.hideAuthors {
                                Authors(authors: controller.authors, authorCount: controller.manga?.authors?.count, load: controller.loadAuthors)
                            }
                            if !settings.hideMangaRelated {
                                RelatedItems(relatedItems: controller.relatedItems, load: controller.loadRelated)
                            }
                            if !settings.hideMangaRecommendations {
                                Recommendations(mangaRecommendations: manga.recommendations)
                            }
                            if !settings.hideMangaReviews {
                                Reviews(id: id, type: .manga, reviews: controller.reviews, width: geometry.size.width - 34, load: controller.loadReviews)
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
                        ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
                    }
                }
            } else if controller.loadingState == .idle {
                VStack {
                    Image(systemName: "book.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 10)
                    Text("Manga not found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if controller.loadingState == .loading && controller.manga == nil {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let manga = controller.manga, !manga.isEmpty() {
                if controller.loadingState == .loading {
                    ProgressView()
                } else if networker.isSignedIn && !settings.useWithoutAccount {
                    Button {
                        isEditViewPresented = true
                    } label: {
                        Image(systemName: manga.myListStatus?.status == nil ? "plus" : "square.and.pencil")
                    }
                    .sheet(isPresented: $isEditViewPresented) {
                        Task {
                            await controller.loadDetails()
                        }
                    } content: {
                        MangaEditView(id: manga.id, listStatus: manga.myListStatus, title: manga.title, enTitle: manga.alternativeTitles?.en, numVolumes: manga.numVolumes, numChapters: manga.numChapters, imageUrl: controller.manga?.mainPicture?.large)
                            .presentationBackground {
                                ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
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
            ShareLink(item: URL(string: "https://myanimelist.net/manga/\(id)")!) {
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
