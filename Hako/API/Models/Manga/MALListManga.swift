//
//  MALListManga.swift
//  Hako
//
//  Created by Gao Tianrun on 28/4/24.
//

import Foundation

struct MALListManga: Codable, Identifiable {
    var id: Int { node.id }
    let node: Node
    let ranking: Ranking?
    var listStatus: MyListStatus?
    
    init(manga: Manga) {
        self.node = .init(id: manga.id, title: manga.title, mainPicture: manga.mainPicture, alternativeTitles: manga.alternativeTitles, startSeason: nil, numEpisodes: nil, numVolumes: manga.numVolumes, numChapters: manga.numChapters, status: manga.status, rating: nil)
        self.ranking = .init(rank: manga.rank)
        self.listStatus = manga.myListStatus
    }
}
