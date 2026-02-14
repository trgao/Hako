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
    
    @ViewBuilder private func AnimeStatusView(_ animeItems: [MALListAnime]) -> some View {
        ForEach(Array(animeItems.enumerated()), id: \.1.id) { index, item in
            AnimeListItem(anime: item, selectedAnime: $selectedAnime, selectedAnimeIndex: $selectedAnimeIndex, index: index)
                .onAppear {
                    Task {
                        await controller.loadMoreIfNeeded(index: index)
                    }
                }
                .swipeActions(edge: .leading) {
                    if settings.useSwipeActions && !controller.isRefreshLoading, var listStatus = item.listStatus, listStatus.numEpisodesWatched > 0 {
                        Button {
                            Task {
                                listStatus.numEpisodesWatched -= 1
                                await controller.updateAnime(index: index, id: item.id, listStatus: listStatus)
                            }
                        } label: {
                            Label("-1 episode", systemImage: "minus.circle")
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    if settings.useSwipeActions && !controller.isRefreshLoading, var listStatus = item.listStatus, item.node.numEpisodes == nil || item.node.numEpisodes == 0 || listStatus.numEpisodesWatched < (item.node.numEpisodes ?? .max) {
                        Button {
                            Task {
                                listStatus.numEpisodesWatched += 1
                                await controller.updateAnime(index: index, id: item.id, listStatus: listStatus)
                            }
                        } label: {
                            Label("+1 episode", systemImage: "plus.circle")
                        }
                    }
                }
        }
        if controller.loadingState == .paginating {
            LoadingList(length: 5)
        }
    }
    
    @ViewBuilder private func MangaStatusView(_ mangaItems: [MALListManga]) -> some View {
        ForEach(Array(mangaItems.enumerated()), id: \.1.id) { index, item in
            MangaListItem(manga: item, selectedManga: $selectedManga, selectedMangaIndex: $selectedMangaIndex, index: index)
                .onAppear {
                    Task {
                        await controller.loadMoreIfNeeded(index: index)
                    }
                }
                .swipeActions(edge: .leading) {
                    if settings.useSwipeActions && !controller.isRefreshLoading {
                        if settings.mangaReadProgress == 0 {
                            if var listStatus = item.listStatus, listStatus.numChaptersRead > 0 {
                                Button {
                                    Task {
                                        listStatus.numChaptersRead -= 1
                                        await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                    }
                                } label: {
                                    Label("-1 chapter", systemImage: "minus.circle")
                                }
                            }
                        } else if var listStatus = item.listStatus, listStatus.numVolumesRead > 0 {
                            Button {
                                Task {
                                    listStatus.numVolumesRead -= 1
                                    await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                }
                            } label: {
                                Label("-1 volume", systemImage: "minus.circle")
                            }
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    if settings.useSwipeActions && !controller.isRefreshLoading {
                        if settings.mangaReadProgress == 0 {
                            if var listStatus = item.listStatus, item.node.numChapters == nil || item.node.numChapters == 0 || listStatus.numChaptersRead < (item.node.numChapters ?? .max) {
                                Button {
                                    Task {
                                        listStatus.numChaptersRead += 1
                                        await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                    }
                                } label: {
                                    Label("+1 chapter", systemImage: "plus.circle")
                                }
                            }
                        } else if var listStatus = item.listStatus, item.node.numVolumes == nil || item.node.numVolumes == 0 || listStatus.numVolumesRead < (item.node.numVolumes ?? .max) {
                            Button {
                                Task {
                                    listStatus.numVolumesRead += 1
                                    await controller.updateManga(index: index, id: item.id, listStatus: listStatus)
                                }
                            } label: {
                                Label("+1 volume", systemImage: "plus.circle")
                            }
                        }
                    }
                }
        }
        if controller.loadingState == .paginating {
            LoadingList(length: 5)
        }
    }
    
    private var animeList: some View {
        List {
            Section(controller.animeStatus.toString()) {
                if controller.isAnimeItemsEmpty() {
                    if controller.loadingState == .loading {
                        LoadingList(length: 20)
                    } else if controller.loadingState == .error {
                        ErrorView(refresh: { await controller.refresh() })
                            .padding(.vertical, 50)
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
                } else if controller.animeStatus == .none {
                    AnimeStatusView(controller.allAnimeItems)
                } else if controller.animeStatus == .watching {
                    AnimeStatusView(controller.watchingAnimeItems)
                } else if controller.animeStatus == .completed {
                    AnimeStatusView(controller.completedAnimeItems)
                } else if controller.animeStatus == .onHold {
                    AnimeStatusView(controller.onHoldAnimeItems)
                } else if controller.animeStatus == .dropped {
                    AnimeStatusView(controller.droppedAnimeItems)
                } else if controller.animeStatus == .planToWatch {
                    AnimeStatusView(controller.planToWatchAnimeItems)
                }
            }
            if settings.useStatusTabBar {
                Section {} footer: {
                    Rectangle()
                        .frame(height: 0)
                }
            }
        }
        .id("animelist:\(controller.animeStatus)\(controller.animeSort)") // To reset list to top position whenever status or sort is changed
        .disabled(controller.loadingState == .loading && controller.isAnimeItemsEmpty())
        .onChange(of: controller.animeStatus) {
            if isInit {
                // Loading state is changed here to prevent brief flickering of nothing found view
                controller.loadingState = .loading
                Task {
                    await controller.refresh()
                }
            }
        }
        .onChange(of: controller.animeSort) {
            if isInit {
                Task {
                    await controller.refresh(true)
                }
            }
        }
        .refreshable {
            isRefresh = true
        }
    }
    
    private var mangaList: some View {
        List {
            Section(controller.mangaStatus.toString()) {
                if controller.isMangaItemsEmpty() {
                    if controller.loadingState == .loading {
                        LoadingList(length: 20)
                    } else if controller.loadingState == .error {
                        ErrorView(refresh: { await controller.refresh() })
                            .padding(.vertical, 50)
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
                } else if controller.mangaStatus == .none {
                    MangaStatusView(controller.allMangaItems)
                } else if controller.mangaStatus == .reading {
                    MangaStatusView(controller.readingMangaItems)
                } else if controller.mangaStatus == .completed {
                    MangaStatusView(controller.completedMangaItems)
                } else if controller.mangaStatus == .onHold {
                    MangaStatusView(controller.onHoldMangaItems)
                } else if controller.mangaStatus == .dropped {
                    MangaStatusView(controller.droppedMangaItems)
                } else if controller.mangaStatus == .planToRead {
                    MangaStatusView(controller.planToReadMangaItems)
                }
            }
            if settings.useStatusTabBar {
                Section {} footer: {
                    Rectangle()
                        .frame(height: 0)
                }
            }
        }
        .id("mangalist:\(controller.mangaStatus)\(controller.mangaSort)") // To reset list to top position whenever status or sort is changed
        .disabled(controller.loadingState == .loading && controller.isMangaItemsEmpty())
        .onChange(of: controller.mangaStatus) {
            if isInit {
                // Loading state is changed here to prevent brief flickering of nothing found view
                controller.loadingState = .loading
                Task {
                    await controller.refresh()
                }
            }
        }
        .onChange(of: controller.mangaSort) {
            if isInit {
                Task {
                    await controller.refresh(true)
                }
            }
        }
        .refreshable {
            isRefresh = true
        }
    }
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                ZStack {
                    if controller.type == .anime {
                        animeList
                        if settings.useStatusTabBar {
                            UserListStatusPicker(selection: $controller.animeStatus, options: Constants.animeStatuses, isLoading: controller.isLoading())
                        }
                    } else if controller.type == .manga {
                        mangaList
                        if settings.useStatusTabBar {
                            UserListStatusPicker(selection: $controller.mangaStatus, options: Constants.mangaStatuses, isLoading: controller.isLoading())
                        }
                    }
                    if controller.isRefreshLoading {
                        LoadingView()
                    }
                }
                .task(id: isRefresh) {
                    if animeStatus == nil && animeSort == nil && mangaStatus == nil && mangaSort == nil && (controller.shouldRefresh() || isRefresh) {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .sheet(item: $selectedAnime) {
                    Task {
                        if let index = selectedAnimeIndex, let animeListStatus = animeListStatus {
                            if isAnimeDeleted || (controller.animeStatus != .none && animeListStatus.status != controller.animeStatus) {
                                controller.removeAnimeItem(index)
                            } else {
                                controller.updateAnimeItemListStatus(index, animeListStatus)
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
                                controller.removeMangaItem(index)
                            } else {
                                controller.updateMangaItemListStatus(index, mangaListStatus)
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
                        AnimeMangaToggle(type: $controller.type, isLoading: controller.isLoading())
                            .onChange(of: controller.type) {
                                if controller.isItemsEmpty() && controller.getCanLoadMorePages() {
                                    // Loading state is changed here to prevent brief flickering of nothing found view
                                    controller.loadingState = .loading
                                    Task {
                                        await controller.refresh()
                                    }
                                }
                            }
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
        .id(id)
        .task(id: id) {
            if let type = type {
                controller.type = type
            }
            if controller.type == .anime {
                if let animeStatus = animeStatus {
                    controller.animeStatus = animeStatus
                }
                if let animeSort = animeSort {
                    controller.animeSort = animeSort
                }
            } else if controller.type == .manga {
                if let mangaStatus = mangaStatus {
                    controller.mangaStatus = mangaStatus
                }
                if let mangaSort = mangaSort {
                    controller.mangaSort = mangaSort
                }
            } else if !isInit {
                controller.animeStatus = settings.getAnimeStatus()
                controller.animeSort = settings.getAnimeSort()
                controller.mangaStatus = settings.getMangaStatus()
                controller.mangaSort = settings.getMangaSort()
            }
            type = nil
            animeStatus = nil
            animeSort = nil
            mangaStatus = nil
            mangaSort = nil
            isInit = true
        }
    }
}
