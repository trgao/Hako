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
            } else {
                if let character = controller.character {
                    PageList {
                        Favourites(favorites: controller.character?.favorites)
                        TextBox(title: "About", text: character.about)
                        CharacterAnimeSection(animes: character.anime)
                        CharacterMangaSection(mangas: character.manga)
                        CharacterVoiceSection(voices: character.voices)
                    } photo: {
                        ImageCarousel(id: "character\(character.id)", imageUrl: character.images?.jpg?.imageUrl, pictures: [Picture(medium: character.images?.jpg?.imageUrl, large: character.images?.jpg?.largeImageUrl)])
                    } title: {
                        NameText(english: character.name, japanese: character.nameKanji)
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

struct CharacterAnimeSection: View {
    @State private var isExpanded = true
    private let animes: [Animeography]
    
    init(animes: [Animeography]?) {
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
                                Text(anime.role ?? "")
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                ExpandableSectionHeader(title: "Animes", isExpanded: $isExpanded)
            }
        }
    }
}

struct CharacterMangaSection: View {
    @State private var isExpanded = true
    private let mangas: [Mangaography]
    
    init(mangas: [Mangaography]?) {
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
                                Text(manga.role ?? "")
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                ExpandableSectionHeader(title: "Mangas", isExpanded: $isExpanded)
            }
        }
    }
}

struct CharacterVoiceSection: View {
    @State private var isExpanded = true
    private let voices: [Voice]
    
    init(voices: [Voice]?) {
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
                        PersonDetailsView(id: voice.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "person\(voice.id)", imageUrl: voice.person.images?.jpg?.imageUrl, imageSize: .small)
                                .padding(.trailing, 10)
                            VStack(alignment: .leading) {
                                Text(voice.person.name ?? "")
                                Text(voice.language ?? "")
                                    .foregroundStyle(Color(.systemGray))
                                    .font(.system(size: 13))
                            }
                        }
                    }
                }
            } header: {
                ExpandableSectionHeader(title: "Voices", isExpanded: $isExpanded)
            }
        }
    }
}
