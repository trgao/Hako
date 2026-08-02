//
//  Animeography.swift
//  Hako
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

struct Animeography: Codable, Identifiable {
    var id: Int { anime.id }
    let anime: ThirdPartyListItem
    let role: String?
}
