//
//  MyListView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct MyListView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = MyListViewController()
    @StateObject private var networker = NetworkManager.shared
    @State private var isRefresh = false
    @State private var isBack = false
    @State private var selectedAnime: MALListAnime?
    @State private var selectedManga: MALListManga?
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                VStack {
                    if controller.type == .anime {
                        ZStack {
                            List {
                                Section(controller.animeStatus.toString()) {
                                    if controller.isLoadingError && controller.animeItems.isEmpty {
                                        HStack {
                                            Spacer()
                                            ErrorView(refresh: { await controller.refresh() })
                                            Spacer()
                                        }
                                    } else {
                                        ForEach(controller.animeItems, id: \.forEachId) { item in
                                            AnimeListItem(anime: item, status: controller.animeStatus, refresh: { await controller.refresh() }, isBack: $isBack, selectedAnime: $selectedAnime)
                                                .onAppear {
                                                    Task {
                                                        await controller.loadMoreIfNeeded(currentItem: item)
                                                    }
                                                }
                                        }
                                        if !controller.isAnimeLoading && controller.isItemsEmpty() {
                                            VStack {
                                                Image(systemName: "tv.fill")
                                                    .resizable()
                                                    .frame(width: 45, height: 40)
                                                Text("Nothing found. ")
                                                    .bold()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 50)
                                        }
                                    }
                                }
                            }
                            if controller.isAnimeLoading {
                                LoadingView()
                            }
                        }
                        
                    } else if controller.type == .manga {
                        ZStack {
                            List {
                                Section(controller.mangaStatus.toString()) {
                                    if controller.isLoadingError && controller.mangaItems.isEmpty {
                                        HStack {
                                            Spacer()
                                            ErrorView(refresh: { await controller.refresh() })
                                            Spacer()
                                        }
                                    } else {
                                        ForEach(controller.mangaItems, id: \.forEachId) { item in
                                            MangaListItem(manga: item, status: controller.mangaStatus, refresh: { await controller.refresh() }, isBack: $isBack, selectedManga: $selectedManga)
                                                .onAppear {
                                                    Task {
                                                        await controller.loadMoreIfNeeded(currentItem: item)
                                                    }
                                                }
                                        }
                                        if !controller.isMangaLoading && controller.isItemsEmpty() {
                                            VStack {
                                                Image(systemName: "book.fill")
                                                    .resizable()
                                                    .frame(width: 45, height: 40)
                                                Text("Nothing found. ")
                                                    .bold()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 50)
                                        }
                                    }
                                }
                            }
                            if controller.isMangaLoading {
                                LoadingView()
                            }
                        }
                    }
                }
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.shouldRefresh() || isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .sheet(item: $selectedAnime) {
                    Task {
                        await controller.refresh()
                    }
                } content: { anime in
                    AnimeEditView(id: anime.id, listStatus: anime.listStatus, title: anime.node.title, numEpisodes: anime.node.numEpisodes, imageUrl: anime.node.mainPicture?.medium)
                        .presentationBackground {
                            if settings.translucentBackground {
                                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.medium, imageSize: .background)
                            } else {
                                Color(.systemGray6)
                            }
                        }
                }
                .sheet(item: $selectedManga) {
                    Task {
                        await controller.refresh()
                    }
                } content: { manga in
                    MangaEditView(id: manga.id, listStatus: manga.listStatus, title: manga.node.title, numVolumes: manga.node.numVolumes, numChapters: manga.node.numChapters, imageUrl: manga.node.mainPicture?.medium)
                            .presentationBackground {
                                if settings.translucentBackground {
                                    ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.medium, imageSize: .background)
                                } else {
                                    Color(.systemGray6)
                                }
                            }
                }
                .task(id: isBack) {
                    if isBack {
                        await controller.refresh()
                        isBack = false
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ListFilter(controller: controller)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        AnimeMangaToggle(type: $controller.type, refresh: {
                            if controller.shouldRefresh() {
                                await controller.refresh()
                            }
                        })
                    }
                }
                .navigationTitle(controller.type == .anime ? "My Anime List" : "My Manga List")
            } else {
                VStack {
                    Image(systemName: "gear")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("You have to sign in under Settings to view or edit your lists")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity)
                .padding(30)
                .background(Color(.secondarySystemBackground))
            }
        }
    }
}
