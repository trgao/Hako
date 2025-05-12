//
//  MyListView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct MyListView: View {
    @StateObject private var controller = MyListViewController()
    @StateObject private var networker = NetworkManager.shared
    @State private var isRefresh = false
    @State private var isBack = false
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                VStack {
                    if controller.type == .anime {
                        ZStack {
                            List {
                                Section(controller.animeStatus.toString()) {
                                    if controller.isLoadingError {
                                        HStack {
                                            Spacer()
                                            ErrorView(refresh: { await controller.refresh() })
                                            Spacer()
                                        }
                                    } else {
                                        ForEach(controller.animeItems, id: \.forEachId) { item in
                                            AnimeListItem(anime: item, status: controller.animeStatus, refresh: { await controller.refresh() }, isBack: $isBack)
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
                                    if controller.isLoadingError {
                                        HStack {
                                            Spacer()
                                            ErrorView(refresh: { await controller.refresh() })
                                            Spacer()
                                        }
                                    } else {
                                        ForEach(controller.mangaItems, id: \.forEachId) { item in
                                            MangaListItem(manga: item, status: controller.mangaStatus, refresh: { await controller.refresh() }, isBack: $isBack)
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
