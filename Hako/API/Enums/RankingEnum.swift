//
//  RankingEnum.swift
//  Hako
//
//  Created by Gao Tianrun on 8/1/26.
//

import Foundation

enum RankingEnum: String {
    case all, tv, ova, movie, special, manga, novels, oneshots, manhwa, manhua, bypopularity, favorite
    
    func toString() -> String {
        switch self {
        case .bypopularity: return "Popularity"
        case .favorite: return "Favourites"
        default: return self.rawValue.formatMediaType()
        }
    }
}
