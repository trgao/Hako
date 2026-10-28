//
//  ExploreView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SystemNotification

struct ExploreView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(Router.self) private var router
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

    @State private var isRefresh = false
    @State private var searchText = ""
    @State private var previousSearch = ""
    @State private var searchTask: Task<Void, Never>?
    @Binding private var isPresented: Bool
    @Binding private var urlSearchText: String?
    @Binding private var pickerType: SearchEnum

    init(isPresented: Binding<Bool>, urlSearchText: Binding<String?>, pickerType: Binding<SearchEnum>) {
        self._isPresented = isPresented
        self._urlSearchText = urlSearchText
        self._pickerType = pickerType
    }

    private var randomButton: some View {
        Menu {
            Section("Random") {
                NavigationLink(value: Route.screen(.randomAnime)) {
                    Label("Anime", systemImage: "tv")
                }
                NavigationLink(value: Route.screen(.randomManga)) {
                    Label("Manga", systemImage: "book")
                }
                NavigationLink(value: Route.screen(.randomCharacter)) {
                    Label("Character", systemImage: "person.crop.circle")
                }
                NavigationLink(value: Route.screen(.randomPerson)) {
                    Label("Person", systemImage: "person")
                }
            }
        } label: {
            Button {} label: {
                Image(systemName: "dice")
            }
        }
    }

    private var exploreView: some View {
        ScrollView {
            VStack {
                ExploreItems()
                Spacer()
                if !settings.hideRecentlyViewed && !settings.recentlyViewedItems.isEmpty {
                    ScrollViewCarousel(title: "Recently viewed") {
                        ForEach(settings.recentlyViewedItems.reversed()) { item in
                            if let anime = item.anime {
                                AnimeGridItem(id: anime.id, title: anime.title, enTitle: anime.alternativeTitles?.en, jaTitle: anime.alternativeTitles?.ja, imageUrl: anime.mainPicture?.large, anime: anime, isRecentlyViewed: true)
                            } else if let manga = item.manga {
                                MangaGridItem(id: manga.id, title: manga.title, enTitle: manga.alternativeTitles?.en, jaTitle: manga.alternativeTitles?.ja, imageUrl: manga.mainPicture?.large, manga: manga, isRecentlyViewed: true)
                            }
                        }
                    }
                }
                if networker.isSignedIn && !settings.hideAnimeForYou {
                    ScrollViewCarousel(title: "Anime for you", loadingState: controller.suggestionsLoadingState, refresh: controller.loadAnimeSuggestions) {
                        ForEach(controller.animeSuggestions) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, jaTitle: item.node.alternativeTitles?.ja, imageUrl: item.node.mainPicture?.large, anime: item.node)
                        }
                    }
                    .task {
                        await controller.loadAnimeSuggestions()
                    }
                }
                if !settings.hideTopAiringAnime {
                    ScrollViewCarousel(title: "Top airing anime", loadingState: controller.airingLoadingState, refresh: controller.loadTopAiringAnime) {
                        ForEach(controller.topAiringAnime) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, jaTitle: item.node.alternativeTitles?.ja, imageUrl: item.node.mainPicture?.large, anime: item.node)
                        }
                    }
                    .task {
                        await controller.loadTopAiringAnime()
                    }
                }
                if !settings.hideTopUpcomingAnime {
                    ScrollViewCarousel(title: "Top upcoming anime", loadingState: controller.upcomingLoadingState, refresh: controller.loadTopUpcomingAnime) {
                        ForEach(controller.topUpcomingAnime) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, jaTitle: item.node.alternativeTitles?.ja, imageUrl: item.node.mainPicture?.large, anime: item.node)
                        }
                    }
                    .task {
                        await controller.loadTopUpcomingAnime()
                    }
                }
                if !settings.hideNewlyAddedAnime {
                    ScrollViewCarousel(title: "Newly added anime", loadingState: controller.newAnimeLoadingState, refresh: controller.loadNewlyAddedAnime) {
                        ForEach(controller.newlyAddedAnime) { item in
                            AnimeGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, jaTitle: item.titleJapanese, imageUrl: item.images?.jpg?.largeImageUrl, anime: Anime(item: item))
                        }
                    }
                    .task {
                        await controller.loadNewlyAddedAnime()
                    }
                }
                if !settings.hideNewlyAddedManga {
                    ScrollViewCarousel(title: "Newly added manga", loadingState: controller.newMangaLoadingState, refresh: controller.loadNewlyAddedManga) {
                        ForEach(controller.newlyAddedManga) { item in
                            MangaGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, jaTitle: item.titleJapanese, imageUrl: item.images?.jpg?.largeImageUrl, manga: Manga(item: item))

                        }
                    }
                    .task {
                        await controller.loadNewlyAddedManga()
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .refreshable {
            isRefresh = true
        }
        .task(id: isRefresh) {
            if isRefresh {
                await controller.refreshExplore()
                isRefresh = false
            }
        }
    }

    private var nothingFoundView: some View {
        ContentUnavailableView(
            "No results",
            systemImage: "magnifyingglass"
        )
    }

    private var searchView: some View {
        ZStack {
            VStack {
                if controller.isSearchLoading {
                    List {
                        Section {
                            LoadingList(length: 20)
                        }
                    }
                    .disabled(true)
                } else {
                    List {
                        Section {
                            if controller.type == .anime {
                                if controller.animeItems.isEmpty {
                                    if controller.isAnimeLoadingError && searchText.count > 2 {
                                        ErrorView(refresh: {
                                            controller.isSearchLoading = true
                                            await controller.searchAnime(query: searchText)
                                            controller.isSearchLoading = false
                                        })
                                        .padding(.vertical, 50)
                                    } else {
                                        nothingFoundView
                                    }
                                } else {
                                    ForEach(Array(controller.animeItems.enumerated()), id: \.1.id) { index, item in
                                        AnimeListItem(anime: item, selectedAnime: $selectedAnime, selectedAnimeIndex: $selectedAnimeIndex, index: index)
                                    }
                                }
                            } else if controller.type == .manga {
                                if controller.mangaItems.isEmpty {
                                    if controller.isMangaLoadingError && searchText.count > 2 {
                                        ErrorView(refresh: {
                                            controller.isSearchLoading = true
                                            await controller.searchManga(query: searchText)
                                            controller.isSearchLoading = false
                                        })
                                        .padding(.vertical, 50)
                                    } else {
                                        nothingFoundView
                                    }
                                } else {
                                    ForEach(Array(controller.mangaItems.enumerated()), id: \.1.id) { index, item in
                                        MangaListItem(manga: item, selectedManga: $selectedManga, selectedMangaIndex: $selectedMangaIndex, index: index)
                                    }
                                }
                            } else if controller.type == .character {
                                if controller.characterItems.isEmpty {
                                    if controller.isCharacterLoadingError && searchText.count > 2 {
                                        ErrorView(refresh: {
                                            controller.isSearchLoading = true
                                            await controller.searchCharacters(query: searchText)
                                            controller.isSearchLoading = false
                                        })
                                        .padding(.vertical, 50)
                                    } else {
                                        nothingFoundView
                                    }
                                } else {
                                    ForEach(controller.characterItems) { item in
                                        CharacterListItem(character: item)
                                    }
                                }
                            } else if controller.type == .person {
                                if controller.personItems.isEmpty {
                                    if controller.isPersonLoadingError && searchText.count > 2 {
                                        ErrorView(refresh: {
                                            controller.isSearchLoading = true
                                            await controller.searchPeople(query: searchText)
                                            controller.isSearchLoading = false
                                        })
                                        .padding(.vertical, 50)
                                    } else {
                                        nothingFoundView
                                    }
                                } else {
                                    ForEach(controller.personItems) { item in
                                        PersonListItem(person: item)
                                    }
                                }
                            }
                        } footer: {
                            Rectangle()
                                .frame(height: 35)
                                .foregroundStyle(.clear)
                        }
                        .padding(.bottom, 10)
                    }
                    .id("search:\(controller.type)\(searchText)") // To reset list to top position whenever search type or search text is changed
                }
            }
            if controller.isRefreshLoading && !controller.isSearchLoading {
                LoadingView()
            }
        }
        .task(id: urlSearchText) {
            if let urlSearchText {
                previousSearch = ""
                controller.resetSearch()
                searchText = urlSearchText
            }
            urlSearchText = nil
        }
        .task(id: searchText) {
            if searchText != previousSearch {
                controller.isSearchLoading = true
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
                if let index = selectedAnimeIndex, let animeListStatus {
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
            AnimeEditView(id: anime.id, listStatus: anime.listStatus, title: anime.node.title, alternativeTitles: anime.node.alternativeTitles, numEpisodes: anime.node.numEpisodes, imageUrl: anime.node.mainPicture?.large, isDeleted: $isAnimeDeleted, animeListStatus: $animeListStatus)
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
                if let index = selectedMangaIndex, let mangaListStatus {
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
            MangaEditView(id: manga.id, listStatus: manga.listStatus, title: manga.node.title, alternativeTitles: manga.node.alternativeTitles, numVolumes: manga.node.numVolumes, numChapters: manga.node.numChapters, imageUrl: manga.node.mainPicture?.large, isDeleted: $isMangaDeleted, mangaListStatus: $mangaListStatus)
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
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            ZStack {
                if isPresented {
                    searchView
                } else {
                    exploreView
                }
                if isPresented {
                    if #unavailable(iOS 26.2) {
                        TabPicker(selection: $controller.type, options: Constants.searchTypes.map { ($0.rawValue.capitalized, $0) })
                    } else if horizontalSizeClass != .compact {
                        TabPicker(selection: $controller.type, options: Constants.searchTypes.map { ($0.rawValue.capitalized, $0) })
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.keyboard)
            .searchable(text: $searchText, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .onChange(of: isPresented) {
                guard urlSearchText == nil else {
                    return
                }

                searchText = ""
                previousSearch = ""
                controller.resetSearch()
            }
            .navigationTitle("Explore")
            .toolbar {
                if !settings.hideRandom {
                    randomButton
                }
            }
            .navigationDestinations()
        }
        .onChange(of: pickerType) {
            controller.type = pickerType
        }
    }
}
