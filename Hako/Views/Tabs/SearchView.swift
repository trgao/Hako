//
//  SearchView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import Shimmer

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = SearchViewController()
    @StateObject var networker = NetworkManager.shared
    
    @State private var selectedAnime: MALListAnime?
    @State private var selectedAnimeIndex: Int?
    @State private var isAnimeDeleted = false
    @State private var animeListStatus: MyListStatus?
    
    @State private var selectedManga: MALListManga?
    @State private var selectedMangaIndex: Int?
    @State private var isMangaDeleted = false
    @State private var mangaListStatus: MyListStatus?
    
    @State private var searchText = ""
    @State private var previousSearch = ""
    @State private var searchTask: Task<Void, Never>?
    @Binding private var isPresented: Bool
    @Binding private var isRoot: Bool
    private let options = [
        ("Anime", SearchEnum.anime),
        ("Manga", SearchEnum.manga),
        ("Person", SearchEnum.person),
        ("Character", SearchEnum.character),
    ]
    
    init(isPresented: Binding<Bool>, isRoot: Binding<Bool>) {
        self._isPresented = isPresented
        self._isRoot = isRoot
    }
    
    var exploreView: some View {
        ScrollView {
            VStack {
                if !settings.hideExploreAnimeManga {
                    VStack(spacing: 0) {
                        ScrollViewNavigationLink(title: "Explore anime") {
                            AnimeGenresListView()
                        }
                        ScrollViewNavigationLink(title: "Explore manga") {
                            MangaGenresListView()
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 17)
                    .padding(.vertical, 5)
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
                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
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
                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
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
                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
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
    
    var nothingFoundView: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.bottom, 10)
            Text("Nothing found")
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 50)
    }
    
    var searchView: some View {
        ZStack {
            VStack {
                if controller.isLoading {
                    List {
                        LoadingList(length: 20)
                    }
                    .id(controller.isLoading)
                    .disabled(true)
                } else if controller.type == .anime {
                    List {
                        Section {
                            if controller.animeItems.isEmpty {
                                if controller.isAnimeLoadingError {
                                    ListErrorView(refresh: { await controller.search(query: searchText) })
                                } else {
                                    nothingFoundView
                                }
                            } else {
                                ForEach(Array(controller.animeItems.enumerated()), id: \.1.id) { index, item in
                                    AnimeListItem(anime: item, selectedAnime: $selectedAnime, selectedAnimeIndex: $selectedAnimeIndex, index: index)
                                }
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
                            if controller.mangaItems.isEmpty {
                                if controller.isMangaLoadingError {
                                    ListErrorView(refresh: { await controller.search(query: searchText) })
                                } else {
                                    nothingFoundView
                                }
                            } else {
                                ForEach(Array(controller.mangaItems.enumerated()), id: \.1.id) { index, item in
                                    MangaListItem(manga: item, selectedManga: $selectedManga, selectedMangaIndex: $selectedMangaIndex, index: index)
                                }
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
                            if controller.characterItems.isEmpty {
                                if controller.isCharacterLoadingError {
                                    ListErrorView(refresh: { await controller.search(query: searchText) })
                                } else {
                                    nothingFoundView
                                }
                            } else {
                                ForEach(controller.characterItems) { item in
                                    CharacterListItem(character: item)
                                }
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
                            if controller.personItems.isEmpty {
                                if controller.isPersonLoadingError {
                                    ListErrorView(refresh: { await controller.search(query: searchText) })
                                } else {
                                    nothingFoundView
                                }
                            } else {
                                ForEach(controller.personItems) { item in
                                    PersonListItem(person: item)
                                }
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
            if controller.isRefreshLoading && !controller.isLoading {
                LoadingView()
            }
        }
        .task(id: searchText) {
            if searchText != previousSearch {
                controller.isLoading = true
                await controller.queryChannel.send(searchText)
                previousSearch = searchText
            }
        }
        .task {
            for await query in controller.queryChannel.debounce(for: .seconds(0.35)) {
                searchTask?.cancel()
                searchTask = Task {
                    await controller.search(query: query)
                }
            }
        }
        .task {
            if networker.isSignedIn {
                await controller.refreshSearch(query: searchText)
            }
        }
        .sheet(item: $selectedAnime) {
            Task {
                if let index = selectedAnimeIndex, let animeListStatus = animeListStatus {
                    if isAnimeDeleted {
                        controller.animeItems[index].listStatus = nil
                        controller.animeItems[index].node.myListStatus = nil
                    } else {
                        var newListStatus = animeListStatus
                        newListStatus.updatedAt = Date()
                        controller.animeItems[index].listStatus = newListStatus
                        controller.animeItems[index].node.myListStatus = newListStatus
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
                    if isMangaDeleted {
                        controller.mangaItems[index].listStatus = nil
                        controller.mangaItems[index].node.myListStatus = nil
                    } else {
                        var newListStatus = mangaListStatus
                        newListStatus.updatedAt = Date()
                        controller.mangaItems[index].listStatus = newListStatus
                        controller.mangaItems[index].node.myListStatus = newListStatus
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
        .alert("Unable to edit", isPresented: $controller.isEditError) {
            Button("OK", role: .cancel) {}
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
                    TabPicker(selection: $controller.type, options: options, refresh: {})
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.keyboard)
            .searchable(text: $searchText, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .task {
                await controller.refresh()
            }
            .onChange(of: isPresented) {
                searchText = ""
                previousSearch = ""
                controller.resetSearch()
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
