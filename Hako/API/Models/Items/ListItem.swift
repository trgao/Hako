//
//  ListItem.swift
//  Hako
//
//  Created by Gao Tianrun on 6/12/25.
//

import Foundation

struct ListItem: Codable, Identifiable {
    let id: String
    let anime: Anime?
    let manga: Manga?
}
