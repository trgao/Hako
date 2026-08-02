//
//  UserFavourites.swift
//  Hako
//
//  Created by Gao Tianrun on 20/7/25.
//

import Foundation

struct UserFavourites: Codable {
    let anime: [ThirdPartyListItem]?
    let manga: [ThirdPartyListItem]?
    let characters: [ThirdPartyListItem]?
    let people: [ThirdPartyListItem]?
}
