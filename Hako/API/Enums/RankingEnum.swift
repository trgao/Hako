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
        case .lightnovels: return "Light Novels"
        default: return self.rawValue.formatMediaType()
        }
    }
}
