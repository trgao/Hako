//
//  MyListView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SystemNotification

struct MyListView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(Router.self) private var router
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = UserListViewController()
    @StateObject private var networker = NetworkManager.shared
    @State private var isInit = false
    @State private var selectedAnime: MALListAnime?
    @State private var selectedManga: MALListManga?
    @Binding private var id: UUID?
    @Binding private var type: TypeEnum?
    @Binding private var animeStatus: StatusEnum?
    @Binding private var animeSort: SortEnum?
    @Binding private var mangaStatus: StatusEnum?
    @Binding private var mangaSort: SortEnum?
    @Binding private var pickerType: TypeEnum
    @Binding private var pickerAnimeStatus: StatusEnum
    @Binding private var pickerMangaStatus: StatusEnum
    @Binding private var pickerDisabled: Bool

    init(id: Binding<UUID?> = .constant(nil), type: Binding<TypeEnum?>, animeStatus: Binding<StatusEnum?>, animeSort: Binding<SortEnum?>, mangaStatus: Binding<StatusEnum?>, mangaSort: Binding<SortEnum?>, pickerType: Binding<TypeEnum>, pickerAnimeStatus: Binding<StatusEnum>, pickerMangaStatus: Binding<StatusEnum>, pickerDisabled: Binding<Bool>) {
        self._id = id
        self._type = type
        self._animeStatus = animeStatus
        self._animeSort = animeSort
        self._mangaStatus = mangaStatus
        self._mangaSort = mangaSort
        self._pickerType = pickerType
        self._pickerAnimeStatus = pickerAnimeStatus
        self._pickerMangaStatus = pickerMangaStatus
        self._pickerDisabled = pickerDisabled
    }

    @ViewBuilder private var animeStatusView: some View {
        let animeItems = controller.animeItems
        ForEach(Array(animeItems.enumerated()), id: \.1.id) { index, item in
            AnimeListItem(anime: item, isLoading: controller.isRefreshLoading, selectedAnime: $selectedAnime)
                .onAppear {
                    Task {
                        await controller.loadMoreIfNeeded(index: index)
                    }
                }
                .swipeActions(edge: .leading) {
                    if settings.useSwipeActions && !controller.isRefreshLoading, var listStatus = networker.getAnimeListStatus(item.id).value, listStatus.numEpisodesWatched > 0 {
                        Button {
                            Task {
                                listStatus.numEpisodesWatched -= 1
                                await controller.updateAnime(id: item.id, listStatus: listStatus)
                            }
                        } label: {
                            Label("-1 episode", systemImage: "minus.circle")
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    if settings.useSwipeActions && !controller.isRefreshLoading, var listStatus = networker.getAnimeListStatus(item.id).value, item.node.numEpisodes == nil || item.node.numEpisodes == 0 || listStatus.numEpisodesWatched < (item.node.numEpisodes ?? .max) {
                        Button {
                            Task {
                                listStatus.numEpisodesWatched += 1
                                if settings.swipeActionAutoComplete && listStatus.numEpisodesWatched == item.node.numEpisodes {
                                    listStatus.status = .completed
                                }
                                await controller.updateAnime(id: item.id, listStatus: listStatus)
                            }
                        } label: {
                            Label("+1 episode", systemImage: "plus.circle")
                        }
                    }
                }
        }
        if controller.loadingState == .paginating {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        }
    }

    @ViewBuilder private var mangaStatusView: some View {
        let mangaItems = controller.mangaItems
        ForEach(Array(mangaItems.enumerated()), id: \.1.id) { index, item in
            MangaListItem(manga: item, isLoading: controller.isRefreshLoading, selectedManga: $selectedManga)
                .onAppear {
                    Task {
                        await controller.loadMoreIfNeeded(index: index)
                    }
                }
                .swipeActions(edge: .leading) {
                    if settings.useSwipeActions && !controller.isRefreshLoading, var listStatus = networker.getMangaListStatus(item.id).value {
                        if settings.mangaReadProgress == 0 {
                            if listStatus.numChaptersRead > 0 {
                                Button {
                                    Task {
                                        listStatus.numChaptersRead -= 1
                                        await controller.updateManga(id: item.id, listStatus: listStatus)
                                    }
                                } label: {
                                    Label("-1 chapter", systemImage: "minus.circle")
                                }
                            }
                        } else if listStatus.numVolumesRead > 0 {
                            Button {
                                Task {
                                    listStatus.numVolumesRead -= 1
                                    await controller.updateManga(id: item.id, listStatus: listStatus)
                                }
                            } label: {
                                Label("-1 volume", systemImage: "minus.circle")
                            }
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    if settings.useSwipeActions && !controller.isRefreshLoading, var listStatus = networker.getMangaListStatus(item.id).value {
                        if settings.mangaReadProgress == 0 {
                            if item.node.numChapters == nil || item.node.numChapters == 0 || listStatus.numChaptersRead < (item.node.numChapters ?? .max) {
                                Button {
                                    Task {
                                        listStatus.numChaptersRead += 1
                                        if settings.swipeActionAutoComplete && listStatus.numChaptersRead == item.node.numChapters {
                                            listStatus.status = .completed
                                        }
                                        await controller.updateManga(id: item.id, listStatus: listStatus)
                                    }
                                } label: {
                                    Label("+1 chapter", systemImage: "plus.circle")
                                }
                            }
                        } else if item.node.numVolumes == nil || item.node.numVolumes == 0 || listStatus.numVolumesRead < (item.node.numVolumes ?? .max) {
                            Button {
                                Task {
                                    listStatus.numVolumesRead += 1
                                    if settings.swipeActionAutoComplete && listStatus.numVolumesRead == item.node.numVolumes {
                                        listStatus.status = .completed
                                    }
                                    await controller.updateManga(id: item.id, listStatus: listStatus)
                                }
                            } label: {
                                Label("+1 volume", systemImage: "plus.circle")
                            }
                        }
                    }
                }
        }
        if controller.loadingState == .paginating {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
        }
    }

    private var animeList: some View {
        List {
            Section(controller.animeStatus.toString()) {
                if controller.animeItems.isEmpty {
                    if controller.loadingState == .loading {
                        LoadingList()
                    } else if controller.loadingState == .error {
                        ErrorView(refresh: { await controller.refresh() })
                    } else {
                        ContentUnavailableView(
                            "Nothing found",
                            systemImage: "tv.fill"
                        )
                        .frame(maxWidth: .infinity, minHeight: 200)
                    }
                } else {
                    animeStatusView
                }
            }
            if settings.useStatusTabBar {
                if #unavailable (iOS 26.2) {
                    Section {} footer: {
                        Rectangle()
                            .frame(height: 0)
                    }
                } else if horizontalSizeClass != .compact {
                    Section {} footer: {
                        Rectangle()
                            .frame(height: 0)
                    }
                }
            }
        }
        .id("animelist:\(controller.animeStatus)\(controller.animeSort)") // To reset list to top position whenever status or sort is changed
        .disabled(controller.loadingState == .loading && controller.animeItems.isEmpty)
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
            Task {
                await controller.refresh()
            }
        }
    }

    private var mangaList: some View {
        List {
            Section(controller.mangaStatus.toString()) {
                if controller.mangaItems.isEmpty {
                    if controller.loadingState == .loading {
                        LoadingList()
                    } else if controller.loadingState == .error {
                        ErrorView(refresh: { await controller.refresh() })
                    } else {
                        ContentUnavailableView(
                            "Nothing found",
                            systemImage: "book.fill"
                        )
                        .frame(maxWidth: .infinity, minHeight: 200)
                    }
                } else {
                    mangaStatusView
                }
            }
            if settings.useStatusTabBar {
                if #unavailable (iOS 26.2) {
                    Section {} footer: {
                        Rectangle()
                            .frame(height: 0)
                    }
                } else if horizontalSizeClass != .compact {
                    Section {} footer: {
                        Rectangle()
                            .frame(height: 0)
                    }
                }
            }
        }
        .id("mangalist:\(controller.mangaStatus)\(controller.mangaSort)") // To reset list to top position whenever status or sort is changed
        .disabled(controller.loadingState == .loading && controller.mangaItems.isEmpty)
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
            Task {
                await controller.refresh()
            }
        }
    }

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            if networker.isSignedIn {
                ZStack {
                    if controller.type == .anime {
                        animeList
                        if settings.useStatusTabBar {
                            if #unavailable (iOS 26.2) {
                                UserListStatusPicker(selection: $controller.animeStatus, options: Constants.animeStatuses, isLoading: controller.isLoading())
                            } else if horizontalSizeClass != .compact {
                                UserListStatusPicker(selection: $controller.animeStatus, options: Constants.animeStatuses, isLoading: controller.isLoading())
                            }
                        }
                    } else if controller.type == .manga {
                        mangaList
                        if settings.useStatusTabBar {
                            if #unavailable (iOS 26.2) {
                                UserListStatusPicker(selection: $controller.mangaStatus, options: Constants.mangaStatuses, isLoading: controller.isLoading())
                            } else if horizontalSizeClass != .compact {
                                UserListStatusPicker(selection: $controller.mangaStatus, options: Constants.mangaStatuses, isLoading: controller.isLoading())
                            }
                        }
                    }
                    if controller.isRefreshLoading {
                        LoadingView()
                    }
                }
                .sheet(item: $selectedAnime) { anime in
                    AnimeEditView(anime: anime.node)
                        .presentationBackground {
                            if settings.translucentBackground {
                                ImageFrame(id: "anime\(anime.id)", imageUrl: anime.node.mainPicture?.large, imageSize: .background)
                            } else {
                                Color(.systemGray6)
                            }
                        }
                }
                .sheet(item: $selectedManga) { manga in
                    MangaEditView(manga: manga.node)
                        .presentationBackground {
                            if settings.translucentBackground {
                                ImageFrame(id: "manga\(manga.id)", imageUrl: manga.node.mainPicture?.large, imageSize: .background)
                            } else {
                                Color(.systemGray6)
                            }
                        }
                }
                .task {
                    guard animeStatus == nil && animeSort == nil && mangaStatus == nil && mangaSort == nil else {
                        return
                    }
                    await controller.refresh()
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
                .navigationDestinations()
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
        .task(id: id) {
            if let type {
                controller.type = type
            }
            if type == .anime {
                if let animeStatus {
                    controller.animeStatus = animeStatus
                    pickerAnimeStatus = animeStatus
                }
                if let animeSort {
                    controller.animeSort = animeSort
                }
            } else if type == .manga {
                if let mangaStatus {
                    controller.mangaStatus = mangaStatus
                    pickerMangaStatus = mangaStatus
                }
                if let mangaSort {
                    controller.mangaSort = mangaSort
                }
            } else if !isInit {
                controller.animeStatus = settings.getAnimeStatus()
                controller.animeSort = settings.getAnimeSort()
                controller.mangaStatus = settings.getMangaStatus()
                controller.mangaSort = settings.getMangaSort()

                pickerAnimeStatus = settings.getAnimeStatus()
                pickerMangaStatus = settings.getMangaStatus()
            }
            pickerType = controller.type
            type = nil
            animeStatus = nil
            animeSort = nil
            mangaStatus = nil
            mangaSort = nil
            isInit = true
        }
        .onChange(of: controller.type) {
            pickerType = controller.type
        }
        .onChange(of: pickerAnimeStatus) {
            controller.animeStatus = pickerAnimeStatus
        }
        .onChange(of: pickerMangaStatus) {
            controller.mangaStatus = pickerMangaStatus
        }
        .onChange(of: controller.isLoading()) {
            pickerDisabled = controller.isLoading()
        }
    }
}
