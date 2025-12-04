//
//  PersonDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/24.
//

import SwiftUI

struct PersonDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: PersonDetailsViewController
    @State private var isRefresh = false
    @State private var voiceIndex: Int?
    @State private var animeIndex: Int?
    @State private var mangaIndex: Int?
    private let id: Int
    
    init (id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: PersonDetailsViewController(id: id))
    }
    
    init (id: Int, name: String?) {
        self.id = id
        self._controller = StateObject(wrappedValue: PersonDetailsViewController(id: id, name: name))
    }
    
    private func formatPosition(_ position: String?) -> String? {
        if let position = position, position.prefix(3) == "add" {
            return String(position.suffix(from: position.index(position.startIndex, offsetBy: 4)))
        }
        return position
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.person == nil {
                ErrorView(refresh: controller.refresh)
            } else {
                if let person = controller.person {
                    ScrollView {
                        VStack {
                            VStack {
                                ImageCarousel(id: "person\(person.id)", imageUrl: person.images?.jpg?.imageUrl, pictures: [Picture(medium: person.images?.jpg?.imageUrl, large: person.images?.jpg?.largeImageUrl)])
                                NameText(english: person.name, birthday: person.birthday?.toString())
                                Favourites(favorites: controller.person?.favorites)
                            }
                            .padding(.horizontal, 20)
                            TextBox(title: "About", text: person.about)
                            if let voices = person.voices, !voices.isEmpty {
                                ScrollViewListSection(title: "Voice acting roles", isExpandable: true) {
                                    ForEach(Array(voices.enumerated()), id: \.1.id) { index, voice in
                                        ScrollViewListItem(id: "anime\(voice.anime.id)", title: voice.anime.title, subtitle: voice.character.name, imageUrl: voice.anime.images?.jpg?.imageUrl, url: "https://myanimelist.net/anime/\(voice.anime.id)", index: index, selectedIndex: $voiceIndex)
                                    }
                                }
                            }
                            if let animes = person.anime, !animes.isEmpty {
                                ScrollViewListSection(title: "Anime staff positions", isExpandable: true) {
                                    ForEach(Array(animes.enumerated()), id: \.1.id) { index, anime in
                                        ScrollViewListItem(id: "anime\(anime.id)", title: anime.anime.title, subtitle: formatPosition(anime.position), imageUrl: anime.anime.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/anime/\(anime.id)", index: index, selectedIndex: $animeIndex)
                                    }
                                }
                            }
                            if let mangas = person.manga, !mangas.isEmpty {
                                ScrollViewListSection(title: "Manga staff positions", isExpandable: true) {
                                    ForEach(Array(mangas.enumerated()), id: \.1.id) { index, manga in
                                        ScrollViewListItem(id: "manga\(manga.id)", title: manga.manga.title, subtitle: formatPosition(manga.position), imageUrl: manga.manga.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/manga/\(manga.id)", index: index, selectedIndex: $mangaIndex)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .navigationDestination(item: $voiceIndex) { index in
                        if let voices = person.voices {
                            AnimeDetailsView(anime: Anime(id: voices[index].anime.id, title: voices[index].anime.title ?? "", enTitle: nil))
                        }
                    }
                    .navigationDestination(item: $animeIndex) { index in
                        if let animes = person.anime {
                            AnimeDetailsView(anime: Anime(id: animes[index].id, title: animes[index].anime.title ?? "", enTitle: nil))
                        }
                    }
                    .navigationDestination(item: $mangaIndex) { index in
                        if let mangas = person.manga {
                            MangaDetailsView(manga: Manga(id: mangas[index].id, title: mangas[index].manga.title ?? "", enTitle: nil))
                        }
                    }
                    .task(id: isRefresh) {
                        if isRefresh || controller.isLoadingError {
                            await controller.refresh()
                            isRefresh = false
                        }
                    }
                    .refreshable {
                        isRefresh = true
                    }
                    .scrollContentBackground(settings.translucentBackground ? .hidden : .visible)
                    .background {
                        ImageFrame(id: "person\(id)", imageUrl: person.images?.jpg?.imageUrl, imageSize: .background)
                    }
                }
                if controller.isLoading && (controller.person == nil || controller.person!.isEmpty()) {
                    LoadingView()
                }
            }
        }
        .toolbar {
            if controller.isLoadingError && controller.person != nil && controller.person!.isEmpty() {
                Button {
                    Task {
                        await controller.refresh()
                    }
                } label: {
                    Image(systemName: "exclamationmark.triangle")
                }
            }
            ShareLink(item: URL(string: "https://myanimelist.net/people/\(id)")!) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
