//
//  CharacterDetailsView.swift
//  Hako
//
//  Created by Gao Tianrun on 2/5/24.
//

import SwiftUI

struct CharacterDetailsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var controller: CharacterDetailsViewController
    @State private var hideTitle = true
    @State private var isRefresh = false
    @State private var animeIndex: Int?
    @State private var mangaIndex: Int?
    @State private var voiceIndex: Int?
    private let id: Int

    init(id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id: id))
    }

    init(id: Int, name: String?, imageUrl: String?) {
        self.id = id
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id: id, name: name, imageUrl: imageUrl))
    }

    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.character == nil {
                ErrorView(refresh: controller.refresh)
            } else if let character = controller.character {
                ScrollView {
                    VStack {
                        VStack {
                            ImageCarousel(id: "character\(character.id)", imageUrl: character.images?.jpg?.imageUrl, pictures: [Picture(images: character.images)])
                            NameText(english: character.name, japanese: character.nameKanji)
                                .onScrollVisibilityChange({ hideTitle = $0 })
                            Favourites(favorites: controller.character?.favorites)
                        }
                        .padding(.horizontal, 17)
                        if controller.loadingState == .loading && character.isEmpty() {
                            ProgressView()
                        }
                        TextBox(title: "About", text: character.about)
                        if let animes = character.anime, !animes.isEmpty {
                            ScrollViewListSection(title: "Animes") {
                                ForEach(animes, id: \.id) { anime in
                                    ScrollViewListItem(id: "anime\(anime.id)", title: anime.anime.title, subtitle: anime.role, imageUrl: anime.anime.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/anime/\(anime.id)", item: Anime(id: anime.id, title: anime.anime.title ?? "", imageUrl: anime.anime.images?.jpg?.largeImageUrl))
                                }
                            }
                        }
                        if let mangas = character.manga, !mangas.isEmpty {
                            ScrollViewListSection(title: "Mangas") {
                                ForEach(mangas, id: \.id) { manga in
                                    ScrollViewListItem(id: "manga\(manga.id)", title: manga.manga.title, subtitle: manga.role, imageUrl: manga.manga.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/manga/\(manga.id)", item: Manga(id: manga.id, title: manga.manga.title ?? "", imageUrl: manga.manga.images?.jpg?.largeImageUrl))
                                }
                            }
                        }
                        if let voices = character.voices, !voices.isEmpty {
                            ScrollViewListSection(title: "Voices") {
                                ForEach(voices, id: \.id) { voice in
                                    ScrollViewListItem(id: "person\(voice.id)", title: voice.person.name, subtitle: voice.language, imageUrl: voice.person.images?.jpg?.imageUrl, url: "https://myanimelist.net/people/\(voice.id)", item: Person(id: voice.id, name: voice.person.name, imageUrl: voice.person.images?.jpg?.imageUrl))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 15)
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
            if controller.loadingState == .loading && controller.character == nil {
                LoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(controller.character?.name ?? "")
        .toolbar {
            if hideTitle {
                ToolbarItem(placement: .title) {
                    Text("").hidden()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let character = controller.character, !character.isEmpty() && controller.loadingState == .loading {
                    ProgressView()
                } else if controller.loadingState == .error {
                    Button {
                        Task {
                            await controller.refresh()
                        }
                    } label: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: URL(string: "https://myanimelist.net/character/\(id)")!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
