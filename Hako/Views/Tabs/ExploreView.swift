//
//  ExploreView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import Shimmer
import SystemNotification

struct ExploreView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = ExploreViewController()
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
    @Binding private var urlSearchText: String
    @Binding private var urlItemType: SearchEnum
    @Binding private var urlItemId: Int?
    private let options = [
        ("Anime", SearchEnum.anime),
        ("Manga", SearchEnum.manga),
        ("Character", SearchEnum.character),
        ("Person", SearchEnum.person),
    ]
    
    init(isPresented: Binding<Bool>, isRoot: Binding<Bool>, urlSearchText: Binding<String>, urlItemType: Binding<SearchEnum>, urlItemId: Binding<Int?>) {
        self._isPresented = isPresented
        self._isRoot = isRoot
        self._urlSearchText = urlSearchText
        self._urlItemType = urlItemType
        self._urlItemId = urlItemId
    }
    
    var recentlyViewed: some View {
        VStack {
            Text("Recently viewed")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 35)
                .font(.system(size: 17))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(settings.recentlyViewedItems.reversed()) { item in
                        if let anime = item.anime {
                            AnimeGridItem(id: anime.id, title: anime.title, enTitle: anime.alternativeTitles?.en, imageUrl: anime.mainPicture?.large, anime: anime, isRecentlyViewed: true)
                        } else if let manga = item.manga {
                            MangaGridItem(id: manga.id, title: manga.title, enTitle: manga.alternativeTitles?.en, imageUrl: manga.mainPicture?.large, manga: manga, isRecentlyViewed: true)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
            }
            .padding(.top, -50)
        }
    }
    
    var animeSuggestions: some View {
        VStack {
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
                        .padding(.top, 50)
                    }
                    .padding(.top, -50)
                }
            }
        }
        .task {
            await controller.loadAnimeSuggestions()
        }
    }
    
    var topAiringAnime: some View {
        VStack {
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
                        .padding(.top, 50)
                    }
                    .padding(.top, -50)
                }
            }
        }
        .task {
            await controller.loadTopAiringAnime()
        }
    }
    
    var topUpcomingAnime: some View {
        VStack {
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
                        .padding(.top, 50)
                    }
                    .padding(.top, -50)
                }
            }
        }
        .task {
            await controller.loadTopUpcomingAnime()
        }
    }
    
    var newlyAddedAnime: some View {
        VStack {
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
                                AnimeGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, anime: Anime(item: item))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                    }
                    .padding(.top, -50)
                }
            }
        }
        .task {
            await controller.loadNewlyAddedAnime()
        }
    }
    
    var newlyAddedManga: some View {
        VStack {
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
                                MangaGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, manga: Manga(item: item))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                    }
                    .padding(.top, -50)
                }
            }
        }
        .task {
            await controller.loadNewlyAddedManga()
        }
    }
    
    var exploreView: some View {
        ScrollView {
            VStack {
                VStack {
                    if !settings.hideExploreAnimeManga {
                        HStack {
                            ScrollViewBox(title: "Explore anime", image: "tv.fill") {
                                AnimeGenresListView()
                            }
                            Spacer()
                            ScrollViewBox(title: "Explore manga", image: "book.fill") {
                                MangaGenresListView()
                            }
                        }
                        .padding(.horizontal, 17)
                        Spacer()
                    }
                    if !settings.hideNews {
                        ScrollViewBox(title: "News", image: "newspaper.fill") {
                            NewsListView()
                        }
                        .padding(.horizontal, 17)
                        .padding(.bottom, 10)
                    }
                }
                .padding(.bottom, 5)
                if !settings.hideRecentlyViewed && !settings.recentlyViewedItems.isEmpty {
                    recentlyViewed
                }
                if networker.isSignedIn && !settings.hideAnimeForYou {
                    animeSuggestions
                }
                if !settings.hideTopAiringAnime {
                    topAiringAnime
                }
                if !settings.hideTopUpcomingAnime {
                    topUpcomingAnime
                }
                if !settings.hideNewlyAddedAnime {
                    newlyAddedAnime
                }
                if !settings.hideNewlyAddedManga {
                    newlyAddedManga
                }
            }
            .padding(.vertical, 10)
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
                                if controller.isAnimeLoadingError && searchText.count > 2 {
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
                                if controller.isMangaLoadingError && searchText.count > 2 {
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
                                if controller.isCharacterLoadingError && searchText.count > 2 {
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
                                if controller.isPersonLoadingError && searchText.count > 2 {
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
        .task(id: urlSearchText) {
            if urlSearchText != "" {
                previousSearch = ""
                controller.resetSearch()
                searchText = urlSearchText
                urlSearchText = ""
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
            if networker.isSignedIn && (controller.type == .anime || controller.type == .manga) {
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
            .onChange(of: isPresented) {
                if !isPresented {
                    searchText = ""
                    previousSearch = ""
                    controller.resetSearch()
                }
            }
            .navigationTitle("Explore")
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
                        if #available (iOS 26.0, *) {
                            Button {} label: {
                                Image(systemName: "dice")
                            }
                        } else {
                            Button {} label: {
                                Image(systemName: "dice")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .onAppear {
                isRoot = true
            }
            .onDisappear {
                isRoot = false
            }
            .navigationDestination(item: $urlItemId) { id in
                if urlItemType == .anime {
                    AnimeDetailsView(id: id)
                } else if urlItemType == .manga {
                    MangaDetailsView(id: id)
                } else if urlItemType == .character {
                    CharacterDetailsView(id: id)
                } else if urlItemType == .person {
                    PersonDetailsView(id: id)
                }
            }
        }
    }
}
