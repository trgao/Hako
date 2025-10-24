//
//  MALListManga.swift
//  Hako
//
//  Created by Gao Tianrun on 28/4/24.
//

import Foundation

struct MALListManga: Codable, Identifiable {
    var id: Int { node.id }
    var node: Manga
    let ranking: Ranking?
    var listStatus: MyListStatus?
    
    init(manga: Manga) {
        self.node = manga
        self.ranking = .init(rank: manga.rank)
        self.listStatus = manga.myListStatus
    }
}
