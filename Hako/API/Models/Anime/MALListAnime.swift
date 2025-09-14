//
//  MALListAnime.swift
//  Hako
//
//  Created by Gao Tianrun on 28/4/24.
//

import Foundation

struct MALListAnime: Codable, Identifiable {
    var id: Int { node.id }
    let node: Node
    let ranking: Ranking?
    var listStatus: MyListStatus?
    
    init(anime: Anime) {
        self.node = .init(id: anime.id, title: anime.title, mainPicture: anime.mainPicture, alternativeTitles: anime.alternativeTitles, startSeason: anime.startSeason, numEpisodes: anime.numEpisodes, numVolumes: nil, numChapters: nil, status: anime.status, rating: anime.rating)
        self.ranking = .init(rank: anime.rank)
        self.listStatus = anime.myListStatus
    }
}
