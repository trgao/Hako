//
//  CharacterDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 2/5/24.
//

import SwiftUI

struct CharacterDetailsView: View {
    @Environment(\.screenSize) private var screenSize
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: CharacterDetailsViewController
    @State private var isRefresh = false
    @State private var animeIndex: Int?
    @State private var mangaIndex: Int?
    @State private var voiceIndex: Int?
    private let id: Int
    
    init(id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id: id))
    }
    
    init(id: Int, name: String?) {
        self.id = id
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id: id, name: name))
    }
    
    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.character == nil {
                ErrorView(refresh: controller.refresh)
            } else if let character = controller.character {
                ScrollView {
                    VStack {
                        VStack {
                            ImageCarousel(id: "character\(character.id)", imageUrl: character.images?.jpg?.imageUrl, pictures: [Picture(medium: character.images?.jpg?.imageUrl, large: character.images?.jpg?.largeImageUrl)])
                            NameText(english: character.name, japanese: character.nameKanji)
                            Favourites(favorites: controller.character?.favorites)
                        }
                        .padding(.horizontal, 20)
                        TextBox(title: "About", text: character.about)
                        if let animes = character.anime, !animes.isEmpty {
                            ScrollViewListSection(title: "Animes", isExpandable: true) {
                                ForEach(Array(animes.enumerated()), id: \.1.id) { index, anime in
                                    ScrollViewListItem(id: "anime\(anime.id)", title: anime.anime.title, subtitle: anime.role, imageUrl: anime.anime.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/anime/\(anime.id)", index: index, selectedIndex: $animeIndex)
                                }
                            }
                        }
                        if let mangas = character.manga, !mangas.isEmpty {
                            ScrollViewListSection(title: "Mangas", isExpandable: true) {
                                ForEach(Array(mangas.enumerated()), id: \.1.id) { index, manga in
                                    ScrollViewListItem(id: "manga\(manga.id)", title: manga.manga.title, subtitle: manga.role, imageUrl: manga.manga.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/manga/\(manga.id)", index: index, selectedIndex: $mangaIndex)
                                }
                            }
                        }
                        if let voices = character.voices, !voices.isEmpty {
                            ScrollViewListSection(title: "Voices", isExpandable: true) {
                                ForEach(Array(voices.enumerated()), id: \.1.id) { index, voice in
                                    ScrollViewListItem(id: "person\(voice.id)", title: voice.person.name, subtitle: voice.language, imageUrl: voice.person.images?.jpg?.imageUrl, url: "https://myanimelist.net/people/\(voice.id)", index: index, selectedIndex: $voiceIndex)
                                }
                            }
                        }
                    }
                    .frame(width: screenSize.width)
                    .padding(.vertical, 20)
                }
                .navigationDestination(item: $animeIndex) { index in
                    if let animes = character.anime {
                        AnimeDetailsView(anime: Anime(id: animes[index].id, title: animes[index].anime.title ?? "", enTitle: nil))
                    }
                }
                .navigationDestination(item: $mangaIndex) { index in
                    if let mangas = character.manga {
                        MangaDetailsView(manga: Manga(id: mangas[index].id, title: mangas[index].manga.title ?? "", enTitle: nil))
                    }
                }
                .navigationDestination(item: $voiceIndex) { index in
                    if let voices = character.voices {
                        PersonDetailsView(id: voices[index].id, name: voices[index].person.name)
                    }
                }
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.loadingState == .error || isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .scrollContentBackground(settings.translucentBackground ? .hidden : .visible)
                .background {
                    ImageFrame(id: "character\(id)", imageUrl: character.images?.jpg?.imageUrl, imageSize: .background)
                }
            } else if controller.loadingState == .idle {
                VStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 10)
                    Text("Character not found")
                        .bold()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if controller.loadingState == .loading && (controller.character == nil || controller.character!.isEmpty()) {
                LoadingView()
            }
        }
        .toolbar {
            if controller.loadingState == .error && controller.character != nil && controller.character!.isEmpty() {
                Button {
                    Task {
                        await controller.refresh()
                    }
                } label: {
                    Image(systemName: "exclamationmark.triangle")
                }
            }
            ShareLink(item: URL(string: "https://myanimelist.net/character/\(id)")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
