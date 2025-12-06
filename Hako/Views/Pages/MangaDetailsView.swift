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
        var itemList = settings.recentlyViewedItems
        itemList.removeAll(where: { $0.id == manga.id && $0.type == .manga })
        if itemList.count == 10 {
            itemList.removeFirst()
        }
        itemList.append(ListItem(id: manga.id, title: manga.title, enTitle: manga.alternativeTitles?.en, imageUrl: manga.mainPicture?.medium, type: .manga))
        settings.recentlyViewedItems = itemList
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.manga == nil {
                ErrorView(refresh: controller.refresh)
            } else if let manga = controller.manga {
                ScrollView {
                    VStack {
                        VStack {
                            ImageCarousel(id: "manga\(manga.id)", imageUrl: manga.mainPicture?.large, pictures: manga.pictures?.reversed())
                            TitleText(romaji: manga.title, english: manga.alternativeTitles?.en, japanese: manga.alternativeTitles?.ja)
                            HStack {
                                VStack {
                                    if let myScore = manga.myListStatus?.score, myScore > 0 {
                                        Text("MAL score:")
                                            .font(.system(size: 13))
                                    }
                                    Text("\(manga.mean == nil ? "N/A" : String(manga.mean!)) ⭐")
                                }
                                if let myScore = manga.myListStatus?.score, myScore > 0 {
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
                                if let mediaType = manga.mediaType, let status = manga.status {
                                    Text("\(mediaType.formatMediaType()) ・ \(status.formatStatus())")
                                }
                                Text("\(manga.numVolumes == 0 || manga.numVolumes == nil ? "?" : String(manga.numVolumes!)) volume\(manga.numVolumes == 1 ? "" : "s"), \(manga.numChapters == 0 || manga.numChapters == nil ? "?" : String(manga.numChapters!)) chapter\(manga.numChapters == 1 ? "" : "s")")
                            }
                            .opacity(0.7)
                            .font(.system(size: 13))
                        }
                        .padding(.horizontal, 20)
                        TextBox(title: "Synopsis", text: manga.synopsis)
                        if networker.isSignedIn && !settings.hideMangaProgress && !manga.isEmpty() {
                            if let listStatus = manga.myListStatus, !controller.isLoading {
                                MangaProgress(numChapters: manga.numChapters, numVolumes: manga.numVolumes, numChaptersRead: listStatus.numChaptersRead, numVolumesRead: listStatus.numVolumesRead, status: listStatus.status)
                            } else {
                                MangaProgressNotAdded(numChapters: manga.numChapters, numVolumes: manga.numVolumes, isLoading: controller.isLoading)
                            }
                        }
                        if !settings.hideMangaInformation {
                            MangaInformation(manga: manga)
                        }
                        if !settings.hideMangaCharacters {
                            MangaCharacters(controller: controller)
                        }
                        if !settings.hideAuthors {
                            Authors(controller: controller)
                        }
                        if !settings.hideMangaRelated {
                            MangaRelatedItems(controller: controller)
                        }
                        if !settings.hideMangaRecommendations {
                            Recommendations(mangaRecommendations: manga.recommendations)
                        }
                        if !settings.hideMangaReviews {
                            MangaReviews(id: id, controller: controller)
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
                    ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
                }
            }
            if controller.isLoading && (controller.manga == nil || controller.manga!.isEmpty()) {
                LoadingView()
            }
            if controller.manga == nil && !controller.isLoading && !controller.isLoadingError {
                VStack {
                    Image(systemName: "book.fill")
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
            if let manga = controller.manga, !manga.isEmpty() {
                if controller.isLoading {
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
                        MangaEditView(id: manga.id, listStatus: manga.myListStatus, title: manga.title, enTitle: manga.alternativeTitles?.en, numVolumes: manga.numVolumes, numChapters: manga.numChapters, imageUrl: controller.manga?.mainPicture?.large)
                            .presentationBackground {
                                ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
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
            ShareLink(item: URL(string: "https://myanimelist.net/manga/\(id)")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
}
