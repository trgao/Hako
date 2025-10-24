//
//  MALListAnime.swift
//  Hako
//
//  Created by Gao Tianrun on 28/4/24.
//

import Foundation

struct MALListAnime: Codable, Identifiable {
    var id: Int { node.id }
    var node: Anime
    let ranking: Ranking?
    var listStatus: MyListStatus?
    
    init(anime: Anime) {
        self.node = anime
        self.ranking = .init(rank: anime.rank)
        self.listStatus = anime.myListStatus
    }
}
