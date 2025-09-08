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
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.person == nil {
                ErrorView(refresh: controller.refresh)
            } else {
                if let person = controller.person {
                    PageList {
                        Favourites(favorites: controller.person?.favorites)
                        TextBox(title: "About", text: person.about)
                        PersonVoiceSection(voices: person.voices)
                        PersonAnimeSection(animes: person.anime)
                        PersonMangaSection(mangas: person.manga)
                    } photo: {
                        ImageFrame(id: "person\(person.id)", imageUrl: controller.person?.images?.jpg?.imageUrl, imageSize: .large)
                    } title: {
                        NameText(english: person.name, birthday: person.birthday?.toString())
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
                        ImageFrame(id: "person\(id)", imageUrl: controller.person?.images?.jpg?.imageUrl, imageSize: .background)
                    }
                }
                if controller.isLoading {
                    LoadingView()
                }
            }
        }
        .toolbar {
            Menu {
                ShareLink("Share", item: url)
                Link(destination: url) {
                    Label("Open in browser", systemImage: "globe")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .handleOpenURLInApp()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PersonVoiceSection: View {
    @State private var isExpanded = true
    private let voices: [AnimeVoice]
    
    init(voices: [AnimeVoice]?) {
        if let voices = voices {
            self.voices = voices
        } else {
            self.voices = []
        }
    }
    
    var body: some View {
        if !voices.isEmpty {
            Section(isExpanded: $isExpanded) {
                ForEach(voices) { voice in
                    NavigationLink {
                        AnimeDetailsView(id: voice.anime.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "anime\(voice.anime.id)", imageUrl: voice.anime.images?.jpg?.imageUrl, imageSize: .small)
                                .padding(.trailing, 10)
                            VStack(alignment: .leading) {
                                Text(voice.anime.title ?? "")
                                Text(voice.character.name ?? "")
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                ExpandableSectionHeader(title: "Voice acting roles", isExpanded: $isExpanded)
            }
        }
    }
}

struct PersonAnimeSection: View {
    @State private var isExpanded = true
    private let animes: [AnimePosition]
    
    init(animes: [AnimePosition]?) {
        if let animes = animes {
            self.animes = animes
        } else {
            self.animes = []
        }
    }
    
    var body: some View {
        if !animes.isEmpty {
            Section(isExpanded: $isExpanded) {
                ForEach(animes) { anime in
                    NavigationLink {
                        AnimeDetailsView(id: anime.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "anime\(anime.id)", imageUrl: anime.anime.images?.jpg?.largeImageUrl, imageSize: .small)
                                .padding(.trailing, 10)
                            VStack(alignment: .leading) {
                                Text(anime.anime.title ?? "")
                                if let position = anime.position {
                                    Text(position.prefix(3) == "add" ? position.suffix(position.count - 4) : position.prefix(position.count))
                                        .foregroundStyle(Color(.systemGray))
                                        .font(.system(size: 13))
                                }
                            }
                        }
                    }
                }
            } header: {
                ExpandableSectionHeader(title: "Anime staff positions", isExpanded: $isExpanded)
            }
        }
    }
}

struct PersonMangaSection: View {
    @State private var isExpanded = true
    private let mangas: [MangaPosition]
    
    init(mangas: [MangaPosition]?) {
        if let mangas = mangas {
            self.mangas = mangas
        } else {
            self.mangas = []
        }
    }
    
    var body: some View {
        if !mangas.isEmpty {
            Section(isExpanded: $isExpanded) {
                ForEach(mangas) { manga in
                    NavigationLink {
                        MangaDetailsView(id: manga.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "manga\(manga.id)", imageUrl: manga.manga.images?.jpg?.largeImageUrl, imageSize: .small)
                                .padding(.trailing, 10)
                            VStack(alignment: .leading) {
                                Text(manga.manga.title ?? "")
                                if let position = manga.position {
                                    Text(position.prefix(3) == "add" ? position.suffix(position.count - 4) : position.prefix(position.count))
                                        .foregroundStyle(Color(.systemGray))
                                        .font(.system(size: 13))
                                }
                            }
                        }
                    }
                }
            } header: {
                ExpandableSectionHeader(title: "Manga staff positions", isExpanded: $isExpanded)
            }
        }
    }
}
