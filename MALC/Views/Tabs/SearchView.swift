//
//  SearchView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var controller = SearchViewController()
    @StateObject var networker = NetworkManager.shared
    @State private var isPresented = false
    @State private var isRefresh = false
    @DebouncedState private var searchText = ""
    @State private var previousSearch = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isPresented {
                    VStack {
                        Picker(selection: $controller.type, label: EmptyView()) {
                            Image(systemName: "tv.fill").tag(TypeEnum.anime)
                            Image(systemName: "book.fill").tag(TypeEnum.manga)
                        }
                        .onChange(of: controller.type) { _ in
                            if searchText.count > 2 && controller.isItemsEmpty() {
                                Task {
                                    await controller.search(searchText)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 10)
                        .disabled(controller.isPageLoading)
                        if controller.type == .anime {
                            ZStack {
                                List {
                                    ForEach(controller.animeItems, id: \.forEachId) { item in
                                        AnimeListItem(anime: item)
                                            .onAppear {
                                                Task {
                                                    await controller.loadMoreIfNeeded(searchText, item)
                                                }
                                            }
                                    }
                                }
                                if controller.isAnimeSearchLoading {
                                    LoadingView()
                                }
                            }
                        } else if controller.type == .manga {
                            ZStack {
                                List {
                                    ForEach(controller.mangaItems, id: \.forEachId) { item in
                                        MangaListItem(manga: item)
                                            .onAppear {
                                                Task {
                                                    await controller.loadMoreIfNeeded(searchText, item)
                                                }
                                            }
                                    }
                                }
                                if controller.isMangaSearchLoading {
                                    LoadingView()
                                }
                            }
                        }
                    }
                } else {
                    ZStack {
                        ScrollView {
                            if networker.isSignedIn && !controller.animeSuggestions.isEmpty {
                                VStack {
                                    Text("For You")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 35)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            ForEach(controller.animeSuggestions) { item in
                                                AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            } else {
                                LoadingCarousel()
                            }
                            if !controller.topAiringAnime.isEmpty {
                                VStack {
                                    Text("Top Airing")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 35)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            ForEach(controller.topAiringAnime) { item in
                                                AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            } else {
                                LoadingCarousel()
                            }
                            if !controller.topUpcomingAnime.isEmpty {
                                VStack {
                                    Text("Top Upcoming")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 35)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            ForEach(controller.topUpcomingAnime) { item in
                                                AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            } else {
                                LoadingCarousel()
                            }
                            if !controller.topPopularAnime.isEmpty {
                                VStack {
                                    Text("Most Popular Anime")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 35)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            ForEach(controller.topPopularAnime) { item in
                                                AnimeGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            } else {
                                LoadingCarousel()
                            }
                            if !controller.topPopularManga.isEmpty {
                                VStack {
                                    Text("Most Popular Manga")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 35)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            ForEach(controller.topPopularManga) { item in
                                                MangaGridItem(id: item.id, title: item.node.title, imageUrl: item.node.mainPicture?.medium)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                            } else {
                                LoadingCarousel()
                            }
                        }
                        .padding(.vertical, 2)
                        if controller.isPageLoading && isRefresh {
                            LoadingView()
                        }
                    }
                }
            }
            .task(id: isRefresh) {
                if controller.isPageEmpty() || isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .refreshable {
                isRefresh = true
            }
            .searchable_ios16(text: $searchText, isPresented: $isPresented, prompt: "Search MAL")
            .task(id: searchText) {
                if searchText.count > 2 {
                    if previousSearch != searchText {
                        await controller.search(searchText)
                        previousSearch = searchText
                    }
                } else {
                    controller.animeItems = []
                    controller.mangaItems = []
                }
            }
            .onChange(of: isPresented) { _ in
                controller.animeItems = []
                controller.mangaItems = []
                controller.type = .anime
            }
            .navigationTitle("Search")
        }
    }
}
