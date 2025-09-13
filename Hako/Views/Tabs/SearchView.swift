//
//  SearchView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import AsyncAlgorithms
import Shimmer

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = SearchViewController()
    @StateObject var networker = NetworkManager.shared
    @State private var searchText = ""
    @State private var previousSearch = ""
    @Binding private var isPresented: Bool
    @Binding private var isRoot: Bool
    private let queryChannel = AsyncChannel<String>()
    
    init(isPresented: Binding<Bool>, isRoot: Binding<Bool>) {
        self._isPresented = isPresented
        self._isRoot = isRoot
    }
    
    var exploreView: some View {
        ScrollView {
            VStack {
                if !settings.hideExploreAnimeManga {
                    VStack(alignment: .leading) {
                        VStack(spacing: 0) {
                            ScrollViewNavigationLink(title: "Explore anime") {
                                AnimeGenresListView()
                            }
                            ScrollViewNavigationLink(title: "Explore manga") {
                                MangaGenresListView()
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 17)
                    .padding(.bottom, 10)
                }
                if networker.isSignedIn && !settings.hideAnimeForYou {
                    if controller.animeSuggestions.isEmpty {
                        LoadingCarousel(title: "Anime for you")
                    } else {
                        VStack {
                            Text("Anime for you")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 35)
                                .font(.system(size: 17))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top) {
                                    ForEach(controller.animeSuggestions) { item in
                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                if !settings.hideTopAiringAnime {
                    if controller.topAiringAnime.isEmpty {
                        LoadingCarousel(title: "Top airing anime")
                    } else {
                        VStack {
                            Text("Top airing anime")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 35)
                                .font(.system(size: 17))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top) {
                                    ForEach(controller.topAiringAnime) { item in
                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                if !settings.hideTopUpcomingAnime {
                    if controller.topUpcomingAnime.isEmpty {
                        LoadingCarousel(title: "Top upcoming anime")
                    } else {
                        VStack {
                            Text("Top upcoming anime")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 35)
                                .font(.system(size: 17))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top) {
                                    ForEach(controller.topUpcomingAnime) { item in
                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                if !settings.hideNewlyAddedAnime {
                    if controller.newlyAddedAnime.isEmpty {
                        LoadingCarousel(title: "Newly added anime")
                    } else {
                        VStack {
                            Text("Newly added anime")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 35)
                                .font(.system(size: 17))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top) {
                                    ForEach(controller.newlyAddedAnime) { item in
                                        AnimeGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                if !settings.hideNewlyAddedManga {
                    if controller.newlyAddedManga.isEmpty {
                        LoadingCarousel(title: "Newly added manga")
                    } else {
                        VStack {
                            Text("Newly added manga")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 35)
                                .font(.system(size: 17))
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top) {
                                    ForEach(controller.newlyAddedManga) { item in
                                        MangaGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var searchView: some View {
        VStack {
            if controller.type == .anime {
                List {
                    Section {
                        if controller.isLoading {
                            LoadingList()
                                .id(searchText)
                        } else if controller.animeItems.isEmpty {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding(.bottom, 10)
                                Text("Nothing found")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                        } else if !controller.isAnimeLoadingError {
                            ForEach(controller.animeItems, id: \.id) { item in
                                AnimeListItem(anime: item)
                            }
                        } else {
                            ErrorView(refresh: { await controller.search(searchText) })
                        }
                    } footer: {
                        Rectangle()
                            .frame(height: 35)
                            .foregroundStyle(.clear)
                    }
                    .padding(.bottom, 10)
                }
            } else if controller.type == .manga {
                List {
                    Section {
                        if controller.isLoading {
                            LoadingList()
                                .id(searchText)
                        } else if controller.mangaItems.isEmpty {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding(.bottom, 10)
                                Text("Nothing found")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                        } else if !controller.isMangaLoadingError {
                            ForEach(controller.mangaItems, id: \.id) { item in
                                MangaListItem(manga: item)
                            }
                        } else {
                            ErrorView(refresh: { await controller.search(searchText) })
                        }
                    } footer: {
                        Rectangle()
                            .frame(height: 35)
                            .foregroundStyle(.clear)
                    }
                    .padding(.bottom, 10)
                }
            } else if controller.type == .character {
                List {
                    Section {
                        if controller.isLoading {
                            LoadingList()
                                .id(searchText)
                        } else if controller.characterItems.isEmpty {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding(.bottom, 10)
                                Text("Nothing found")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                        } else if !controller.isCharacterLoadingError {
                            ForEach(controller.characterItems, id: \.id) { item in
                                NavigationLink {
                                    CharacterDetailsView(id: item.id)
                                } label: {
                                    HStack {
                                        ImageFrame(id: "character\(item.id)", imageUrl: item.images?.jpg?.imageUrl, imageSize: .small)
                                        VStack(alignment: .leading) {
                                            Text(item.name ?? "")
                                                .bold()
                                                .font(.system(size: 16))
                                        }
                                        .padding(5)
                                    }
                                }
                                .padding(5)
                            }
                        } else {
                            ErrorView(refresh: { await controller.search(searchText) })
                        }
                    } footer: {
                        Rectangle()
                            .frame(height: 35)
                            .foregroundStyle(.clear)
                    }
                    .padding(.bottom, 10)
                }
            } else if controller.type == .person {
                List {
                    Section {
                        if controller.isLoading {
                            LoadingList()
                                .id(searchText)
                        } else if controller.personItems.isEmpty {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding(.bottom, 10)
                                Text("Nothing found")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                        } else if !controller.isPersonLoadingError {
                            ForEach(controller.personItems, id: \.id) { item in
                                NavigationLink {
                                    PersonDetailsView(id: item.id)
                                } label: {
                                    HStack {
                                        ImageFrame(id: "person\(item.id)", imageUrl: item.images?.jpg?.imageUrl, imageSize: .small)
                                        VStack(alignment: .leading) {
                                            Text(item.name ?? "")
                                                .bold()
                                                .font(.system(size: 16))
                                        }
                                        .padding(5)
                                    }
                                }
                                .padding(5)
                            }
                        } else {
                            ErrorView(refresh: { await controller.search(searchText) })
                        }
                    } footer: {
                        Rectangle()
                            .frame(height: 35)
                            .foregroundStyle(.clear)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isPresented {
                    searchView
                } else {
                    exploreView
                }
                if isPresented {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 40)
                            .foregroundColor(colorScheme == .light ? Color(.systemBackground) : Color(.systemGray6))
                        Picker(selection: $controller.type, label: EmptyView()) {
                            Text("Anime")
                                .tag(SearchEnum.anime)
                            Text("Manga")
                                .tag(SearchEnum.manga)
                            Text("Character")
                                .tag(SearchEnum.character)
                            Text("Person")
                                .tag(SearchEnum.person)
                        }
                        .sensoryFeedback(.impact(weight: .light), trigger: controller.type)
                        .pickerStyle(.segmented)
                        .padding(5)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(.keyboard, edges: .all)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.keyboard)
            .searchable(text: $searchText, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .task(id: searchText) {
                if searchText != previousSearch {
                    controller.isLoading = true
                    await queryChannel.send(searchText)
                    previousSearch = searchText
                }
            }
            .task {
                for await query in queryChannel.debounce(for: .seconds(0.35)) {
                    await controller.search(query)
                }
            }
            .task {
                await controller.refresh()
            }
            .onChange(of: isPresented) {
                controller.animeItems = []
                controller.mangaItems = []
                controller.characterItems = []
                controller.personItems = []
            }
            .navigationTitle("Search")
            .toolbar {
                if !settings.hideRandom {
                    Menu {
                        NavigationLink {
                            RandomAnimeView()
                        } label: {
                            Label("Random anime", systemImage: "tv")
                        }
                        NavigationLink {
                            RandomMangaView()
                        } label: {
                            Label("Random manga", systemImage: "book")
                        }
                        NavigationLink {
                            RandomCharacterView()
                        } label: {
                            Label("Random character", systemImage: "person")
                        }
                        NavigationLink {
                            RandomPersonView()
                        } label: {
                            Label("Random person", systemImage: "person")
                        }
                    } label: {
                        Button {} label: {
                            Image(systemName: "dice")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .onAppear {
                isRoot = true
            }
            .onDisappear {
                isRoot = false
            }
        }
    }
}
