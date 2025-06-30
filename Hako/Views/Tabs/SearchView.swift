//
//  SearchView.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller = SearchViewController()
    @StateObject var networker = NetworkManager.shared
    @State private var isPresented = false
    @DebouncedState private var searchText = ""
    @State private var previousSearch = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if isPresented {
                        Section {
                            if controller.type == .anime {
                                if controller.isAnimeLoadingError {
                                    ErrorView(refresh: { await controller.search(searchText) })
                                } else if controller.isAnimeSearchLoading {
                                    LoadingList()
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
                                } else {
                                    ForEach(controller.animeItems, id: \.id) { item in
                                        AnimeListItem(anime: item)
                                    }
                                }
                            } else if controller.type == .manga {
                                if controller.isMangaLoadingError {
                                    ErrorView(refresh: { await controller.search(searchText) })
                                } else if controller.isMangaSearchLoading {
                                    LoadingList()
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
                                } else {
                                    ForEach(controller.mangaItems, id: \.id) { item in
                                        MangaListItem(manga: item)
                                    }
                                }
                            } else if controller.type == .character {
                                if controller.isCharacterLoadingError {
                                    ErrorView(refresh: { await controller.search(searchText) })
                                } else if controller.isCharacterSearchLoading {
                                    LoadingList()
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
                                } else {
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
                                }
                            } else if controller.type == .person {
                                if controller.isPersonLoadingError {
                                    ErrorView(refresh: { await controller.search(searchText) })
                                } else if controller.isPersonSearchLoading {
                                    LoadingList()
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
                                } else {
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
                .scrollDismissesKeyboard(.immediately)
                .ignoresSafeArea(.keyboard)
                .overlay {
                    if !isPresented {
                        ScrollView {
                            VStack {
                                if networker.isSignedIn && !settings.hideForYou {
                                    if controller.animeSuggestions.isEmpty {
                                        LoadingCarousel(title: "For you")
                                    } else {
                                        VStack {
                                            Text("For you")
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
                                if !settings.hideTopAiring {
                                    if controller.topAiringAnime.isEmpty {
                                        LoadingCarousel(title: "Top airing")
                                    } else {
                                        VStack {
                                            Text("Top airing")
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
                                if !settings.hideTopUpcoming {
                                    if controller.topUpcomingAnime.isEmpty {
                                        LoadingCarousel(title: "Top upcoming")
                                    } else {
                                        VStack {
                                            Text("Top upcoming")
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
                                if !settings.hideMostPopularAnime {
                                    if controller.topPopularAnime.isEmpty {
                                        LoadingCarousel(title: "Most popular anime")
                                    } else {
                                        VStack {
                                            Text("Most popular anime")
                                                .bold()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 35)
                                                .font(.system(size: 17))
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(alignment: .top) {
                                                    ForEach(controller.topPopularAnime) { item in
                                                        AnimeGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                        }
                                    }
                                }
                                if !settings.hideMostPopularManga {
                                    if controller.topPopularManga.isEmpty {
                                        LoadingCarousel(title: "Most popular manga")
                                    } else {
                                        VStack {
                                            Text("Most popular manga")
                                                .bold()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 35)
                                                .font(.system(size: 17))
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(alignment: .top) {
                                                    ForEach(controller.topPopularManga) { item in
                                                        MangaGridItem(id: item.id, title: item.node.title, enTitle: item.node.alternativeTitles?.en, imageUrl: item.node.mainPicture?.large)
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
                }
                .searchable(text: $searchText, isPresented: $isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
                .task(id: searchText) {
                    if searchText.count > 2 {
                        if previousSearch != searchText {
                            await controller.search(searchText)
                            previousSearch = searchText
                        }
                    } else {
                        controller.animeItems = []
                        controller.mangaItems = []
                        controller.characterItems = []
                        controller.personItems = []
                    }
                }
                .onChange(of: isPresented) {
                    controller.animeItems = []
                    controller.mangaItems = []
                    controller.characterItems = []
                    controller.personItems = []
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
            .navigationTitle("Search")
            .toolbar {
                if !settings.hideRandom {
                    Menu {
                        NavigationLink("Random anime") {
                            RandomAnimeView()
                        }
                        NavigationLink("Random manga") {
                            RandomMangaView()
                        }
                        NavigationLink("Random character") {
                            RandomCharacterView()
                        }
                        NavigationLink("Random person") {
                            RandomPersonView()
                        }
                    } label: {
                        Button {} label: {
                            Image(systemName: "dice")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
}
