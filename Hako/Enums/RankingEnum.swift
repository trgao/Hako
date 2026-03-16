//
//  RankingEnum.swift
//  Hako
//
//  Created by Gao Tianrun on 8/1/26.
//

import Foundation

enum RankingEnum: String {
    case all, tv, ova, movie, special, manga, lightnovels, novels, oneshots, manhwa, manhua, bypopularity, favorite
    
    func toString() -> String {
        switch self {
        case .bypopularity: return "Popularity"
        case .favorite: return "Favourites"
        case .lightnovels: return "Light novels"
        default: return self.rawValue.formatMediaType()
        }
    }
    
    func toIcon() -> String {
        switch self {
        case .all: return "star"
        case .tv, .ova: return "tv"
        case .movie: return "movieclapper"
        case .special: return "sparkles.tv"
        case .manga, .manhwa, .manhua: return "book"
        case .lightnovels: return "book.closed"
        case .novels: return "book.closed"
        case .oneshots: return "book.pages"
        case .bypopularity: return "popcorn"
        case .favorite: return "heart"
        }
    }
}
