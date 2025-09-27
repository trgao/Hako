//
//  CharacterDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 2/5/24.
//

import SwiftUI

struct CharacterDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject var controller: CharacterDetailsViewController
    @State private var isRefresh = false
    private let id: Int
    private let url: URL
    
    init (id: Int) {
        self.id = id
        self.url = URL(string: "https://myanimelist.net/character/\(id)")!
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.character == nil {
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
                                ForEach(animes) { anime in
                                    ScrollViewListItem(title: anime.anime.title, subtitle: anime.role) {
                                        ImageFrame(id: "anime\(anime.id)", imageUrl: anime.anime.images?.jpg?.largeImageUrl, imageSize: .small)
                                    } destination: {
                                        AnimeDetailsView(id: anime.id)
                                    }
                                }
                            }
                        }
                        if let mangas = character.manga, !mangas.isEmpty {
                            ScrollViewListSection(title: "Mangas", isExpandable: true) {
                                ForEach(mangas) { manga in
                                    ScrollViewListItem(title: manga.manga.title, subtitle: manga.role) {
                                        ImageFrame(id: "manga\(manga.id)", imageUrl: manga.manga.images?.jpg?.largeImageUrl, imageSize: .small)
                                    } destination: {
                                        MangaDetailsView(id: manga.id)
                                    }
                                }
                            }
                        }
                        if let voices = character.voices, !voices.isEmpty {
                            ScrollViewListSection(title: "Voices", isExpandable: true) {
                                ForEach(voices) { voice in
                                    ScrollViewListItem(title: voice.person.name, subtitle: voice.language) {
                                        ImageFrame(id: "person\(voice.id)", imageUrl: voice.person.images?.jpg?.imageUrl, imageSize: .small)
                                    } destination: {
                                        PersonDetailsView(id: voice.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
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
                    ImageFrame(id: "character\(id)", imageUrl: character.images?.jpg?.imageUrl, imageSize: .background)
                }
            }
            if controller.isLoading {
                LoadingView()
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
