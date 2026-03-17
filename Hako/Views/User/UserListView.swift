//
//  UserListView.swift
//  Hako
//
//  Created by Gao Tianrun on 16/1/26.
//

import SwiftUI

struct UserListView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: UserListViewController
    @StateObject private var networker = NetworkManager.shared
    @State private var isInit = false
    @State private var isRefresh = false
    private let user: String
    private let type: TypeEnum?
    private let animeStatus: StatusEnum?
    private let animeSort: SortEnum?
    private let mangaStatus: StatusEnum?
    private let mangaSort: SortEnum?
    
    init(user: String, type: TypeEnum? = nil, animeStatus: StatusEnum? = nil, animeSort: SortEnum? = nil, mangaStatus: StatusEnum? = nil, mangaSort: SortEnum? = nil) {
        self.user = user
        self._controller = StateObject(wrappedValue: UserListViewController(user: user))
        self.type = type
        self.animeStatus = animeStatus
        self.animeSort = animeSort
        self.mangaStatus = mangaStatus
        self.mangaSort = mangaSort
    }
    
    @ViewBuilder private func AnimeStatusView(_ animeItems: [MALListAnime]) -> some View {
        ForEach(Array(animeItems.enumerated()), id: \.1.id) { index, item in
            AnimeListItem(anime: item)
                .onAppear {
                    Task {
                        await controller.loadMoreIfNeeded(index: index)
                    }
                }
        }
        if controller.loadingState == .paginating {
            LoadingList(length: 5)
        }
    }
    
    @ViewBuilder private func MangaStatusView(_ mangaItems: [MALListManga]) -> some View {
        ForEach(Array(mangaItems.enumerated()), id: \.1.id) { index, item in
            MangaListItem(manga: item)
                .onAppear {
                    Task {
                        await controller.loadMoreIfNeeded(index: index)
                    }
                }
        }
        if controller.loadingState == .paginating {
            LoadingList(length: 5)
        }
    }
    
    private var animeList: some View {
        List {
            Section {
                if controller.isAnimePrivate {
                    VStack {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .frame(width: 30, height: 40)
                            .padding(.bottom, 5)
                        Text("User has set their list to private")
                            .bold()
                            .padding(.bottom, 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 50)
                } else if controller.isAnimeItemsEmpty() {
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
            } header: {
                HStack {
                    Text(controller.animeStatus.toString())
                    Spacer()
                    Text(user)
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
            Section {
                if controller.isMangaPrivate {
                    VStack {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .frame(width: 30, height: 40)
                            .padding(.bottom, 5)
                        Text("User has set their list to private")
                            .bold()
                            .padding(.bottom, 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 50)
                } else if controller.isMangaItemsEmpty() {
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
            } header: {
                HStack {
                    Text(controller.mangaStatus.toString())
                    Spacer()
                    Text(user)
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
            if !isInit {
                if let type = type {
                    controller.type = type
                }
                controller.animeStatus = animeStatus ?? settings.getAnimeStatus()
                controller.animeSort = animeSort ?? settings.getAnimeSort()
                controller.mangaStatus = mangaStatus ?? settings.getMangaStatus()
                controller.mangaSort = mangaSort ?? settings.getMangaSort()
            }
            if (controller.isItemsEmpty() && controller.getCanLoadMorePages()) || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
            isInit = true
        }
        .toolbar {
            UserListFilter(controller: controller)
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
}
