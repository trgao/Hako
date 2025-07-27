//
//  MangaDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 29/4/24.
//

import SwiftUI

struct MangaDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @Namespace private var transitionNamespace
    @StateObject private var controller: MangaDetailsViewController
    @StateObject private var networker = NetworkManager.shared
    @State private var isEditViewPresented = false
    @State private var isPicturesPresented = false
    @State private var isRefresh = false
    private let id: Int
    private let url: URL
    
    init(id: Int) {
        self.id = id
        self.url = URL(string: "https://myanimelist.net/manga/\(id)")!
        self._controller = StateObject(wrappedValue: MangaDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.manga == nil {
                ErrorView(refresh: controller.refresh)
            } else if let manga = controller.manga {
                ScrollView {
                    VStack {
                        VStack {
                            if #available(iOS 18.0, *) {
                                Button {
                                    isPicturesPresented = true
                                } label: {
                                    ImageFrame(id: "manga\(manga.id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .large)
                                }
                                .matchedTransitionSource(id: "pictures", in: transitionNamespace)
                            } else {
                                Button {
                                    isPicturesPresented = true
                                } label: {
                                    ImageFrame(id: "manga\(manga.id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .large)
                                }
                            }
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
                                    Text("\(mediaType.replacingOccurrences(of: "_", with: " ").capitalized) ・ \(status.formatStatus())")
                                }
                                Text("\(manga.numVolumes == 0 || manga.numVolumes == nil ? "?" : String(manga.numVolumes!)) volume\(manga.numVolumes == 1 ? "" : "s"), \(manga.numChapters == 0 || manga.numChapters == nil ? "?" : String(manga.numChapters!)) chapter\(manga.numChapters == 1 ? "" : "s")")
                            }
                            .opacity(0.7)
                            .font(.system(size: 13))
                        }
                        .padding(.horizontal, 20)
                        Synopsis(text: manga.synopsis)
                        if let listStatus = manga.myListStatus, networker.isSignedIn && !settings.hideMangaProgress {
                            MangaProgress(numChapters: manga.numChapters, numVolumes: manga.numVolumes, numChaptersRead: listStatus.numChaptersRead, numVolumesRead: listStatus.numVolumesRead, status: listStatus.status)
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
                        if !settings.hideMangaStatistics {
                            MangaStatistics(controller: controller)
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
                    ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
                }
            }
            if controller.isLoading {
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
        .background(Color(.secondarySystemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isPicturesPresented) {
            if #available(iOS 18.0, *) {
                ImageCarousel(pictures: controller.manga?.pictures)
                    .navigationTransition(.zoom(sourceID: "pictures", in: transitionNamespace))
            } else {
                ImageCarousel(pictures: controller.manga?.pictures)
            }
        }
        .toolbar {
            if networker.isSignedIn && !settings.useWithoutAccount {
                if let manga = controller.manga {
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
                        MangaEditView(id: manga.id, listStatus: manga.myListStatus, title: manga.title, enTitle: manga.alternativeTitles?.en, numVolumes: manga.numVolumes, numChapters: manga.numChapters, imageUrl: controller.manga?.mainPicture?.large)
                            .presentationBackground {
                                ImageFrame(id: "manga\(id)", imageUrl: controller.manga?.mainPicture?.large, imageSize: .background)
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
