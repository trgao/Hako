//
//  MangaPosition.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

struct MangaPosition: Codable, Identifiable, Hashable {
    var id: Int { manga.id }
    let manga: ThirdPartyListItem
    let position: String?
}
