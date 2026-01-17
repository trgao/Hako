//
//  MyListView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SystemNotification

struct MyListView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = UserListViewController(user: "@me")
    @StateObject private var networker = NetworkManager.shared
    @State private var isInit = false
    @State private var isRefresh = false
    @Binding private var id: UUID
    @Binding private var type: TypeEnum?
    @Binding private var animeStatus: StatusEnum?
    @Binding private var animeSort: SortEnum?
    @Binding private var mangaStatus: StatusEnum?
    @Binding private var mangaSort: SortEnum?
    
    @State private var selectedAnime: MALListAnime?
    @State private var selectedAnimeIndex: Int?
    @State private var isAnimeDeleted = false
    @State private var animeListStatus: MyListStatus?
    
    @State private var selectedManga: MALListManga?
    @State private var selectedMangaIndex: Int?
    @State private var isMangaDeleted = false
    @State private var mangaListStatus: MyListStatus?
    
    init(id: Binding<UUID>, type: Binding<TypeEnum?>, animeStatus: Binding<StatusEnum?>, animeSort: Binding<SortEnum?>, mangaStatus: Binding<StatusEnum?>, mangaSort: Binding<SortEnum?>) {
        self._id = id
        self._type = type
        self._animeStatus = animeStatus
        self._animeSort = animeSort
        self._mangaStatus = mangaStatus
        self._mangaSort = mangaSort
    }
    
    private var animeList: some View {
        List {
            Section(controller.animeStatus.toString()) {
                if controller.animeItems.isEmpty {
                    if controller.isAnimeLoading {
                        LoadingList(length: 20)
                    } else if controller.isLoadingError {
                        ListErrorView(refresh: { await controller.refreshAnime() })
                    } else {
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
                } else {
                    ForEach(Array(controller.animeItems.enumerated()), id: \.1.id) { index, item in
                        AnimeListItem(anime: item, selectedAnime: $selectedAnime, selectedAnimeIndex: $selectedAnimeIndex, index: index)
                            .onAppear {
                                Task {
                                    await controller.loadMoreIfNeeded(index: index)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if settings.useSwipeActions && !controller.isLoading {
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
                                if settings.useSwipeActions && !controller.isLoading {
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
                    if controller.isAnimeLoading {
                        LoadingList(length: 5)
                    }
                }
            }
        }
        .id("animelist:\(controller.animeStatus)\(controller.animeSort)") // To reset list to top position whenever status or sort is changed
        .disabled(controller.isAnimeLoading && controller.animeItems.isEmpty)
    }
    
    private var mangaList: some View {
        List {
            Section(controller.mangaStatus.toString()) {
                if controller.mangaItems.isEmpty {
                    if controller.isMangaLoading {
                        LoadingList(length: 20)
                    } else if controller.isLoadingError {
                        ListErrorView(refresh: { await controller.refreshManga() })
                    } else {
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
                } else {
                    ForEach(Array(controller.mangaItems.enumerated()), id: \.1.id) { index, item in
                        MangaListItem(manga: item, selectedManga: $selectedManga, selectedMangaIndex: $selectedMangaIndex, index: index)
                            .onAppear {
                                Task {
                                    await controller.loadMoreIfNeeded(index: index)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if settings.useSwipeActions && !controller.isLoading {
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
                                if settings.useSwipeActions && !controller.isLoading {
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
                    if controller.isMangaLoading {
                        LoadingList(length: 5)
                    }
                }
            }
        }
        .id("mangalist:\(controller.mangaStatus)\(controller.mangaSort)") // To reset list to top position whenever status or sort is changed
        .disabled(controller.isMangaLoading && controller.mangaItems.isEmpty)
    }
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                ZStack {
                    if controller.type == .anime {
                        animeList
                    } else if controller.type == .manga {
                        mangaList
                    }
                    if controller.isLoading {
                        LoadingView()
                    }
                }
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    await controller.refresh(!controller.isItemsEmpty())
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
                            if isAnimeDeleted || (controller.animeStatus != .none && animeListStatus.status != controller.animeStatus) {
                                controller.animeItems.remove(at: index)
                            } else {
                                controller.animeItems[index].listStatus = animeListStatus
                            }
                            isAnimeDeleted = false
                            selectedAnimeIndex = nil
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
                            if isMangaDeleted || (controller.mangaStatus != .none && mangaListStatus.status != controller.mangaStatus) {
                                controller.mangaItems.remove(at: index)
                            } else {
                                controller.mangaItems[index].listStatus = mangaListStatus
                            }
                            isMangaDeleted = false
                            selectedMangaIndex = nil
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
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        UserListFilter(controller: controller)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        AnimeMangaToggle(type: $controller.type)
                    }
                }
                .navigationTitle("My \(controller.type.rawValue) list")
            } else {
                List {
                    SignInSections()
                }
                .navigationTitle("My list")
            }
        }
        .systemNotification(isActive: $controller.isEditError) {
            Label("Unable to save", systemImage: "exclamationmark.triangle.fill")
                .labelStyle(.iconTint(.red))
                .padding()
        }
        .onAppear {
            if !isInit {
                controller.animeStatus = settings.getAnimeStatus()
                controller.animeSort = settings.getAnimeSort()
                controller.mangaStatus = settings.getMangaStatus()
                controller.mangaSort = settings.getMangaSort()
                isInit = true
            }
        }
        .id(id)
        .task(id: id) {
            if let type = type {
                controller.type = type
            }
            type = nil
            if controller.type == .anime {
                if let animeStatus = animeStatus {
                    controller.animeStatus = animeStatus
                }
                animeStatus = nil
                if let animeSort = animeSort {
                    controller.animeSort = animeSort
                }
                animeSort = nil
            } else if controller.type == .manga {
                if let mangaStatus = mangaStatus {
                    controller.mangaStatus = mangaStatus
                }
                mangaStatus = nil
                if let mangaSort = mangaSort {
                    controller.mangaSort = mangaSort
                }
                mangaSort = nil
            }
        }
    }
}
