//
//  UserFavouritesInformation.swift
//  Hako
//
//  Created by Gao Tianrun on 15/3/26.
//

import SwiftUI

struct UserFavouritesInformation: View {
    @EnvironmentObject private var settings: SettingsManager
    private let userFavourites: UserFavourites?
    private let anime: [MALListAnime]
    private let manga: [MALListManga]
    
    init(userFavourites: UserFavourites?, anime: [MALListAnime], manga: [MALListManga]) {
        self.userFavourites = userFavourites
        self.anime = anime
        self.manga = manga
    }
    
    var body: some View {
        if let userFavourites = userFavourites {
            if !anime.isEmpty && !settings.hideUserFavouriteAnime {
                ScrollViewCarousel(title: "Favourite anime", spacing: 15) {
                    ForEach(anime) { anime in
                        AnimeGridItem(id: anime.id, title: anime.node.title, enTitle: anime.node.alternativeTitles?.en, imageUrl: anime.node.mainPicture?.large, anime: anime.node)
                    }
                }
            }
            if !manga.isEmpty && !settings.hideUserFavouriteManga {
                ScrollViewCarousel(title: "Favourite manga", spacing: 15) {
                    ForEach(manga) { manga in
                        MangaGridItem(id: manga.id, title: manga.node.title, enTitle: manga.node.alternativeTitles?.en, imageUrl: manga.node.mainPicture?.large, manga: manga.node)
                    }
                }
            }
            if !userFavourites.characters.isEmpty && !settings.hideUserFavouriteCharacters {
                ScrollViewCarousel(title: "Favourite characters", spacing: 15) {
                    ForEach(userFavourites.characters) { character in
                        CharacterGridItem(id: character.id, name: character.name, imageUrl: character.images?.jpg?.imageUrl)
                    }
                }
            }
            if !userFavourites.people.isEmpty && !settings.hideUserFavouritePeople {
                ScrollViewCarousel(title: "Favourite people", spacing: 15) {
                    ForEach(userFavourites.people) { person in
                        PersonGridItem(id: person.id, name: person.name, imageUrl: person.images?.jpg?.imageUrl)
                    }
                }
            }
        }
    }
}
