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
    
    init (id: Int) {
        self.id = id
        self._controller = StateObject(wrappedValue: PersonDetailsViewController(id: id))
    }
    
    var body: some View {
        ZStack {
            if controller.isLoadingError && controller.person == nil {
                ErrorView(refresh: controller.refresh)
            } else {
                if let person = controller.person {
                    PageList {
                        TextBox(title: "About", text: person.about)
                        PersonVoiceSection(voices: person.voices)
                        PersonAnimeSection(animes: person.anime)
                        PersonMangaSection(mangas: person.manga)
                    } header: {
                        ImageFrame(id: "person\(person.id)", imageUrl: controller.person?.images?.jpg?.imageUrl, imageSize: .large)
                            .padding([.top], 10)
                        NameText(english: person.name)
                        if let birthday = person.birthday {
                            Text("Birthday: \(birthday.toString())")
                                .padding(.horizontal, 10)
                                .font(.system(size: 18))
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                        }
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
                            ImageFrame(id: "person\(id)", imageUrl: controller.person?.images?.jpg?.imageUrl, imageSize: .background)
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

struct PersonVoiceSection: View {
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
            Section {
                ForEach(voices) { voice in
                    NavigationLink {
                        AnimeDetailsView(id: voice.anime.id)
                    } label: {
                        HStack {
                            ImageFrame(id: "anime\(voice.anime.id)", imageUrl: voice.anime.images?.jpg?.imageUrl, imageSize: .small)
                                .padding([.trailing], 10)
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
                Text("Voice Acting Roles")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct PersonAnimeSection: View {
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
                Text("Anime Staff Positions")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}

struct PersonMangaSection: View {
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
                Text("Manga Staff Positions")
                    .textCase(nil)
                    .foregroundColor(Color.primary)
                    .font(.system(size: 17))
                    .bold()
            }
        }
    }
}
