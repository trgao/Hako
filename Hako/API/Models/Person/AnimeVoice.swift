//
//  AnimeVoice.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

struct AnimeVoice: Codable, Identifiable {
    var id: String { "anime\(anime.id)character\(character.id)" }
    let anime: ThirdPartyListItem
    let character: ThirdPartyListItem
    let role: String?
}
