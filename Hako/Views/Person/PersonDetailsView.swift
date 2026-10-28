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
    @State private var hideTitle = true
    @State private var isRefresh = false
    @State private var voiceIndex: Int?
    @State private var animeIndex: Int?
    @State private var mangaIndex: Int?
    private let id: Int

    init (id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: PersonDetailsViewController(id: id))
    }

    init (id: Int, name: String?, imageUrl: String?) {
        self.id = id
        self._controller = StateObject(wrappedValue: PersonDetailsViewController(id: id, name: name, imageUrl: imageUrl))
    }

    private func formatPosition(_ position: String?) -> String? {
        if let position, position.prefix(3) == "add" {
            return String(position.suffix(from: position.index(position.startIndex, offsetBy: 4)))
        }
        return position
    }

    var body: some View {
        ZStack {
            if controller.loadingState == .error && controller.person == nil {
                ErrorView(refresh: controller.refresh)
            } else {
                if let person = controller.person {
                    ScrollView {
                        VStack {
                            VStack {
                                ImageCarousel(id: "person\(person.id)", imageUrl: person.images?.jpg?.imageUrl, pictures: [Picture(images: person.images)])
                                NameText(english: person.name, birthday: person.birthday?.toString())
                                    .onScrollVisibilityChange({ hideTitle = $0 })
                                Favourites(favorites: controller.person?.favorites)
                            }
                            .padding(.horizontal, 17)
                            if controller.loadingState == .loading && person.isEmpty() {
                                ProgressView()
                            }
                            TextBox(title: "About", text: person.about)
                            if let voices = person.voices, !voices.isEmpty {
                                ScrollViewListSection(title: "Voice acting roles") {
                                    ForEach(voices, id: \.id) { voice in
                                        ScrollViewListItem(id: "anime\(voice.anime.id)", title: voice.anime.title, subtitle: voice.character.name, imageUrl: voice.anime.images?.jpg?.imageUrl, url: "https://myanimelist.net/anime/\(voice.anime.id)", item: .anime(Anime(id: voice.anime.id, title: voice.anime.title ?? "", imageUrl: voice.anime.images?.jpg?.largeImageUrl)))
                                    }
                                }
                            }
                            if let animes = person.anime, !animes.isEmpty {
                                ScrollViewListSection(title: "Anime staff positions") {
                                    ForEach(animes, id: \.id) { anime in
                                        ScrollViewListItem(id: "anime\(anime.id)", title: anime.anime.title, subtitle: formatPosition(anime.position), imageUrl: anime.anime.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/anime/\(anime.id)", item: .anime(Anime(id: anime.id, title: anime.anime.title ?? "", imageUrl: anime.anime.images?.jpg?.largeImageUrl)))
                                    }
                                }
                            }
                            if let mangas = person.manga, !mangas.isEmpty {
                                ScrollViewListSection(title: "Manga staff positions") {
                                    ForEach(mangas, id: \.id) { manga in
                                        ScrollViewListItem(id: "manga\(manga.id)", title: manga.manga.title, subtitle: formatPosition(manga.position), imageUrl: manga.manga.images?.jpg?.largeImageUrl, url: "https://myanimelist.net/manga/\(manga.id)", item: .manga(Manga(id: manga.id, title: manga.manga.title ?? "", imageUrl: manga.manga.images?.jpg?.largeImageUrl)))
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
                        ImageFrame(id: "person\(id)", imageUrl: person.images?.jpg?.imageUrl, imageSize: .background)
                    }
                } else if controller.loadingState == .idle {
                    VStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.bottom, 10)
                        Text("Person not found")
                            .bold()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                if controller.loadingState == .loading && controller.person == nil {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(controller.person?.name ?? "")
        .toolbar {
            if hideTitle {
                ToolbarItem(placement: .title) {
                    Text("").hidden()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let person = controller.person, !person.isEmpty() && controller.loadingState == .loading {
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
                ShareLink(item: URL(string: "https://myanimelist.net/people/\(id)")!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
