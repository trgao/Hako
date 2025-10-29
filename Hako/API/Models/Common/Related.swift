//
//  Related.swift
//  Hako
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Related: Codable {
    let relation: String?
    let entry: [JikanListItem]
}

struct RelatedItem: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let type: TypeEnum?
    let title: String?
    let relation: String?
    var anime: Anime?
    var manga: Manga?
}
