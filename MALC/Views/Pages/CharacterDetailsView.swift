//
//  CharacterDetailsView.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import SwiftUI

struct CharacterDetailsView: View {
    @StateObject var controller: CharacterDetailsViewController
    @State private var isRefresh = false
    private let id: Int
    private let imageUrl: String?
    
    init (id: Int, imageUrl: String?) {
        self.id = id
        self.imageUrl = imageUrl
        self._controller = StateObject(wrappedValue: CharacterDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.character == nil {
                ErrorView(refresh: controller.refresh)
            } else {
                if let character = controller.character {
                    List {
                        Section {
                            VStack(alignment: .center) {
                                ImageFrame(id: "character\(character.id)", imageUrl: imageUrl, imageSize: .large)
                                    .padding([.top], 10)
                                Text(character.name ?? "")
                                    .bold()
                                    .font(.system(size: 25))
                                    .padding(.horizontal, 10)
                                    .multilineTextAlignment(.center)
                                Text(character.nameKanji ?? "")
                                    .padding(.horizontal, 10)
                                    .font(.system(size: 18))
                                    .opacity(0.7)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                        }
                        TextBox(title: "About", text: character.about)
                        CharacterAnimeSection(animes: character.anime)
                        CharacterMangaSection(mangas: character.manga)
                        CharacterVoiceSection(voices: character.voices)
                    }
                    .shadow(radius: 0.5)
                    .task(id: isRefresh) {
                        if isRefresh {
                            await controller.refresh()
                            isRefresh = false
                        }
                    }
                    .refreshable {
                        isRefresh = true
                    }
                }
                if controller.isLoading {
                    LoadingView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await controller.refresh()
        }
    }
}

struct CharacterAnimeSection: View {
    private let animes: [Animeography]
    
    init(animes: [Animeography]) {
        self.animes = animes
    }
    
    var body: some View {
        if !animes.isEmpty {
            Section {
                ForEach(animes) { anime in
                    NavigationLink {
                        AnimeDetailsView(id: anime.id, imageUrl: anime.anime.images?.jpg.imageUrl)
                    } label: {
                        HStack {
                            ImageFrame(id: "anime\(anime.id)", imageUrl: anime.anime.images?.jpg.imageUrl, imageSize: .small)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(anime.anime.title ?? "")
                                Text(anime.role)
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
    
    init(mangas: [Mangaography]) {
        self.mangas = mangas
    }
    
    var body: some View {
        if !mangas.isEmpty {
            Section {
                ForEach(mangas) { manga in
                    NavigationLink {
                        MangaDetailsView(id: manga.id, imageUrl: manga.manga.images?.jpg.imageUrl)
                    } label: {
                        HStack {
                            ImageFrame(id: "manga\(manga.id)", imageUrl: manga.manga.images?.jpg.imageUrl, imageSize: .small)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(manga.manga.title ?? "")
                                Text(manga.role)
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
    
    init(voices: [Voice]) {
        self.voices = voices
    }
    
    var body: some View {
        if !voices.isEmpty {
            Section {
                ForEach(voices) { voice in
                    NavigationLink {
                        PersonDetailsView(id: voice.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "person\(voice.id)", imageUrl: voice.person.images?.jpg.imageUrl, imageSize: .small)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(voice.person.name ?? "")
                                Text(voice.language)
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
