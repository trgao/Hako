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
    
    init (id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.character == nil {
                ErrorView(refresh: controller.refresh)
            } else {
                if let character = controller.character {
                    PageList {
                        TextBox(title: "About", text: character.about)
                        CharacterAnimeSection(animes: character.anime)
                        CharacterMangaSection(mangas: character.manga)
                        CharacterVoiceSection(voices: character.voices)
                    } header: {
                        ImageFrame(id: "character\(character.id)", imageUrl: character.images?.jpg?.imageUrl, imageSize: .large)
                            .padding(.vertical, 10)
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
                        if settings.translucentBackground {
                            ImageFrame(id: "character\(id)", imageUrl: character.images?.jpg?.imageUrl, imageSize: .background)
                        }
                    }
                }
                if controller.isLoading {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CharacterAnimeSection: View {
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
            Section {
                ForEach(animes) { anime in
                    NavigationLink {
                        AnimeDetailsView(id: anime.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "anime\(anime.id)", imageUrl: anime.anime.images?.jpg?.largeImageUrl, imageSize: .small)
                                .padding([.trailing], 10)
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
                Text("Animes")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct CharacterMangaSection: View {
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
            Section {
                ForEach(mangas) { manga in
                    NavigationLink {
                        MangaDetailsView(id: manga.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "manga\(manga.id)", imageUrl: manga.manga.images?.jpg?.largeImageUrl, imageSize: .small)
                                .padding([.trailing], 10)
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
                Text("Mangas")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct CharacterVoiceSection: View {
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
            Section {
                ForEach(voices) { voice in
                    NavigationLink {
                        PersonDetailsView(id: voice.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "person\(voice.id)", imageUrl: voice.person.images?.jpg?.imageUrl, imageSize: .small)
                                .padding([.trailing], 10)
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
                Text("Voices")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}
