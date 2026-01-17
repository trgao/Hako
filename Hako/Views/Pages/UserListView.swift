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
                    UserListFilter(controller: controller)
                    Spacer()
                    Text(user)
                }
            }
        }
        .disabled(controller.isAnimeLoading && controller.animeItems.isEmpty)
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
                    UserListFilter(controller: controller)
                    Spacer()
                    Text(user)
                }
            }
        }
        .disabled(controller.isMangaLoading && controller.mangaItems.isEmpty)
    }
    
    var body: some View {
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
            if isRefresh {
                if controller.type == .anime {
                    await controller.refreshAnime(!controller.isItemsEmpty())
                } else if controller.type == .manga {
                    await controller.refreshManga(!controller.isItemsEmpty())
                }
                isRefresh = false
            }
        }
        .toolbar {
            AnimeMangaToggle(type: $controller.type)
        }
        .navigationTitle("\(controller.type.rawValue.capitalized) list")
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
            if controller.isItemsEmpty() {
                Task {
                    await controller.refresh()
                }
            }
        }
    }
}
