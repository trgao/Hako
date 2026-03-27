//
//  ExploreView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SystemNotification

struct ExploreView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
    @Binding private var id: UUID
    @Binding private var path: [ViewItem]
    @Binding private var isPresented: Bool
    @Binding private var isRoot: Bool
    @Binding private var urlSearchText: String?
    
    init(id: Binding<UUID>, path: Binding<[ViewItem]>, isPresented: Binding<Bool>, isRoot: Binding<Bool>, urlSearchText: Binding<String?>) {
        self._id = id
        self._path = path
        self._isPresented = isPresented
        self._isRoot = isRoot
        self._urlSearchText = urlSearchText
    }
    
    @ViewBuilder private var exploreAnimeManga: some View {
        if dynamicTypeSize <= .xxLarge {
            HStack {
                ExploreBox(title: "Anime", image: "tv.fill") {
                    ExploreAnimeView()
                }
                Spacer()
                ExploreBox(title: "Manga", image: "book.fill") {
                    ExploreMangaView()
                }
            }
            .padding(.horizontal, 17)
            Spacer()
        } else {
            ExploreBox(title: "Anime", image: "tv.fill") {
                ExploreAnimeView()
            }
            .padding(.horizontal, 17)
            Spacer()
            ExploreBox(title: "Manga", image: "book.fill") {
                ExploreMangaView()
            }
            .padding(.horizontal, 17)
            Spacer()
        }
    }
    
    @ViewBuilder private var exploreCharactersPeople: some View {
        if dynamicTypeSize <= .xxLarge {
            HStack {
                ExploreBox(title: "Characters", image: "person.crop.circle.fill") {
                    ExploreCharactersView()
                }
                Spacer()
                ExploreBox(title: "People", image: "person.fill") {
                    ExplorePeopleView()
                }
            }
            .padding(.horizontal, 17)
            Spacer()
        } else {
            ExploreBox(title: "Characters", image: "person.crop.circle.fill") {
                ExploreCharactersView()
            }
            .padding(.horizontal, 17)
            Spacer()
            ExploreBox(title: "People", image: "person.fill") {
                ExplorePeopleView()
            }
            .padding(.horizontal, 17)
            Spacer()
        }
    }
    
    private var exploreView: some View {
        ScrollView {
            VStack {
                VStack {
                    if !settings.hideExploreAnimeManga {
                        exploreAnimeManga
                    }
                    if !settings.hideExploreCharactersPeople {
                        exploreCharactersPeople
                    }
                    if !settings.hideNews {
                        ExploreBox(title: "News", image: "newspaper.fill") {
                            NewsListView()
                        }
                        .padding(.horizontal, 17)
                        Spacer()
                    }
                }
                Spacer()
                if !settings.hideRecentlyViewed && !settings.recentlyViewedItems.isEmpty {
                    ScrollViewCarousel(title: "Recently viewed") {
                        ForEach(settings.recentlyViewedItems.reversed()) { item in
                            if let anime = item.anime {
                                AnimeGridItem(id: anime.id, title: anime.title, enTitle: anime.alternativeTitles?.en, imageUrl: anime.mainPicture?.large, anime: anime, isRecentlyViewed: true)
                            } else if let manga = item.manga {
                                MangaGridItem(id: manga.id, title: manga.title, enTitle: manga.alternativeTitles?.en, imageUrl: manga.mainPicture?.large, manga: manga, isRecentlyViewed: true)
                            }
                        }
                    }
                }
                if networker.isSignedIn && !settings.hideAnimeForYou {
                    ScrollViewCarousel(title: "Anime for you", loadingState: controller.suggestionsLoadingState, refresh: controller.loadAnimeSuggestions) {
                        ForEach(controller.animeSuggestions) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                        }
                    }
                    .task {
                        await controller.loadAnimeSuggestions()
                    }
                }
                if !settings.hideTopAiringAnime {
                    ScrollViewCarousel(title: "Top airing anime", loadingState: controller.airingLoadingState, refresh: controller.loadTopAiringAnime) {
                        ForEach(controller.topAiringAnime) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                        }
                    }
                    .task {
                        await controller.loadTopAiringAnime()
                    }
                }
                if !settings.hideTopUpcomingAnime {
                    ScrollViewCarousel(title: "Top upcoming anime", loadingState: controller.upcomingLoadingState, refresh: controller.loadTopUpcomingAnime) {
                        ForEach(controller.topUpcomingAnime) { item in
                            AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large, anime: item.node)
                        }
                    }
                    .task {
                        await controller.loadTopUpcomingAnime()
                    }
                }
                if !settings.hideNewlyAddedAnime {
                    ScrollViewCarousel(title: "Newly added anime", loadingState: controller.newAnimeLoadingState, refresh: controller.loadNewlyAddedAnime) {
                        ForEach(controller.newlyAddedAnime) { item in
                            AnimeGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, anime: Anime(item: item))
                        }
                    }
                    .task {
                        await controller.loadNewlyAddedAnime()
                    }
                }
                if !settings.hideNewlyAddedManga {
                    ScrollViewCarousel(title: "Newly added manga", loadingState: controller.newMangaLoadingState, refresh: controller.loadNewlyAddedManga) {
                        ForEach(controller.newlyAddedManga) { item in
                            MangaGridItem(id: item.id, title: item.title, enTitle: item.titleEnglish, imageUrl: item.images?.jpg?.largeImageUrl, manga: Manga(item: item))

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
                                            await controller.searchCharacter(query: searchText)
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
                                            await controller.searchPerson(query: searchText)
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
            if let urlSearchText = urlSearchText {
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
        NavigationStack(path: $path) {
            ZStack {
                if isPresented {
                    searchView
                } else {
                    exploreView
                }
                if isPresented {
                    TabPicker(selection: $controller.type, options: Constants.searchTypes.map{ ($0.rawValue.capitalized, $0) })
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
                            Label("Random character", systemImage: "person.crop.circle")
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
                    }
                }
            }
            .onAppear {
                isRoot = true
            }
            .onDisappear {
                isRoot = false
            }
            .navigationDestination(for: ViewItem.self) { item in
                switch item.type {
                case .anime: AnimeDetailsView(id: item.id)
                case .manga: MangaDetailsView(id: item.id)
                case .character: CharacterDetailsView(id: item.id)
                case .person: PersonDetailsView(id: item.id)
                case .animeGenre: GroupDetailsView(title: Constants.animeGenres[item.id] ?? Constants.animeThemes[item.id] ?? Constants.animeDemographics[item.id], group: "genres", id: item.id, type: .anime)
                case .mangaGenre: GroupDetailsView(title: Constants.mangaGenres[item.id] ?? Constants.mangaThemes[item.id] ?? Constants.mangaDemographics[item.id], group: "genres", id: item.id, type: .manga)
                case .producer: GroupDetailsView(title: item.name, group: "producers", id: item.id, type: .anime)
                case .magazine: GroupDetailsView(title: item.name, group: "magazines", id: item.id, type: .manga)
                case .news: NewsListView()
                case .exploreAnime: ExploreAnimeView()
                case .exploreManga: ExploreMangaView()
                case .exploreCharacters: ExploreCharactersView()
                case .explorePeople: ExplorePeopleView()
                case .exploreStudios: StudiosListView()
                case .exploreMagazines: MagazinesListView()
                case .userlist: UserListView(user: item.name ?? "", type: item.listType, animeStatus: item.animeStatus, animeSort: item.animeSort, mangaStatus: item.mangaStatus, mangaSort: item.mangaSort)
                case .profile: UserProfileView(user: item.name ?? "")
                }
            }
        }
        .id(id)
        .task(id: id) {
            if path.isEmpty {
                isRoot = true
            }
        }
    }
}

struct ExploreBox<Destination: View>: View {
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    @State private var isPressed = false
    @State private var isLongPress = false
    private let title: String
    private let image: String
    private let destination: () -> Destination

    init(title: String, image: String, destination: @escaping () -> Destination) {
        self.title = title
        self.image = image
        self.destination = destination
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: image)
                .foregroundStyle(settings.getAccentColor())
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPressed = true
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isLongPress = pressing
        }) {}
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isPressed || isLongPress ? Color(.systemGray4) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .navigationDestination(isPresented: $isPressed, destination: destination)
    }
}
