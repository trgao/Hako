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
    @DebouncedState private var searchText = ""
    @State private var previousSearch = ""
    
    var body: some View {
        NavigationStack {
            PageList {} header: {
                if isPresented {
                    VStack {
                        Picker(selection: $controller.type, label: EmptyView()) {
                            Image(systemName: "tv.fill").tag(TypeEnum.anime)
                            Image(systemName: "book.fill").tag(TypeEnum.manga)
                        }
                        .onChange(of: controller.type) {
                            if searchText.count > 2 && controller.isItemsEmpty() {
                                Task {
                                    await controller.search(searchText)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 10)
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
                                .frame(height: UIScreen.main.bounds.size.height)
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
                                .frame(height: UIScreen.main.bounds.size.height)
                                if controller.isMangaSearchLoading {
                                    LoadingView()
                                }
                            }
                        }
                    }
                } else {
                    ZStack {
                        ScrollView {
                            if networker.isSignedIn {
                                if controller.animeSuggestions.isEmpty {
                                    LoadingCarousel()
                                } else {
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
                                }
                            }
                            if controller.topAiringAnime.isEmpty {
                                LoadingCarousel()
                            } else {
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
                            }
                            if controller.topUpcomingAnime.isEmpty {
                                LoadingCarousel()
                            } else {
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
                            }
                            if controller.topPopularAnime.isEmpty {
                                LoadingCarousel()
                            } else {
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
                            }
                            if controller.topPopularManga.isEmpty {
                                LoadingCarousel()
                            } else {
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
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .searchable(text: $searchText, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search MAL")
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
            .onChange(of: isPresented) {
                controller.animeItems = []
                controller.mangaItems = []
                controller.type = .anime
            }
            .navigationTitle("Search")
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
}
