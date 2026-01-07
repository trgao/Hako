//
//  ViewTypeEnum.swift
//  Hako
//
//  Created by Gao Tianrun on 6/1/26.
//

enum ViewTypeEnum {
    case anime, manga, character, person, animeGenre, mangaGenre, producer, magazine, news, exploreAnime, exploreManga, none
    
    init(value: String) {
        switch value {
        case "anime": self = .anime
        case "manga": self = .manga
        case "character": self = .character
        case "person": self = .person
        case "animeGenre": self = .animeGenre
        case "mangaGenre": self = .mangaGenre
        case "producer": self = .producer
        case "magazine": self = .magazine
        case "news": self = .news
        case "exploreAnime": self = .exploreAnime
        case "exploreManga": self = .exploreManga
        default:
            self = .none
        }
    }
}
