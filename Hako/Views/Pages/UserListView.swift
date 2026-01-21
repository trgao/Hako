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
                } else if controller.animeItems.isEmpty {
                    if controller.isAnimeLoading {
                        LoadingList(length: 20)
                    } else if controller.isAnimeLoadingError {
                        ListErrorView(refresh: { await controller.refresh() })
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
                        AnimeListItem(anime: item)
                            .onAppear {
                                Task {
                                    await controller.loadMoreIfNeeded(index: index)
                                }
                            }
                    }
                    if controller.isAnimeLoading {
                        LoadingList(length: 5)
                    }
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
        .disabled(controller.isAnimeLoading && controller.animeItems.isEmpty)
        .onChange(of: controller.animeStatus) {
            Task {
                await controller.refresh(true)
            }
        }
        .onChange(of: controller.animeSort) {
            Task {
                await controller.refresh(true)
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
                } else if controller.mangaItems.isEmpty {
                    if controller.isMangaLoading {
                        LoadingList(length: 20)
                    } else if controller.isMangaLoadingError {
                        ListErrorView(refresh: { await controller.refresh() })
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
                        MangaListItem(manga: item)
                            .onAppear {
                                Task {
                                    await controller.loadMoreIfNeeded(index: index)
                                }
                            }
                    }
                    if controller.isMangaLoading {
                        LoadingList(length: 5)
                    }
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
        .disabled(controller.isMangaLoading && controller.mangaItems.isEmpty)
        .onChange(of: controller.mangaStatus) {
            Task {
                await controller.refresh(true)
            }
        }
        .onChange(of: controller.mangaSort) {
            Task {
                await controller.refresh(true)
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
    }
    
    var body: some View {
        ZStack {
            if controller.type == .anime {
                animeList
                if settings.useStatusTabBar {
                    UserListStatusPicker(selection: $controller.animeStatus, options: Constants.animeStatuses)
                        .disabled(controller.isAnimeLoading)
                }
            } else if controller.type == .manga {
                mangaList
                if settings.useStatusTabBar {
                    UserListStatusPicker(selection: $controller.mangaStatus, options: Constants.mangaStatuses)
                        .disabled(controller.isMangaLoading)
                }
            }
            if controller.isRefreshLoading {
                LoadingView()
            }
        }
        .toolbar {
            UserListFilter(controller: controller)
            AnimeMangaToggle(type: $controller.type, isLoading: controller.isLoading())
                .onChange(of: controller.type) {
                    if controller.isItemsEmpty() {
                        Task {
                            await controller.refresh()
                        }
                    }
                }
        }
        .onAppear {
            if !isInit {
                if let type = type {
                    controller.type = type
                }
                controller.animeStatus = animeStatus ?? settings.getAnimeStatus()
                controller.animeSort = animeSort ?? settings.getAnimeSort()
                controller.mangaStatus = mangaStatus ?? settings.getMangaStatus()
                controller.mangaSort = mangaSort ?? settings.getMangaSort()
                isInit = true
            }
        }
    }
}
