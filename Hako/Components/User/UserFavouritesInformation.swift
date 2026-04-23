//
//  UserFavouritesInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 15/3/26.
//

import SwiftUI

struct UserFavouritesInformation: View {
    @EnvironmentObject private var settings: SettingsManager
    private let anime: [MALListAnime]?
    private let manga: [MALListManga]?
    private let characters: [JikanListItem]?
    private let people: [JikanListItem]?
    private let loadingState: LoadingEnum
    private let load: () async -> Void
    
    init(anime: [MALListAnime]?, manga: [MALListManga]?, characters: [JikanListItem]?, people: [JikanListItem]?, loadingState: LoadingEnum, load: @escaping () async -> Void) {
        self.anime = anime
        self.manga = manga
        self.characters = characters
        self.people = people
        self.loadingState = loadingState
        self.load = load
    }
    
    var body: some View {
        VStack {
            if !settings.hideUserFavouriteAnime {
                ScrollViewCarousel(title: "Favourite anime", count: anime?.count, loadingState: loadingState, refresh: load) {
                    ForEach(anime ?? []) { anime in
                        AnimeGridItem(id: anime.id, title: anime.node.title, enTitle: anime.node.alternativeTitles?.en, jaTitle: anime.node.alternativeTitles?.ja, imageUrl: anime.node.mainPicture?.large, anime: anime.node)
                    }
                    .padding(-5)
                }
            }
            if !settings.hideUserFavouriteManga {
                ScrollViewCarousel(title: "Favourite manga", count: manga?.count, loadingState: loadingState, refresh: load) {
                    ForEach(manga ?? []) { manga in
                        MangaGridItem(id: manga.id, title: manga.node.title, enTitle: manga.node.alternativeTitles?.en, jaTitle: manga.node.alternativeTitles?.ja, imageUrl: manga.node.mainPicture?.large, manga: manga.node)
                    }
                    .padding(-5)
                }
            }
            if !settings.hideUserFavouriteCharacters {
                ScrollViewCarousel(title: "Favourite characters", count: characters?.count, loadingState: loadingState, refresh: load, placeholder: SmallPlaceholderGridItem.init) {
                    ForEach(characters ?? []) { character in
                        CharacterGridItem(id: character.id, name: character.name, imageUrl: character.images?.jpg?.imageUrl)
                    }
                }
            }
            if !settings.hideUserFavouritePeople {
                ScrollViewCarousel(title: "Favourite people", count: people?.count, loadingState: loadingState, refresh: load, placeholder: SmallPlaceholderGridItem.init) {
                    ForEach(people ?? []) { person in
                        PersonGridItem(id: person.id, name: person.name, imageUrl: person.images?.jpg?.imageUrl)
                    }
                }
            }
        }
    }
}
