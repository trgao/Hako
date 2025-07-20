//
//  UserFavourites.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import Foundation

struct UserFavourites: Codable {
    let anime: [JikanListItem]
    let manga: [JikanListItem]
    let characters: [JikanListItem]
    let people: [JikanListItem]
}
