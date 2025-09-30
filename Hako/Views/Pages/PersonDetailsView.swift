//
//  PersonDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/24.
//

import SwiftUI

struct PersonDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject var controller: PersonDetailsViewController
    @State private var isRefresh = false
    private let id: Int
    private let url: URL
    
    init (id: Int) {
        self.id = id
        self.url = URL(string: "https://myanimelist.net/people/\(id)")!
        self._controller = StateObject(wrappedValue: PersonDetailsViewController(id: id))
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
                                    ForEach(voices) { voice in
                                        ScrollViewListItem(title: voice.anime.title, subtitle: voice.character.name) {
                                            ImageFrame(id: "anime\(voice.anime.id)", imageUrl: voice.anime.images?.jpg?.imageUrl, imageSize: .small)
                                        } destination: {
                                            AnimeDetailsView(id: voice.anime.id)
                                        }
                                    }
                                }
                            }
                            if let animes = person.anime, !animes.isEmpty {
                                ScrollViewListSection(title: "Anime staff positions", isExpandable: true) {
                                    ForEach(animes) { anime in
                                        ScrollViewListItem(title: anime.anime.title, subtitle: formatPosition(anime.position)) {
                                            ImageFrame(id: "anime\(anime.id)", imageUrl: anime.anime.images?.jpg?.largeImageUrl, imageSize: .small)
                                        } destination: {
                                            AnimeDetailsView(id: anime.id)
                                        }
                                    }
                                }
                            }
                            if let mangas = person.manga, !mangas.isEmpty {
                                ScrollViewListSection(title: "Manga staff positions", isExpandable: true) {
                                    ForEach(mangas) { manga in
                                        ScrollViewListItem(title: manga.manga.title, subtitle: formatPosition(manga.position)) {
                                            ImageFrame(id: "manga\(manga.id)", imageUrl: manga.manga.images?.jpg?.largeImageUrl, imageSize: .small)
                                        } destination: {
                                            MangaDetailsView(id: manga.id)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .task(id: isRefresh) {
                        if isRefresh {
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
                if controller.isLoading {
                    LoadingView()
                }
            }
        }
        .toolbar {
            ShareLink(item: url) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
