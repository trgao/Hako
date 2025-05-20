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
    @State private var selectedAnime: MALListAnime?
    @State private var selectedAnimeIndex: Int?
    @State private var selectedManga: MALListManga?
    @State private var selectedMangaIndex: Int?
    
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
                                        ForEach(controller.animeItems.indices, id: \.self) { index in
                                            AnimeListItem(anime: controller.animeItems[index], status: controller.animeStatus, selectedAnime: $selectedAnime, selectedAnimeIndex: $selectedAnimeIndex, index: index)
                                                .onAppear {
                                                    Task {
                                                        await controller.loadMoreIfNeeded(currentItem: controller.animeItems[index])
                                                    }
                                                }
                                        }
                                        if !controller.isAnimeLoading && controller.isItemsEmpty() {
                                            VStack {
                                                Image(systemName: "tv.fill")
                                                    .resizable()
                                                    .frame(width: 45, height: 40)
                                                Text("Nothing found")
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
                                        ForEach(controller.mangaItems.indices, id: \.self) { index in
                                            MangaListItem(manga: controller.mangaItems[index], status: controller.mangaStatus, selectedManga: $selectedManga, selectedMangaIndex: $selectedMangaIndex, index: index)
                                                .onAppear {
                                                    Task {
                                                        await controller.loadMoreIfNeeded(currentItem: controller.mangaItems[index])
                                                    }
                                                }
                                        }
                                        if !controller.isMangaLoading && controller.isItemsEmpty() {
                                            VStack {
                                                Image(systemName: "book.fill")
                                                    .resizable()
                                                    .frame(width: 45, height: 40)
                                                Text("Nothing found")
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
                        if let index = selectedAnimeIndex {
                            await controller.refreshItem(index: index, type: .anime)
                            selectedAnimeIndex = nil
                        }
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
                        if let index = selectedMangaIndex {
                            await controller.refreshItem(index: index, type: .manga)
                            selectedMangaIndex = nil
                        }
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
                List {
                    SignInSections()
                }
                .navigationTitle("My List")
            }
        }
    }
}
