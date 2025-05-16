//
//  Person.swift
//  Hako
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

struct Person: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let name: String
    let birthday: Date?
    let about: String?
    let images: Images
    let anime: [AnimePosition]
    let manga: [MangaPosition]
    let voices: [AnimeVoice]
}
