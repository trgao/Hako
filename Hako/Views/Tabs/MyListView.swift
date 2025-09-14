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
    @State private var isAnimeDeleted = false
    @State private var animeListStatus: AnimeListStatus?
    
    @State private var selectedManga: MALListManga?
    @State private var selectedMangaIndex: Int?
    @State private var isMangaDeleted = false
    @State private var mangaListStatus: MangaListStatus?
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                VStack {
                    ZStack {
                        if controller.type == .anime {
                            List {
                                Section(controller.animeStatus.toString()) {
                                    if controller.isLoadingError && controller.animeItems.isEmpty {
                                        HStack {
                                            ErrorView(refresh: { await controller.refreshAnime() })
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    } else {
                                        ForEach(Array(controller.animeItems.enumerated()), id: \.1.id) { index, item in
                                            AnimeListItem(anime: item, selectedAnime: $selectedAnime, selectedAnimeIndex: $selectedAnimeIndex, index: index)
                                                .onAppear {
                                                    Task {
                                                        await controller.loadMoreIfNeeded(index: index)
                                                    }
                                                }
                                                .swipeActions(edge: .leading) {
                                                    if settings.useSwipeActions {
                                                        if var listStatus = item.listStatus, listStatus.numEpisodesWatched > 0 {
                                                            Button {
                                                                Task {
                                                                    listStatus.numEpisodesWatched -= 1
                                                                    await controller.updateAnime(index: index, id: item.id, listStatus: listStatus)
                                                                }
                                                            } label: {
                                                                Label("-1 episode watched", systemImage: "minus.circle")
                                                            }
                                                        }
                                                    }
                                                }
                                                .swipeActions(edge: .trailing) {
                                                    if settings.useSwipeActions {
                                                        if var listStatus = item.listStatus, item.node.numEpisodes == nil || item.node.numEpisodes == 0 || listStatus.numEpisodesWatched < (item.node.numEpisodes ?? .max) {
                                                            Button {
                                                                Task {
                                                                    listStatus.numEpisodesWatched += 1
                                                                    await controller.updateAnime(index: index, id: item.id, listStatus: listStatus)
                                                                }
                                                            } label: {
                                                                Label("+1 episode watched", systemImage: "plus.circle")
                                                            }
                                                        }
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
                                    if controller.isAnimeLoading {
                                        LoadingList()
                                            .id(controller.animeLoadId)
                                    }
                                }
                            }
                        } else if controller.type == .manga {
                            List {
                                Section(controller.mangaStatus.toString()) {
                                    if controller.isLoadingError && controller.mangaItems.isEmpty {
                                        HStack {
                                            ErrorView(refresh: { await controller.refreshManga() })
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    } else {
                                        ForEach(Array(controller.mangaItems.enumerated()), id: \.1.id) { index, item in
                                            MangaListItem(manga: item, selectedManga: $selectedManga, selectedMangaIndex: $selectedMangaIndex, index: index)
                                                .onAppear {
                                                    Task {
                                                        await controller.loadMoreIfNeeded(index: index)
                                                    }
                                                }
                                                .swipeActions(edge: .leading) {
                                                    if settings.useSwipeActions {
                                                        if settings.mangaReadProgress == 0 {
                                                            if var listStatus = item.listStatus, listStatus.numChaptersRead > 0 {
                                                                Button {
                                                                    Task {
                                                                        listStatus.numChaptersRead -= 1
                                                                        await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                                    }
                                                                } label: {
                                                                    Label("-1 chapter read", systemImage: "minus.circle")
                                                                }
                                                            }
                                                        } else if var listStatus = item.listStatus, listStatus.numVolumesRead > 0 {
                                                            Button {
                                                                Task {
                                                                    listStatus.numVolumesRead -= 1
                                                                    await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                                }
                                                            } label: {
                                                                Label("-1 volume read", systemImage: "minus.circle")
                                                            }
                                                        }
                                                    }
                                                }
                                                .swipeActions(edge: .trailing) {
                                                    if settings.useSwipeActions {
                                                        if settings.mangaReadProgress == 0 {
                                                            if var listStatus = item.listStatus, item.node.numChapters == nil || item.node.numChapters == 0 || listStatus.numChaptersRead < (item.node.numChapters ?? .max) {
                                                                Button {
                                                                    Task {
                                                                        listStatus.numChaptersRead += 1
                                                                        await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                                    }
                                                                } label: {
                                                                    Label("+1 chapter read", systemImage: "plus.circle")
                                                                }
                                                            }
                                                        } else if var listStatus = item.listStatus, item.node.numVolumes == nil || item.node.numVolumes == 0 || listStatus.numVolumesRead < (item.node.numVolumes ?? .max) {
                                                            Button {
                                                                Task {
                                                                    listStatus.numVolumesRead += 1
                                                                    await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                                                }
                                                            } label: {
                                                                Label("+1 volume read", systemImage: "plus.circle")
                                                            }
                                                        }
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
                                    if controller.isMangaLoading {
                                        LoadingList()
                                            .id(controller.mangaLoadId)
                                    }
                                }
                            }
                        }
                        if controller.isLoading {
                            LoadingView()
                        }
                    }
                }
                .task {
                    await controller.refresh(!controller.isItemsEmpty())
                }
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if isRefresh {
                        if controller.type == .anime {
                            await controller.refreshAnime(!controller.isItemsEmpty())
                        } else if controller.type == .manga {
                            await controller.refreshManga(!controller.isItemsEmpty())
                        }
                        isRefresh = false
                    }
                }
                .sheet(item: $selectedAnime) {
                    Task {
                        if let index = selectedAnimeIndex, let animeListStatus = animeListStatus {
                            if isAnimeDeleted || animeListStatus.status != controller.animeStatus {
                                controller.animeItems.remove(at: index)
                            } else {
                                controller.animeItems[index].listStatus = animeListStatus
                                selectedAnimeIndex = nil
                            }
                        }
                    }
                } content: { anime in
                    AnimeEditView(id: anime.id, listStatus: anime.listStatus, title: anime.node.title, enTitle: anime.node.alternativeTitles?.en, numEpisodes: anime.node.numEpisodes, imageUrl: anime.node.mainPicture?.large, isDeleted: $isAnimeDeleted, animeListStatus: $animeListStatus)
                        .presentationBackground {
                            if settings.translucentBackground {
                                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.large, imageSize: .background)
                            } else {
                                Color(.systemGray6)
                            }
                        }
                }
                .sheet(item: $selectedManga) {
                    Task {
                        if let index = selectedMangaIndex, let mangaListStatus = mangaListStatus {
                            if isMangaDeleted || mangaListStatus.status != controller.mangaStatus {
                                controller.mangaItems.remove(at: index)
                            } else {
                                controller.mangaItems[index].listStatus = mangaListStatus
                                selectedMangaIndex = nil
                            }
                        }
                    }
                } content: { manga in
                    MangaEditView(id: manga.id, listStatus: manga.listStatus, title: manga.node.title, enTitle: manga.node.alternativeTitles?.en, numVolumes: manga.node.numVolumes, numChapters: manga.node.numChapters, imageUrl: manga.node.mainPicture?.large, isDeleted: $isMangaDeleted, mangaListStatus: $mangaListStatus)
                        .presentationBackground {
                            if settings.translucentBackground {
                                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.large, imageSize: .background)
                            } else {
                                Color(.systemGray6)
                            }
                        }
                }
                .alert("Unable to edit", isPresented: $controller.isEditError) {
                    Button("OK", role: .cancel) {}
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ListFilter(controller: controller)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        AnimeMangaToggle(type: $controller.type)
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
